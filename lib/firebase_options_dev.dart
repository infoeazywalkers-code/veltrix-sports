// Development Firebase Options.
// NOTE: dev and prod share the same Firebase project (veltrix-sports) — the
// android entries are identical to firebase_options.dart. The web entry below
// must use the real web app registration (same as production); using the
// Android API key / a mismatched web appId breaks ALL web backend calls.
// iOS/macOS/Windows entries below are still demo placeholders.
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
    apiKey: 'AIzaSyAmseNI3VGRd1mIonnzO4P9tp8_xdDt8p4',
    appId: '1:25616595982:web:9858680bae4c42fcc8d05f',
    messagingSenderId: '25616595982',
    projectId: 'veltrix-sports',
    authDomain: 'veltrix-sports.firebaseapp.com',
    storageBucket: 'veltrix-sports.firebasestorage.app',
    measurementId: 'G-22EME77ENP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAwtl2l3e6m4eKxHP-_-wq2PcDPkom5z_o',
    appId: '1:25616595982:android:d3aa8cf032ea388fc8d05f',
    messagingSenderId: '25616595982',
    projectId: 'veltrix-sports',
    storageBucket: 'veltrix-sports.firebasestorage.app',
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
