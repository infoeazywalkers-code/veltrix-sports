import 'package:flutter/material.dart';
import '../constants.dart' as web;

class M {
  M._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double pageH = 16;
  static const double pageV = 20;

  static const double rSm = 10;
  static const double rMd = 14;
  static const double rLg = 18;
  static const double rXl = 22;
  static const double rFull = 50;

  static const double touchTarget = 48;
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 32;

  static const double navBarHeight = 72;

  static const Color navy = web.navy;
  static const Color ink = web.ink;
  static const Color muted = web.muted;
  static const Color bg = web.bg;
  static const Color lime = web.lime;
  static const Color blue = web.blue;
  static const Color purple = web.purple;
  static const Color orange = web.orange;
  static const Color teal = web.teal;
  static const Color darkNavy = web.darkNavy;
  static const Color cardBg = Colors.white;
  static const Color divider = Color(0xFFE8ECF0);

  static const TextStyle screenTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: navy,
    height: 1.15,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: navy,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: ink,
    height: 1.4,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: muted,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: muted,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: ink,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.0,
    color: lime,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: navy,
  );

  static const TextStyle cardBody = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: muted,
    height: 1.4,
  );

  static const TextStyle statBig = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: navy,
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: muted,
  );

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: navy,
      primary: navy,
      secondary: lime,
      surface: cardBg,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: cardBg,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rLg),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: navy,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: navy,
      unselectedItemColor: muted,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 8,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    ),
    dividerTheme: const DividerThemeData(
      color: divider,
      thickness: 1,
      space: 1,
    ),
  );

  static EdgeInsets pagePadding(BuildContext context) => const EdgeInsets.symmetric(
    horizontal: pageH,
    vertical: pageV,
  );

  static double maxWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w > 600 ? 600 : w;
  }
}
