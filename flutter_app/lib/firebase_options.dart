import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Placeholder Firebase options.
///
/// Replace this file by running FlutterFire CLI before using real Firebase auth:
///
/// ```bash
/// dart pub global activate flutterfire_cli
/// flutterfire configure
/// ```
///
/// The app catches initialization errors and shows setup guidance if these
/// placeholder values are not replaced.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FIREBASE_API_KEY',
    appId: '1:000000000000:android:replace',
    messagingSenderId: '000000000000',
    projectId: 'replace-with-firebase-project-id',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FIREBASE_API_KEY',
    appId: '1:000000000000:ios:replace',
    messagingSenderId: '000000000000',
    projectId: 'replace-with-firebase-project-id',
    iosBundleId: 'com.drape.ai',
  );

  static const FirebaseOptions macos = ios;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FIREBASE_API_KEY',
    appId: '1:000000000000:web:replace',
    messagingSenderId: '000000000000',
    projectId: 'replace-with-firebase-project-id',
    authDomain: 'replace-with-firebase-project-id.firebaseapp.com',
  );
}
