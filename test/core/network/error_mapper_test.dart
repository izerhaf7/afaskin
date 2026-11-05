import 'package:afaskin/core/network/error_mapper.dart';
import 'package:afaskin/core/network/failures.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _err(DioExceptionType type, {int? status, Object? data}) {
  final req = RequestOptions(path: '/analyze');
  return DioException(
    requestOptions: req,
    type: type,
    response: status == null
        ? null
        : Response<dynamic>(
            requestOptions: req,
            statusCode: status,
            data: data,
          ),
  );
}

void main() {
  group('mapToFailure', () {
    test('timeouts -> NetworkFailure(isTimeout)', () {
      for (final t in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        final f = mapToFailure(_err(t));
        expect(f, isA<NetworkFailure>().having((e) => e.isTimeout, 't', true));
      }
    });

    test('connection error -> NetworkFailure', () {
      final f = mapToFailure(_err(DioExceptionType.connectionError));
      expect(f, isA<NetworkFailure>().having((e) => e.isTimeout, 't', false));
    });

    test('422 quality_rejected -> QualityRejected with reasons', () {
      final f = mapToFailure(
        _err(
          DioExceptionType.badResponse,
          status: 422,
          data: {
            'error': 'quality_rejected',
            'reasons': ['too_dark', 'blurry'],
            'message': 'Foto terlalu gelap dan kurang tajam.',
          },
        ),
      );
      expect(f, isA<QualityRejected>());
      final q = f as QualityRejected;
      expect(q.reasons, ['too_dark', 'blurry']);
      expect(q.message, 'Foto terlalu gelap dan kurang tajam.');
      expect(q.readableReasons, ['Foto terlalu gelap', 'Foto kurang tajam']);
    });

    test('422 with another body -> ServerFailure', () {
      final f = mapToFailure(
        _err(
          DioExceptionType.badResponse,
          status: 422,
          data: {'detail': <Object>[]},
        ),
      );
      expect(f, isA<ServerFailure>().having((e) => e.statusCode, 's', 422));
    });

    test('500 -> ServerFailure', () {
      final f = mapToFailure(_err(DioExceptionType.badResponse, status: 500));
      expect(f, isA<ServerFailure>().having((e) => e.statusCode, 's', 500));
    });

    test('non-Dio errors -> ServerFailure; Failures pass through', () {
      expect(mapToFailure(const FormatException()), isA<ServerFailure>());
      const nf = NetworkFailure();
      expect(mapToFailure(nf), same(nf));
    });

    test('messages are friendly Indonesian text', () {
      expect(const NetworkFailure().message, contains('koneksi'));
      expect(const ServerFailure().message, contains('server'));
    });
  });
}
