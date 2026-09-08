import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/mobile/theme.dart';
import 'package:veltrix_sports/constants.dart';

void main() {
  group('M.theme', () {
    test('has correct scaffold background', () {
      expect(M.theme.scaffoldBackgroundColor, bg);
    });

    test('has Material3 enabled', () {
      expect(M.theme.useMaterial3, true);
    });

    test('has navy appBar theme', () {
      expect(M.theme.appBarTheme.backgroundColor, navy);
      expect(M.theme.appBarTheme.foregroundColor, Colors.white);
    });

    test('has zero appBar elevation', () {
      expect(M.theme.appBarTheme.elevation, 0);
    });

    test('has white bottom nav bar background', () {
      expect(M.theme.bottomNavigationBarTheme.backgroundColor, Colors.white);
    });

    test('has navy selected item color in bottom nav', () {
      expect(M.theme.bottomNavigationBarTheme.selectedItemColor, M.navy);
    });

    test('has muted unselected item color in bottom nav', () {
      expect(M.theme.bottomNavigationBarTheme.unselectedItemColor, M.muted);
    });

    test('has cardTheme with zero elevation', () {
      expect(M.theme.cardTheme.elevation, 0);
    });

    test('has cardTheme with cardBg color', () {
      expect(M.theme.cardTheme.color, M.cardBg);
    });

    test('colorScheme has navy primary', () {
      expect(M.theme.colorScheme.primary, navy);
    });

    test('colorScheme has lime secondary', () {
      expect(M.theme.colorScheme.secondary, lime);
    });
  });
}
