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
  // Kalibrasi kedua: hasil fusion masih terlalu merendah karena CNN sudah
  // dikalibrasi T lebih dulu, lalu digabung geometrik dengan kuesioner.
  // Diukur pada data uji: akurasi tipe kulit 82,7% tetapi keyakinan yang
  // ditampilkan hanya 67,2%; kondisi 82,4% vs 41,4%. `T_fusion` memetakan
  // kembali supaya angka yang dilihat pengguna mendekati akurasi sebenarnya
  // di seluruh rentang kualitas jawaban (sigma 0,5..2,5).
  final ts = (skinCfg['T_fusion'] as num?)?.toDouble() ?? 1.0;
  final tc = (condModelCfg['T_fusion'] as num?)?.toDouble()
      ?? (condCfg['T_fusion'] as num?)?.toDouble()
      ?? 1.0;
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
  final psc = calibrate(ps, ts);
  final pcc = calibrate(pc, tc);
  return SkinProfile(
    pSkin: {for (var i = 0; i < sc.length; i++) sc[i]: _round(psc[i], 4)},
    pCond: {for (var i = 0; i < cc.length; i++) cc[i]: _round(pcc[i], 4)},
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

/// Rata-rata [k] probabilitas terkuat untuk kelas [classIndex].
///
/// Dipakai sebagai ukuran bukti visual: lesi di foto selfie hanya terlihat di
/// sedikit patch dan keyakinannya rendah, sehingga "jumlah patch di atas
/// ambang" tidak pernah tercapai. Rata-rata top-k tetap menangkap sinyal itu.
double topKMean(List<List<double>> p, int classIndex, int k) {
  if (k <= 0 || p.isEmpty) return 0;
  final nilai = <double>[
    for (final row in p)
      if (classIndex >= 0 && classIndex < row.length) row[classIndex],
  ]..sort((a, b) => b.compareTo(a));
  if (nilai.isEmpty) return 0;
  final n = k < nilai.length ? k : nilai.length;
  var jumlah = 0.0;
  for (var i = 0; i < n; i++) {
    jumlah += nilai[i];
  }
  return jumlah / n;
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

/// Keyakinan bahwa tiap kondisi BENAR-BENAR ADA di wajah ini.
///
/// Angka yang dulu ditampilkan adalah porsi satu kelas di dalam distribusi 10
/// kelas yang jumlahnya selalu 1. Akibatnya, pada wajah dengan jerawat DAN bekas
/// jerawat keduanya berebut satu jatah 100%: terukur pada 947 wajah uji, kondisi
/// yang jelas terlihat hanya tampil 23,6% rata-rata, dan jerawat bisa muncul 13%.
///
/// Di sini nilai itu diganti `sigmoid(a * logit(bukti) + b)` per kelas, dilatih
/// pada 4.866 wajah split train terhadap pertanyaan "kelas ini muncul di wajah
/// ini?". Bukti = [topKMean] — besaran yang sama dengan yang dipakai gerbang
/// tampil, jadi angka yang muncul di layar memakai bahan yang sudah terbukti.
///
/// Terukur pada 947 wajah test: ECE 0,107 -> 0,021, Brier 0,110 -> 0,050,
/// AUC 0,936 -> 0,962, dan keyakinan rata-rata pada wajah yang memang punya
/// kondisinya naik 23,6% -> 71,5%.
///
/// [cfg] = `condition.models.<model>.presence` di ml_config.json.
///
/// Hasil dibatasi 1%..99%: model tidak pernah benar-benar pasti, dan pada
/// kalibrasi ini nilai di atas 0,99 memang di luar jangkauan data latih
/// (terukur ECE 0,021 — pada p≈0,99 laju sebenarnya ≈0,97). Tanpa batas ini
/// layar menampilkan "100% yakin", yang mengklaim lebih dari yang terukur.
Map<String, double> presenceProbs(
  List<List<double>> tiles,
  List<String> classes,
  Map<String, dynamic> cfg,
) {
  if (tiles.isEmpty || cfg.isEmpty) return const {};
  final a = (cfg['a'] as List?)?.cast<num>();
  final b = (cfg['b'] as List?)?.cast<num>();
  if (a == null || b == null) return const {};
  final k = (cfg['top_k'] as num?)?.toInt() ?? 3;
  final out = <String, double>{};
  for (var j = 0; j < classes.length; j++) {
    if (j >= a.length || j >= b.length) continue;
    // Clear bukan lesi: tidak pernah ditampilkan sebagai kondisi, dan
    // parameternya jatuh ke pemisahan sempurna saat dilatih.
    if (classes[j] == 'Clear') continue;
    final bukti = topKMean(tiles, j, k).clamp(1e-4, 1 - 1e-4);
    final z = math.log(bukti / (1 - bukti));
    final p = 1 / (1 + math.exp(-((a[j].toDouble() * z) + b[j].toDouble())));
    out[classes[j]] = p.clamp(0.01, 0.99);
  }
  return out;
}
