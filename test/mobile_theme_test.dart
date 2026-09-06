import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/mobile/theme.dart';

void main() {
  group('M (Mobile Theme) constants', () {
    test('spacing constants are defined', () {
      expect(M.xs, 4);
      expect(M.sm, 8);
      expect(M.md, 12);
      expect(M.base, 16);
      expect(M.lg, 24);
      expect(M.xl, 32);
      expect(M.xxl, 48);
    });

    test('page padding constants', () {
      expect(M.pageH, 16);
      expect(M.pageV, 20);
    });

    test('border radius constants', () {
      expect(M.rSm, 10);
      expect(M.rMd, 14);
      expect(M.rLg, 18);
      expect(M.rXl, 22);
      expect(M.rFull, 50);
    });

    test('icon size constants', () {
      expect(M.iconSm, 20);
      expect(M.iconMd, 24);
      expect(M.iconLg, 32);
    });

    test('touch target constant', () {
      expect(M.touchTarget, 48);
    });

    test('nav bar height constant', () {
      expect(M.navBarHeight, 72);
    });

    test('color constants are defined', () {
      expect(M.navy, isNotNull);
      expect(M.ink, isNotNull);
      expect(M.muted, isNotNull);
      expect(M.bg, isNotNull);
      expect(M.lime, isNotNull);
      expect(M.blue, isNotNull);
      expect(M.purple, isNotNull);
      expect(M.orange, isNotNull);
      expect(M.teal, isNotNull);
      expect(M.darkNavy, isNotNull);
      expect(M.cardBg, isNotNull);
      expect(M.divider, isNotNull);
    });

    test('text styles are defined', () {
      expect(M.screenTitle, isNotNull);
      expect(M.sectionTitle, isNotNull);
      expect(M.body, isNotNull);
      expect(M.bodyMuted, isNotNull);
      expect(M.caption, isNotNull);
      expect(M.label, isNotNull);
      expect(M.badge, isNotNull);
      expect(M.cardTitle, isNotNull);
      expect(M.cardBody, isNotNull);
      expect(M.statBig, isNotNull);
      expect(M.statLabel, isNotNull);
    });

    test('screenTitle has correct properties', () {
      expect(M.screenTitle.fontSize, 28);
      expect(M.screenTitle.fontWeight, FontWeight.w900);
      expect(M.screenTitle.color, M.navy);
    });

    test('sectionTitle has correct properties', () {
      expect(M.sectionTitle.fontSize, 20);
      expect(M.sectionTitle.fontWeight, FontWeight.w800);
      expect(M.sectionTitle.color, M.navy);
    });

    test('body has correct properties', () {
      expect(M.body.fontSize, 15);
      expect(M.body.fontWeight, FontWeight.w400);
      expect(M.body.color, M.ink);
    });

    test('badge has correct properties', () {
      expect(M.badge.fontSize, 10);
      expect(M.badge.fontWeight, FontWeight.w900);
      expect(M.badge.color, M.lime);
    });

    test('theme getter returns ThemeData', () {
      final theme = M.theme;
      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, M.bg);
    });

    test('theme has correct cardTheme', () {
      final theme = M.theme;
      expect(theme.cardTheme.elevation, 0);
      expect(theme.cardTheme.color, M.cardBg);
    });

    test('theme has correct appBarTheme', () {
      final theme = M.theme;
      expect(theme.appBarTheme.backgroundColor, M.navy);
      expect(theme.appBarTheme.elevation, 0);
    });

    test('theme has correct bottomNavigationBarTheme', () {
      final theme = M.theme;
      expect(theme.bottomNavigationBarTheme.selectedItemColor, M.navy);
      expect(theme.bottomNavigationBarTheme.unselectedItemColor, M.muted);
    });

    test('maxWidth is a static function', () {
      expect(M.maxWidth, isA<Function>());
    });
  });
}
