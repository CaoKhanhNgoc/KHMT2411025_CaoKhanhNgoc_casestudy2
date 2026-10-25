import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  static String formatDate(DateTime? date) {
    if (date == null) return 'Chưa đặt';
    return _dateFormat.format(date);
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Chưa đặt';
    return _dateTimeFormat.format(dateTime);
  }

  static bool isOverdue(DateTime? dueDate, String status) {
    if (dueDate == null || status == 'completed') return false;
    return dueDate.isBefore(DateTime.now());
  }

  static bool isDueSoon(DateTime? dueDate, String status, {int hours = 24}) {
    if (dueDate == null || status == 'completed') return false;
    final now = DateTime.now();
    final threshold = now.add(Duration(hours: hours));
    return dueDate.isAfter(now) && dueDate.isBefore(threshold);
  }
}
