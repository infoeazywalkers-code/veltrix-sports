import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'constants.dart';
import 'shell.dart';
import 'mobile/app.dart';
import 'mobile/shell.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Firebase Analytics
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  runApp(kIsWeb ? const VeltrixApp() : const MobileApp());
}

class VeltrixApp extends StatelessWidget {
  const VeltrixApp({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final useMobileLayout = screenWidth < 900;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Veltrix Sports',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(seedColor: navy, primary: navy),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
