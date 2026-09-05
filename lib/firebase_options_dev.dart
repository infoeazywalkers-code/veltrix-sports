// Development Firebase Options - For demo purposes only
// Replace with your actual Firebase project credentials
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForWeb',
    appId: '1:123456789012:web:abcdef123456',
    messagingSenderId: '123456789012',
    projectId: 'veltrix-sports-demo',
    authDomain: 'veltrix-sports-demo.firebaseapp.com',
    storageBucket: 'veltrix-sports-demo.appspot.com',
    measurementId: 'G-DEMO123456',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForAndroid',
    appId: '1:123456789012:android:abcdef123456',
    messagingSenderId: '123456789012',
    projectId: 'veltrix-sports-demo',
    storageBucket: 'veltrix-sports-demo.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForIOS',
    appId: '1:123456789012:ios:abcdef123456',
    messagingSenderId: '123456789012',
    projectId: 'veltrix-sports-demo',
    storageBucket: 'veltrix-sports-demo.appspot.com',
    iosClientId: '123456789012-abcdef123456.apps.googleusercontent.com',
    iosBundleId: 'com.veltrixsports.veltrixSports',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForMacOS',
    appId: '1:123456789012:macos:abcdef123456',
    messagingSenderId: '123456789012',
    projectId: 'veltrix-sports-demo',
    storageBucket: 'veltrix-sports-demo.appspot.com',
    iosClientId: '123456789012-abcdef123456.apps.googleusercontent.com',
    iosBundleId: 'com.veltrixsports.veltrixSports',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForWindows',
    appId: '1:123456789012:windows:abcdef123456',
    messagingSenderId: '123456789012',
    projectId: 'veltrix-sports-demo',
    authDomain: 'veltrix-sports-demo.firebaseapp.com',
    storageBucket: 'veltrix-sports-demo.appspot.com',
  );
}