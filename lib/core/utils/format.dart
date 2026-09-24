import 'package:intl/intl.dart';

final _cop = NumberFormat.currency(
  locale: 'es_CO',
  symbol: '\$',
  decimalDigits: 0,
);

String formatMoney(num value) => _cop.format(value);

String formatKm(num value) {
  final n = NumberFormat.decimalPattern('es_CO');
  return '${n.format(value)} km';
}
