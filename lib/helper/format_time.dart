import 'package:flutter/material.dart';

class FormatTime {
  static String getFormatTime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  static String getFormatSentTime(
      {required BuildContext context, required String time}) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime currTime = DateTime.now();
    if (date.month == currTime.month &&
        date.day == currTime.day &&
        date.year == currTime.year) {
      return TimeOfDay.fromDateTime(date).format(context);
    }
    return "${date.day}  ${getMonth(date)}";
  }

  static String getMonth(DateTime date) {
    switch (date.month) {
      case 1:
        return "Jan";
      case 2:
        return "Feb";
      case 3:
        return "Mar";
      case 4:
        return "Apr";
      case 5:
        return "May";
      case 6:
        return "Jun";
      case 7:
        return "Jul";
      case 8:
        return "Aug";
      case 9:
        return "Sep";
      case 10:
        return "Oct";
      case 11:
        return "Nov";
      case 12:
        return "Dec";
    }
    return "NA";
  }
}
