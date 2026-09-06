import 'package:flutter/material.dart';

const navy = Color(0xff102a43);
const ink = Color(0xff243b53);
const muted = Color(0xff829ab1);
const bg = Color(0xfff5f7fa);
const lime = Color(0xffb7e22a);
const blue = Color(0xff1687e0);
const purple = Color(0xff7657d5);
const orange = Color(0xffff8a3d);
const teal = Color(0xff00a9a5);
const darkNavy = Color(0xff081f33);
const lightGreen = Color(0xfff0f7ec);
const successGreen = Color(0xff4c8c2b);
const successText = Color(0xff3f6f26);

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
