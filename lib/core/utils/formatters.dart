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

const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// `5 Nov 2026, 09.30` in the device's local time (Indonesian style).
String formatDateTime(DateTime t) {
  final l = t.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${l.day} ${_months[l.month - 1]} ${l.year}, '
      '${two(l.hour)}.${two(l.minute)}';
}
