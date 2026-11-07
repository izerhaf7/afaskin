import 'dart:math' as math;

/// Late fusion CNN + kuesioner (port dari notebook 05 / `afaskin_fusion.py`).
///
/// Semua fungsi murni (tanpa I/O) supaya bisa diuji terhadap hasil Python
/// (`test/fixtures/ml_golden.json`).

List<double> softmax(List<double> z) {
  final m = z.reduce(math.max);
  final e = [for (final v in z) math.exp(v - m)];
  final s = e.fold<double>(0, (a, b) => a + b);
  return [for (final v in e) v / s];
}

double _safeLog(double p) => math.log(p.clamp(1e-12, 1.0));

/// Temperature scaling: softmax(log(p) / T).
List<double> calibrate(List<double> p, double t) =>
    softmax([for (final v in p) _safeLog(v) / t]);

/// `arithmetic`: a*Pm + (1-a)*Pq. `geometric`: softmax(a*log Pm + (1-a)*log Pq).
List<double> fuse(List<double> pm, List<double> pq, double alpha, String rule) {
  if (rule == 'arithmetic') {
    return [for (var i = 0; i < pm.length; i++) alpha * pm[i] + (1 - alpha) * pq[i]];
  }
  return softmax([
    for (var i = 0; i < pm.length; i++)
      alpha * _safeLog(pm[i]) + (1 - alpha) * _safeLog(pq[i]),
  ]);
}

/// Jawaban kuesioner: kunci `Q1`..`Q7`, null = tidak diisi.
typedef Answers = Map<String, int?>;

/// Q1 (+Q4, 6-Q5) -> indeks keberminyakan -> keanggotaan Gaussian per tipe kulit.
List<double> questionnaireSkin(Answers a, Map<String, dynamic> cfg) {
  final classes = (cfg['classes'] as List).cast<String>();
  final mu = (cfg['skin_mu'] as Map).cast<String, num>();
  final sigma = (cfg['skin_sigma'] as num).toDouble();
  final vals = <double>[
    a['Q1']!.toDouble(),
    if (a['Q4'] != null) a['Q4']!.toDouble(),
    if (a['Q5'] != null) 6 - a['Q5']!.toDouble(),
  ];
  final o = vals.reduce((x, y) => x + y) / vals.length;
  final lik = [
    for (final c in classes) math.exp(-math.pow(o - mu[c]!, 2) / (2 * sigma * sigma)),
  ];
  final s = lik.reduce((x, y) => x + y);
  return [for (final v in lik) v / s];
}

/// Q3 (jerawat meradang), Q6 (komedo), Q7 (bekas jerawat) -> softmax(beta * bukti).
List<double> questionnaireCondition(Answers a, Map<String, dynamic> cfg) {
  final classes = (cfg['classes'] as List).cast<String>();
  final beta = (cfg['beta'] as num).toDouble();
  final acne = (cfg['acne_group'] as List).cast<String>();
  final comedo = (cfg['comedo_group'] as List).cast<String>();
  double ev(String q) => a[q] == null ? 0.5 : (a[q]! - 1) / 4;
  final e3 = ev('Q3'), e6 = ev('Q6'), e7 = ev('Q7');
  final e = <String, double>{
    for (final c in acne) c: e3,
    for (final c in comedo) c: e6,
    'Scars': e7,
    'Milium': 0.5,
    'Birthmark': 0.5,
    'Clear': 1 - [e3, e6, e7].reduce(math.max),
  };
  return softmax([for (final c in classes) beta * e[c]!]);
}

/// Hasil fusion untuk satu pengguna (disimpan untuk rekomendasi).
class SkinProfile {
  const SkinProfile({required this.pSkin, required this.pCond, required this.sensitive});

  factory SkinProfile.fromJson(Map<String, dynamic> j) => SkinProfile(
    pSkin: (j['p_skin'] as Map).map((k, v) => MapEntry(k as String, (v as num).toDouble())),
    pCond: (j['p_cond'] as Map).map((k, v) => MapEntry(k as String, (v as num).toDouble())),
    sensitive: j['sensitive'] as bool,
  );

  /// Kunci huruf kecil: dry, normal, oily (urutan kelas model).
  final Map<String, double> pSkin;

  /// Kunci nama kelas model: Acne, Birthmark, ..., Clear.
  final Map<String, double> pCond;
  final bool sensitive;

  Map<String, dynamic> toJson() => {'p_skin': pSkin, 'p_cond': pCond, 'sensitive': sensitive};
}

double _round(double v, int digits) {
  final f = math.pow(10, digits);
  return (v * f).roundToDouble() / f;
}

/// Port `predict_profile`: kalibrasi CNN, fusion dengan kuesioner, flag sensitif (Q2 >= 4).
SkinProfile predictProfile({
  required List<double> pSkinCnn,
  required List<double> pCondCnn,
  required Answers answers,
  required Map<String, dynamic> skinCfg,
  required Map<String, dynamic> condCfg,
  required Map<String, dynamic> condModelCfg,
}) {
  final sc = (skinCfg['classes'] as List).cast<String>();
  final cc = (condCfg['classes'] as List).cast<String>();
  final ps = fuse(
    calibrate(pSkinCnn, (skinCfg['T'] as num).toDouble()),
    questionnaireSkin(answers, skinCfg),
    (skinCfg['alpha'] as num).toDouble(),
    skinCfg['rule'] as String,
  );
  final pc = fuse(
    calibrate(pCondCnn, (condModelCfg['T'] as num).toDouble()),
    questionnaireCondition(answers, condCfg),
    (condModelCfg['alpha'] as num).toDouble(),
    condModelCfg['rule'] as String,
  );
  return SkinProfile(
    pSkin: {for (var i = 0; i < sc.length; i++) sc[i]: _round(ps[i], 4)},
    pCond: {for (var i = 0; i < cc.length; i++) cc[i]: _round(pc[i], 4)},
    sensitive: (answers['Q2'] ?? 0) >= 4,
  );
}

/// Probabilitas per patch -> satu distribusi per wajah + region tiap kondisi.
///
/// Kelas lesi: rata-rata `topK` patch tertinggi. Clear: rata-rata semua patch.
/// Region: area dengan probabilitas maksimum >= 0,3 (urut menurun), atau
/// area dengan nilai tertinggi bila tidak ada.
///
/// [mode] `mean`: rata-rata semua patch untuk setiap kelas (dipakai di aplikasi;
/// top-k terbukti selalu "menemukan" lesi di wajah bersih). `top_k`: versi
/// backend lama, dipertahankan untuk golden test.
({List<double> probs, Map<String, List<String>> where}) aggregateTiles(
  List<List<double>> p,
  List<String> regions,
  List<String> classes, {
  int topK = 3,
  String mode = 'top_k',
}) {
  final k = math.min(topK, p.length);
  final out = List<double>.filled(classes.length, 0);
  final where = <String, List<String>>{};
  for (var j = 0; j < classes.length; j++) {
    final col = [for (final row in p) row[j]];
    if (mode == 'mean' || classes[j] == 'Clear') {
      out[j] = col.reduce((a, b) => a + b) / col.length;
    } else {
      final sorted = [...col]..sort();
      out[j] = sorted.sublist(sorted.length - k).reduce((a, b) => a + b) / k;
    }
    final byRegion = <String, double>{};
    for (var i = 0; i < col.length; i++) {
      byRegion[regions[i]] = math.max(byRegion[regions[i]] ?? 0, col[i]);
    }
    final ordered = byRegion.entries.toList();
    // Stabil: sama seperti `sorted()` Python untuk nilai yang sama.
    mergeSortDesc(ordered, (e) => e.value);
    final hit = [for (final e in ordered) if (e.value >= 0.3) e.key];
    where[classes[j]] = hit.isNotEmpty ? hit : [_argmaxKey(byRegion)];
  }
  final s = out.reduce((a, b) => a + b);
  return (probs: [for (final v in out) v / s], where: where);
}

/// Bukti visual per kelas: jumlah & proporsi patch yang diprediksi kelas itu
/// dengan keyakinan >= [conf]. Kondisi hanya ditampilkan kalau model citra
/// sendiri melihatnya (kuesioner tidak boleh memunculkan kondisi sendirian).
///
/// [conf] 0,5 (bukan 0,6): lesi kecil di patch 15% lebar wajah jarang membuat
/// satu kelas menang dengan keyakinan tinggi, jadi ambang 0,6 membuat model
/// tidak pernah melaporkan apa pun. Diukur pada 8 foto berjerawat + 5 selfie
/// bersih: 0,5 dengan `gate_min_patches` 5 menangkap 7/8 dan 0/5.
Map<String, ({int count, double frac})> visualEvidence(
  List<List<double>> p,
  List<String> classes, {
  double conf = 0.5,
}) {
  final counts = List<int>.filled(classes.length, 0);
  for (final row in p) {
    var best = 0;
    for (var j = 1; j < row.length; j++) {
      if (row[j] > row[best]) best = j;
    }
    if (row[best] >= conf) counts[best]++;
  }
  return {
    for (var j = 0; j < classes.length; j++)
      classes[j]: (count: counts[j], frac: p.isEmpty ? 0 : counts[j] / p.length),
  };
}

String _argmaxKey(Map<String, double> m) {
  String? best;
  for (final e in m.entries) {
    if (best == null || e.value > m[best]!) best = e.key;
  }
  return best!;
}

/// Urut menurun yang stabil (elemen bernilai sama tetap pada urutan aslinya).
void mergeSortDesc<T>(List<T> list, double Function(T) key) {
  final indexed = [for (var i = 0; i < list.length; i++) (i, list[i])];
  indexed.sort((a, b) {
    final c = key(b.$2).compareTo(key(a.$2));
    return c != 0 ? c : a.$1.compareTo(b.$1);
  });
  for (var i = 0; i < list.length; i++) {
    list[i] = indexed[i].$2;
  }
}
