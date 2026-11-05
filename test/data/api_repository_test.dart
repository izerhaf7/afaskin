import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:afaskin/core/network/dio_client.dart';
import 'package:afaskin/core/network/failures.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/data/repositories/analysis_repository_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Asset bundle reading straight from disk (no Flutter binding needed, so
/// real sockets work in this test).
class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(await File(key).readAsBytes());
}

String _mock(String p) => File('assets/mock/$p').readAsStringSync();

/// Minimal server implementing the FastAPI contract for one test.
class _FakeBackend {
  late HttpServer server;
  final requests = <HttpRequest>[];
  final bodies = <Uint8List>[];
  FutureOr<void> Function(HttpRequest req, Uint8List body)? handler;

  String get baseUrl => 'http://${server.address.host}:${server.port}';

  Future<void> start() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      final body = await req.fold<BytesBuilder>(
        BytesBuilder(),
        (b, chunk) => b..add(chunk),
      );
      requests.add(req);
      bodies.add(body.takeBytes());
      await handler!(req, bodies.last);
    });
  }

  static Future<void> json(HttpRequest req, String body, {int status = 200}) {
    req.response
      ..statusCode = status
      ..headers.contentType = ContentType.json
      ..write(body);
    return req.response.close();
  }
}

const _payload = AnalyzePayload(
  profile: UserProfile(age: 21, gender: Gender.female, budgetMax: 150000),
  questionnaire: {'q1': 4, 'q2': 2},
);

void main() {
  late _FakeBackend backend;
  late AnalysisRepositoryApi repo;

  setUp(() async {
    backend = _FakeBackend();
    await backend.start();
    final dio = buildDio(baseUrl: backend.baseUrl)
      ..interceptors.removeWhere((i) => i is LogInterceptor);
    repo = AnalysisRepositoryApi(dio, _DiskBundle());
  });

  tearDown(() => backend.server.close(force: true));

  test('GET /api/v1/health', () async {
    backend.handler = (req, _) =>
        _FakeBackend.json(req, '{"status":"ok","model_version":"v1.2"}');
    final h = await repo.health();
    expect(h.modelVersion, 'v1.2');
    expect(backend.requests.single.uri.path, '/api/v1/health');
  });

  test('POST /analyze sends multipart image + JSON payload', () async {
    backend.handler = (req, _) =>
        _FakeBackend.json(req, _mock('analyze_success.json'));
    final jpeg = Uint8List.fromList([0xFF, 0xD8, 1, 2, 3, 0xFF, 0xD9]);

    final r = await repo.analyze(imageJpeg: jpeg, payload: _payload);
    expect(r.skinType.label, SkinType.oily);

    final req = backend.requests.single;
    expect(req.method, 'POST');
    expect(req.uri.path, '/api/v1/analyze');
    expect(req.headers.contentType!.mimeType, 'multipart/form-data');

    final body = latin1.decode(backend.bodies.single);
    expect(body, contains('name="image"; filename="face.jpg"'));
    expect(body, contains('content-type: image/jpeg'));
    expect(body, contains(latin1.decode(jpeg)));
    expect(body, contains('name="payload"'));
    expect(body, contains(jsonEncode(_payload.toJson())));
    expect(body, contains('"budget_max":150000'));
  });

  test('POST /analyze 422 quality_rejected -> QualityRejected', () async {
    backend.handler = (req, _) =>
        _FakeBackend.json(req, _mock('analyze_quality_fail.json'), status: 422);
    await expectLater(
      repo.analyze(imageJpeg: Uint8List(1), payload: _payload),
      throwsA(
        isA<QualityRejected>()
            .having((e) => e.reasons, 'reasons', ['too_dark', 'blurry'])
            .having((e) => e.message, 'message', contains('gelap')),
      ),
    );
  });

  test('FastAPI validation 422 (not quality) -> ServerFailure', () async {
    backend.handler = (req, _) => _FakeBackend.json(
      req,
      '{"detail":[{"loc":["body","image"],"msg":"field required"}]}',
      status: 422,
    );
    await expectLater(
      repo.analyze(imageJpeg: Uint8List(1), payload: _payload),
      throwsA(isA<ServerFailure>().having((e) => e.statusCode, 's', 422)),
    );
  });

  test('POST /analyze is not retried on failure', () async {
    backend.handler = (req, _) => _FakeBackend.json(req, '{}', status: 500);
    await expectLater(
      repo.analyze(imageJpeg: Uint8List(1), payload: _payload),
      throwsA(isA<ServerFailure>()),
    );
    expect(backend.requests, hasLength(1));
  });

  test('GET /recommendations query params', () async {
    backend.handler = (req, _) =>
        _FakeBackend.json(req, _mock('recommendations.json'));
    final items = await repo.getRecommendations(
      analysisId: 'abc-123',
      category: ProductCategory.serum,
      maxPrice: 150000,
    );
    expect(items, isNotEmpty);
    expect(backend.requests.single.uri.path, '/api/v1/recommendations');
    expect(backend.requests.single.uri.queryParameters, {
      'analysis_id': 'abc-123',
      'category': 'serum',
      'max_price': '150000',
    });

    await repo.getRecommendations(analysisId: 'abc-123');
    expect(backend.requests.last.uri.queryParameters, {
      'analysis_id': 'abc-123',
    });
  });

  test('GET /products/{id} (id is URL-encoded)', () async {
    backend.handler = (req, _) =>
        _FakeBackend.json(req, _mock('product_detail.json'));
    final p = await repo.getProduct('prd 003');
    expect(p.ingredients, isNotEmpty);
    expect(backend.requests.single.uri.path, '/api/v1/products/prd%20003');
  });

  test('GET /questionnaire falls back to the bundled copy', () async {
    backend.handler = (req, _) => _FakeBackend.json(req, '{}', status: 503);
    final q = await repo.getQuestionnaire();
    expect(q.questions, hasLength(7));
  });

  test('malformed JSON -> ServerFailure', () async {
    backend.handler = (req, _) => _FakeBackend.json(req, '{"items": 3}');
    await expectLater(
      repo.getRecommendations(analysisId: 'x'),
      throwsA(isA<ServerFailure>()),
    );
  });

  test('server down -> NetworkFailure (GET retried first)', () async {
    final port = backend.server.port;
    await backend.server.close(force: true);
    final dio = buildDio(baseUrl: 'http://127.0.0.1:$port')
      ..interceptors.removeWhere((i) => i is LogInterceptor);
    final down = AnalysisRepositoryApi(dio, _DiskBundle());
    await expectLater(down.health(), throwsA(isA<NetworkFailure>()));
  });
}
