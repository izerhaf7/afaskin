import 'package:afaskin/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatRupiah', () {
    expect(formatRupiah(0), 'Rp0');
    expect(formatRupiah(999), 'Rp999');
    expect(formatRupiah(89000), 'Rp89.000');
    expect(formatRupiah(150000), 'Rp150.000');
    expect(formatRupiah(1250000), 'Rp1.250.000');
  });

  test('formatPercent', () {
    expect(formatPercent(0.78), '78%');
    expect(formatPercent(0.005), '1%');
  });
}
