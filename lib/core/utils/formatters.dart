/// Formats Rupiah without pulling in `intl`: `150000` -> `Rp150.000`.
String formatRupiah(int amount) {
  final digits = amount.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
    buf.write(digits[i]);
  }
  return '${amount < 0 ? '-' : ''}Rp$buf';
}

/// `0.78` -> `78%`.
String formatPercent(double value) => '${(value * 100).round()}%';
