import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/user_preferences.dart';
import 'providers.dart';
import 'shell.dart';
import 'mobile/shell.dart';
import 'mobile/theme.dart';
import 'firebase_options_dev.dart' as firebase_options;
import 'firebase_options.dart' as production_firebase_options;
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
      options:
          const bool.fromEnvironment('VELTRIX_PRODUCTION')
              ? production_firebase_options
                  .DefaultFirebaseOptions
                  .currentPlatform
              : firebase_options.DefaultFirebaseOptions.currentPlatform,
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
    FirebaseAuth.instance.authStateChanges().listen((user) {
      final userId = user?.uid ?? '';
      FirebaseAnalytics.instance.setUserId(id: userId.isEmpty ? null : userId);
      if (!kIsWeb) FirebaseCrashlytics.instance.setUserIdentifier(userId);
    });

    // Initialize Push Notifications & Razorpay Engine
    await NotificationService().initialize();
    RazorpayPaymentService().initialize();

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null && FirebaseAuth.instance.currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
            'fcmToken': token,
            'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
          });
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  } catch (error, stackTrace) {
    if (kDebugMode) debugPrint('Firebase initialization failed: $error');
    if (kDebugMode) debugPrintStack(stackTrace: stackTrace);
    // App should still work without Firebase
  }

  runApp(const ProviderScope(child: VeltrixRoot()));
}

class VeltrixRoot extends ConsumerWidget {
  const VeltrixRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final useMobileLayout = screenWidth < 900;
    final themeModePref = ref.watch(themeModeProvider);

    return VeltrixErrorBoundary(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Veltrix Sports',
        scrollBehavior: const VeltrixScrollBehavior(),
        theme: M.lightTheme,
        darkTheme: M.darkTheme,
        themeMode: _resolveThemeMode(themeModePref),
        home: useMobileLayout ? const MobileShell() : const Shell(),
      ),
    );
  }

  ThemeMode _resolveThemeMode(ThemeModePreference pref) {
    switch (pref) {
      case ThemeModePreference.light:
        return ThemeMode.light;
      case ThemeModePreference.dark:
        return ThemeMode.dark;
      case ThemeModePreference.system:
        return ThemeMode.system;
    }
  }
}
