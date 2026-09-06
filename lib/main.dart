import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'constants.dart';
import 'shell.dart';
import 'mobile/shell.dart';
import 'firebase_options_dev.dart' as firebase_options;
import 'services/notification_service.dart';
import 'services/razorpay_service.dart';
import 'widgets/error_boundary.dart';

class VeltrixScrollBehavior extends MaterialScrollBehavior {
  const VeltrixScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register Global Error Boundary
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
    return VeltrixErrorBoundary(details: details);
  };

  // Catch unhandled async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    return true;
  };

  try {
    await Firebase.initializeApp(
      options: firebase_options.DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    if (!kIsWeb) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        !kDebugMode,
      );
    }
    await FirebaseAnalytics.instance.logAppOpen();

    // Initialize Push Notifications & Razorpay Engine
    await NotificationService().initialize();
    RazorpayPaymentService().initialize();
  } catch (error, stackTrace) {
    if (kDebugMode) debugPrint('Firebase initialization failed: $error');
    if (kDebugMode) debugPrintStack(stackTrace: stackTrace);
    // App should still work without Firebase
  }

  runApp(const ProviderScope(child: VeltrixRoot()));
}

class VeltrixRoot extends StatelessWidget {
  const VeltrixRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final useMobileLayout = screenWidth < 900;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Veltrix Sports',
      scrollBehavior: const VeltrixScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(seedColor: navy, primary: navy),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w900, color: navy),
          titleMedium: TextStyle(fontWeight: FontWeight.w800, color: ink),
          bodyMedium: TextStyle(color: ink, height: 1.35),
        ),
      ),
      home: useMobileLayout ? const MobileShell() : const Shell(),
    );
  }
}
