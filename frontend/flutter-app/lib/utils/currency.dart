import 'package:intl/intl.dart';

String formatNaira(double value) {
  // Formats as ₦1,234,567.89
  final fmt = NumberFormat.currency(symbol: '₦', name: 'NGN');
  return fmt.format(value);
}
