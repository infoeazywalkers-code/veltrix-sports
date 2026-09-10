import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/core/constants.dart';

void main() {
  group('normalizeDate', () {
    test('normalizes DateTime to midnight', () {
      final date = DateTime(2026, 9, 5, 14, 30, 45, 123);
      final normalized = normalizeDate(date);
      expect(normalized.year, 2026);
      expect(normalized.month, 9);
      expect(normalized.day, 5);
      expect(normalized.hour, 0);
      expect(normalized.minute, 0);
      expect(normalized.second, 0);
      expect(normalized.millisecond, 0);
    });

    test('preserves date for already-normalized DateTime', () {
      final date = DateTime(2026, 1, 1);
      final normalized = normalizeDate(date);
      expect(normalized, date);
    });

    test('handles midnight DateTime', () {
      final date = DateTime(2026, 12, 31, 0, 0, 0);
      final normalized = normalizeDate(date);
      expect(normalized, date);
    });

    test('handles end-of-day DateTime', () {
      final date = DateTime(2026, 6, 15, 23, 59, 59, 999);
      final normalized = normalizeDate(date);
      expect(normalized.year, 2026);
      expect(normalized.month, 6);
      expect(normalized.day, 15);
      expect(normalized.hour, 0);
    });

    test('handles leap year date', () {
      final date = DateTime(2028, 2, 29, 12, 0);
      final normalized = normalizeDate(date);
      expect(normalized.year, 2028);
      expect(normalized.month, 2);
      expect(normalized.day, 29);
      expect(normalized.hour, 0);
    });
  });

  group('getStartOfWeek', () {
    test('returns Monday for a Wednesday', () {
      // Sept 3, 2026 is a Thursday
      final date = DateTime(2026, 9, 3);
      final monday = getStartOfWeek(date);
      expect(monday.weekday, DateTime.monday);
      expect(monday.day, 31); // Aug 31 is Monday of that week
      expect(monday.month, 8);
    });

    test('returns same day if already Monday', () {
      final date = DateTime(2026, 8, 31); // Monday
      final monday = getStartOfWeek(date);
      expect(monday, date);
    });

    test('returns Monday for Sunday', () {
      final date = DateTime(2026, 9, 6); // Sunday
      final monday = getStartOfWeek(date);
      expect(monday.weekday, DateTime.monday);
      expect(monday.day, 31);
      expect(monday.month, 8);
    });

    test('returns Monday for Saturday', () {
      final date = DateTime(2026, 9, 5); // Saturday
      final monday = getStartOfWeek(date);
      expect(monday.weekday, DateTime.monday);
      expect(monday.day, 31);
    });

    test('returns Monday for Tuesday', () {
      final date = DateTime(2026, 9, 1); // Tuesday
      final monday = getStartOfWeek(date);
      expect(monday.weekday, DateTime.monday);
      expect(monday.day, 31);
      expect(monday.month, 8);
    });

    test('weekOffset=1 returns next week Monday', () {
      final date = DateTime(2026, 9, 3); // Thursday
      final nextMonday = getStartOfWeek(date, weekOffset: 1);
      expect(nextMonday.weekday, DateTime.monday);
      expect(nextMonday.day, 7); // Sept 7
      expect(nextMonday.month, 9);
    });

    test('weekOffset=-1 returns previous week Monday', () {
      final date = DateTime(2026, 9, 3); // Thursday
      final prevMonday = getStartOfWeek(date, weekOffset: -1);
      expect(prevMonday.weekday, DateTime.monday);
      expect(prevMonday.day, 24); // Aug 24
      expect(prevMonday.month, 8);
    });

    test('weekOffset=2 returns two weeks ahead Monday', () {
      final date = DateTime(2026, 9, 3);
      final twoWeeksAhead = getStartOfWeek(date, weekOffset: 2);
      expect(twoWeeksAhead.weekday, DateTime.monday);
      expect(twoWeeksAhead.day, 14);
      expect(twoWeeksAhead.month, 9);
    });

    test('normalizes time to midnight for week start', () {
      final date = DateTime(2026, 9, 3, 15, 45);
      final monday = getStartOfWeek(date);
      expect(monday.hour, 0);
      expect(monday.minute, 0);
      expect(monday.second, 0);
    });
  });

  group('Color constants', () {
    test('navy has correct value', () {
      expect(navy.toARGB32(), 0xff123047);
    });

    test('ink has correct value', () {
      expect(ink.toARGB32(), 0xff1f2933);
    });

    test('muted has correct value', () {
      expect(muted.toARGB32(), 0xff66788a);
    });

    test('bg has correct value', () {
      expect(bg.toARGB32(), 0xfff6f2ea);
    });

    test('lime has correct value', () {
      expect(lime.toARGB32(), 0xffc8f169);
    });

    test('blue has correct value', () {
      expect(blue.toARGB32(), 0xff2176ae);
    });

    test('purple has correct value', () {
      expect(purple.toARGB32(), 0xff7759c2);
    });

    test('orange has correct value', () {
      expect(orange.toARGB32(), 0xffe9763f);
    });

    test('teal has correct value', () {
      expect(teal.toARGB32(), 0xff008f8c);
    });

    test('darkNavy has correct value', () {
      expect(darkNavy.toARGB32(), 0xff081826);
    });

    test('lightGreen has correct value', () {
      expect(lightGreen.toARGB32(), 0xffeef8df);
    });

    test('successGreen has correct value', () {
      expect(successGreen.toARGB32(), 0xff3f7f32);
    });

    test('successText has correct value', () {
      expect(successText.toARGB32(), 0xff315f29);
    });
  });
}
