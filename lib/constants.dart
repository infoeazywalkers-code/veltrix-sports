import 'package:flutter/material.dart';

const navy = Color(0xff123047);
const ink = Color(0xff1f2933);
const muted = Color(0xff66788a);
const bg = Color(0xfff6f2ea);
const lime = Color(0xffc8f169);
const blue = Color(0xff2176ae);
const purple = Color(0xff7759c2);
const orange = Color(0xffe9763f);
const teal = Color(0xff008f8c);
const darkNavy = Color(0xff081826);
const lightGreen = Color(0xffeef8df);
const successGreen = Color(0xff3f7f32);
const successText = Color(0xff315f29);

void showFeatureMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ),
  );
}

/// Normalizes a [DateTime] to midnight (00:00:00.000) for clean date comparison.
DateTime normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

/// Returns the Monday of the week containing [date].
DateTime getStartOfWeek(DateTime date, {int weekOffset = 0}) {
  final cleanDate = normalizeDate(date);
  final daysFromMonday = cleanDate.weekday - 1;
  return cleanDate
      .subtract(Duration(days: daysFromMonday))
      .add(Duration(days: weekOffset * 7));
}

/// Returns the full month name for the given month number (1-12).
String monthName(int m) =>
    [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ][m];
