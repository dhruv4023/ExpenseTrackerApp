import 'package:intl/intl.dart';

String formatDate(String dateTime) {
  // Parse the date string into a DateTime object
  DateTime parsedDate = DateTime.parse(dateTime.substring(0, 4) +
      '-' +
      dateTime.substring(4, 6) +
      '-' +
      dateTime.substring(6, 8) +
      'T' +
      dateTime.substring(8, 10) +
      ':' +
      dateTime.substring(10, 12) +
      ':' +
      dateTime.substring(12, 14));
  // Format the DateTime object to a readable string
  String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(parsedDate);

  return formattedDate;
}

String getCurrentDateTimeFormatted() {
  // Get the current date and time
  DateTime now = DateTime.now();

  // Format the date and time
  String formattedDateTime = DateFormat('yyyyMMddHHmmss').format(now);

  return formattedDateTime;
}
