// GENERATED FILE - jangan diedit manual.
// Sumber: recommender/ingredient_mapping.csv
// Bangkitkan ulang: python src/make_ingredient_guide.py

import 'package:afaskin/data/models/models.dart';

/// Peran sebuah kandungan untuk suatu kondisi.
enum IngredientRole {
  /// Membantu memperbaiki kondisi.
  recommended,

  /// Sebaiknya dihindari karena memperburuk kondisi.
  avoid,
}

/// Satu kandungan aktif beserta manfaat dan rujukannya.
class IngredientInfo {
  const IngredientInfo({
    required this.name,
    required this.benefit,
    required this.source,
    this.role = IngredientRole.recommended,
  });

  final String name;

  /// Manfaat singkat dalam bahasa sehari-hari.
  final String benefit;

  /// Rujukan ilmiah/medis di balik peran kandungan ini.
  final String source;

  final IngredientRole role;

  bool get isAvoid => role == IngredientRole.avoid;
}

abstract final class IngredientGuide {
  /// Kandungan per kondisi kulit, urut dari bobot terbesar.
  static const List<IngredientInfo> _acne = <IngredientInfo>[
    IngredientInfo(
      name: 'Salicylic Acid',
      benefit: 'BHA larut minyak, membersihkan sumbatan di dalam pori.',
      source: 'Zaenglein et al. 2016; Reynolds et al. 2024',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Benzoyl Peroxide',
      benefit: 'Membunuh bakteri penyebab jerawat.',
      source: 'Zaenglein et al. 2016; Reynolds et al. 2024',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Azelaic Acid',
      benefit: 'Meredakan peradangan sekaligus memudarkan bekas kehitaman.',
      source: 'Zaenglein et al. 2016',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Niacinamide',
      benefit: 'Menenangkan peradangan dan mengatur produksi minyak.',
      source: 'Draelos et al. 2006',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Retinol',
      benefit: 'Mempercepat pergantian sel kulit dan merangsang kolagen.',
      source: 'Zaenglein et al. 2016',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Tea Tree',
      benefit: 'Antibakteri alami, bukti ilmiahnya masih terbatas.',
      source: 'Zaenglein et al. 2016',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Comedogenic Oil',
      benefit: 'Minyak atau ester yang mudah menyumbat pori.',
      source: 'Draelos & DiNardo 2006',
      role: IngredientRole.avoid,
    ),
  ];

  static const List<IngredientInfo> _papular = <IngredientInfo>[
    IngredientInfo(
      name: 'Salicylic Acid',
      benefit: 'BHA larut minyak, membersihkan sumbatan di dalam pori.',
      source: 'Zaenglein et al. 2016',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Benzoyl Peroxide',
      benefit: 'Membunuh bakteri penyebab jerawat.',
      source: 'Zaenglein et al. 2016',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Azelaic Acid',
      benefit: 'Meredakan peradangan sekaligus memudarkan bekas kehitaman.',
      source: 'Zaenglein et al. 2016',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Niacinamide',
      benefit: 'Menenangkan peradangan dan mengatur produksi minyak.',
      source: 'Draelos et al. 2006',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Comedogenic Oil',
      benefit: 'Minyak atau ester yang mudah menyumbat pori.',
      source: 'Draelos & DiNardo 2006',
      role: IngredientRole.avoid,
    ),
  ];

  static const List<IngredientInfo> _purulent = <IngredientInfo>[
    IngredientInfo(
      name: 'Benzoyl Peroxide',
      benefit: 'Membunuh bakteri penyebab jerawat.',
      source: 'Zaenglein et al. 2016',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Salicylic Acid',
      benefit: 'BHA larut minyak, membersihkan sumbatan di dalam pori.',
      source: 'Zaenglein et al. 2016',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Azelaic Acid',
      benefit: 'Meredakan peradangan sekaligus memudarkan bekas kehitaman.',
      source: 'Zaenglein et al. 2016',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Tea Tree',
      benefit: 'Antibakteri alami, bukti ilmiahnya masih terbatas.',
      source: 'Zaenglein et al. 2016',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Comedogenic Oil',
      benefit: 'Minyak atau ester yang mudah menyumbat pori.',
      source: 'Draelos & DiNardo 2006',
      role: IngredientRole.avoid,
    ),
  ];

  static const List<IngredientInfo> _blackhead = <IngredientInfo>[
    IngredientInfo(
      name: 'Salicylic Acid',
      benefit: 'BHA larut minyak, membersihkan sumbatan di dalam pori.',
      source: 'Zaenglein et al. 2016',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Retinol',
      benefit: 'Mempercepat pergantian sel kulit dan merangsang kolagen.',
      source: 'Zaenglein et al. 2016',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'AHA',
      benefit: 'Mengelupas sel kulit mati di lapisan permukaan.',
      source: 'Kornhauser et al. 2010',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Niacinamide',
      benefit: 'Menenangkan peradangan dan mengatur produksi minyak.',
      source: 'Draelos et al. 2006',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Comedogenic Oil',
      benefit: 'Minyak atau ester yang mudah menyumbat pori.',
      source: 'Draelos & DiNardo 2006',
      role: IngredientRole.avoid,
    ),
  ];

  static const List<IngredientInfo> _whitehead = <IngredientInfo>[
    IngredientInfo(
      name: 'Salicylic Acid',
      benefit: 'BHA larut minyak, membersihkan sumbatan di dalam pori.',
      source: 'Zaenglein et al. 2016',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Retinol',
      benefit: 'Mempercepat pergantian sel kulit dan merangsang kolagen.',
      source: 'Zaenglein et al. 2016',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'AHA',
      benefit: 'Mengelupas sel kulit mati di lapisan permukaan.',
      source: 'Kornhauser et al. 2010',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Comedogenic Oil',
      benefit: 'Minyak atau ester yang mudah menyumbat pori.',
      source: 'Draelos & DiNardo 2006',
      role: IngredientRole.avoid,
    ),
  ];

  static const List<IngredientInfo> _milium = <IngredientInfo>[
    IngredientInfo(
      name: 'Retinol',
      benefit: 'Mempercepat pergantian sel kulit dan merangsang kolagen.',
      source: 'Berk & Bayliss 2008',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'AHA',
      benefit: 'Mengelupas sel kulit mati di lapisan permukaan.',
      source: 'Berk & Bayliss 2008',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Heavy Occlusive',
      benefit: 'Krim sangat tebal yang bisa memicu milia.',
      source: 'Berk & Bayliss 2008',
      role: IngredientRole.avoid,
    ),
  ];

  static const List<IngredientInfo> _cysts = <IngredientInfo>[
    IngredientInfo(
      name: 'Benzoyl Peroxide',
      benefit: 'Membunuh bakteri penyebab jerawat.',
      source: 'Reynolds et al. 2024',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Azelaic Acid',
      benefit: 'Meredakan peradangan sekaligus memudarkan bekas kehitaman.',
      source: 'Reynolds et al. 2024',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Comedogenic Oil',
      benefit: 'Minyak atau ester yang mudah menyumbat pori.',
      source: 'Draelos & DiNardo 2006',
      role: IngredientRole.avoid,
    ),
  ];

  static const List<IngredientInfo> _scars = <IngredientInfo>[
    IngredientInfo(
      name: 'Vitamin C',
      benefit: 'Antioksidan yang membantu memudarkan noda gelap.',
      source: 'Telang 2013',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Niacinamide',
      benefit: 'Menenangkan peradangan dan mengatur produksi minyak.',
      source: 'Hakozaki et al. 2002',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Sunscreen Filter',
      benefit: 'Melindungi kulit dari sinar UV agar bekas tidak makin gelap.',
      source: 'Telang 2013',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Azelaic Acid',
      benefit: 'Meredakan peradangan sekaligus memudarkan bekas kehitaman.',
      source: 'Zaenglein et al. 2016',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Retinol',
      benefit: 'Mempercepat pergantian sel kulit dan merangsang kolagen.',
      source: 'Zaenglein et al. 2016',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'AHA',
      benefit: 'Mengelupas sel kulit mati di lapisan permukaan.',
      source: 'Kornhauser et al. 2010',
      role: IngredientRole.recommended,
    ),
    IngredientInfo(
      name: 'Alpha Arbutin',
      benefit: 'Menghambat pembentukan melanin pada noda gelap.',
      source: 'Telang 2013',
      role: IngredientRole.recommended,
    ),
  ];

  static const List<IngredientInfo> _birthmark = <IngredientInfo>[
    IngredientInfo(
      name: 'Sunscreen Filter',
      benefit: 'Melindungi kulit dari sinar UV agar bekas tidak makin gelap.',
      source: '(rujukan dokter)',
      role: IngredientRole.recommended,
    ),
  ];

  /// Perawatan dasar saat tidak ada kondisi khusus yang terdeteksi.
  static const List<IngredientInfo> basic = <IngredientInfo>[
    IngredientInfo(
      name: 'Sunscreen Filter',
      benefit: 'Melindungi kulit dari sinar UV agar bekas tidak makin gelap.',
      source: '(perawatan dasar)',
    ),
    IngredientInfo(
      name: 'Hyaluronic Acid',
      benefit: 'Menjaga kelembapan kulit tanpa menyumbat pori.',
      source: '(perawatan dasar)',
    ),
  ];

  /// Kandungan untuk sebuah kondisi; kosong bila kondisi tidak dikenal.
  static List<IngredientInfo> forCondition(SkinConditionLabel c) => switch (c) {
    SkinConditionLabel.acne => _acne,
    SkinConditionLabel.papular => _papular,
    SkinConditionLabel.purulent => _purulent,
    SkinConditionLabel.blackhead => _blackhead,
    SkinConditionLabel.whitehead => _whitehead,
    SkinConditionLabel.milium => _milium,
    SkinConditionLabel.cysts => _cysts,
    SkinConditionLabel.scars => _scars,
    SkinConditionLabel.birthmark => _birthmark,
    SkinConditionLabel.unknown => const <IngredientInfo>[],
  };
}
