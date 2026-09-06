import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/constants.dart';

void main() {
  group('monthName', () {
    test('returns January for 1', () {
      expect(monthName(1), 'January');
    });

    test('returns February for 2', () {
      expect(monthName(2), 'February');
    });

    test('returns March for 3', () {
      expect(monthName(3), 'March');
    });

    test('returns April for 4', () {
      expect(monthName(4), 'April');
    });

    test('returns May for 5', () {
      expect(monthName(5), 'May');
    });

    test('returns June for 6', () {
      expect(monthName(6), 'June');
    });

    test('returns July for 7', () {
      expect(monthName(7), 'July');
    });

    test('returns August for 8', () {
      expect(monthName(8), 'August');
    });

    test('returns September for 9', () {
      expect(monthName(9), 'September');
    });

    test('returns October for 10', () {
      expect(monthName(10), 'October');
    });

    test('returns November for 11', () {
      expect(monthName(11), 'November');
    });

    test('returns December for 12', () {
      expect(monthName(12), 'December');
    });

    test('returns empty string for 0', () {
      expect(monthName(0), '');
    });

    test('all 12 months have correct length', () {
      expect(monthName(1).length, 7); // January
      expect(monthName(2).length, 8); // February
      expect(monthName(3).length, 5); // March
      expect(monthName(4).length, 5); // April
      expect(monthName(5).length, 3); // May
      expect(monthName(6).length, 4); // June
      expect(monthName(7).length, 4); // July
      expect(monthName(8).length, 6); // August
      expect(monthName(9).length, 9); // September
      expect(monthName(10).length, 7); // October
      expect(monthName(11).length, 8); // November
      expect(monthName(12).length, 8); // December
    });

    test('monthName returns strings', () {
      for (int i = 1; i <= 12; i++) {
        expect(monthName(i), isA<String>());
        expect(monthName(i).isNotEmpty, isTrue);
      }
    });
  });

  group('normalizeDate', () {
    test('strips time from DateTime', () {
      final date = DateTime(2026, 3, 15, 10, 30, 45, 123);
      final result = normalizeDate(date);
      expect(result, DateTime(2026, 3, 15));
    });

    test('preserves date-only DateTime', () {
      final date = DateTime(2026, 1, 1);
      expect(normalizeDate(date), date);
    });

    test('handles end of year', () {
      final date = DateTime(2026, 12, 31, 23, 59, 59);
      expect(normalizeDate(date), DateTime(2026, 12, 31));
    });

    test('handles start of year', () {
      final date = DateTime(2026, 1, 1, 0, 0, 0);
      expect(normalizeDate(date), DateTime(2026, 1, 1));
    });

    test('handles leap year', () {
      final date = DateTime(2028, 2, 29, 12, 0);
      expect(normalizeDate(date), DateTime(2028, 2, 29));
    });
  });

  group('getStartOfWeek', () {
    test('Monday returns itself', () {
      final monday = DateTime(2026, 8, 31); // Monday
      expect(getStartOfWeek(monday), monday);
    });

    test('Sunday returns previous Monday', () {
      final sunday = DateTime(2026, 9, 6);
      final monday = getStartOfWeek(sunday);
      expect(monday.weekday, DateTime.monday);
      expect(monday.day, 31);
    });

    test('weekOffset 0 returns current week Monday', () {
      final date = DateTime(2026, 9, 3); // Thursday
      final monday = getStartOfWeek(date);
      expect(monday.weekday, DateTime.monday);
    });

    test('weekOffset positive moves forward', () {
      final date = DateTime(2026, 9, 3);
      final next = getStartOfWeek(date, weekOffset: 1);
      expect(next.day, 7);
    });

    test('weekOffset negative moves backward', () {
      final date = DateTime(2026, 9, 3);
      final prev = getStartOfWeek(date, weekOffset: -1);
      expect(prev.day, 24);
    });

    test('normalizes time to midnight', () {
      final date = DateTime(2026, 9, 3, 15, 30);
      final monday = getStartOfWeek(date);
      expect(monday.hour, 0);
      expect(monday.minute, 0);
    });
  });
}
