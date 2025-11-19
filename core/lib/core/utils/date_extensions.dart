import 'package:intl/intl.dart';

extension DateUtil on String {

  String withDateFormat({String? format}) {
    if (isEmpty) {
      return '';
    }
    final date = DateTime.parse(this);
    final formatter = DateFormat(format ?? 'MM/dd/yyyy');
    return formatter.format(date);
  }
}

extension DateUtils on DateTime {
  String formatDate({String? format}) {
    final formatter = DateFormat(format ?? 'MM/dd/yyyy');
    return formatter.format(this);
  }
}


