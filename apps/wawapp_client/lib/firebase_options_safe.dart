// نسخة آمنة من إعدادات Firebase بدون مفاتيح حقيقية
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'demo-web-api-key',
    appId: '1:demo:web:demo',
    messagingSenderId: 'demo',
    projectId: 'demo-project',
    authDomain: 'demo-project.firebaseapp.com',
    storageBucket: 'demo-project.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'demo-android-api-key',
    appId: '1:demo:android:demo',
    messagingSenderId: 'demo',
    projectId: 'demo-project',
    storageBucket: 'demo-project.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'demo-ios-api-key',
    appId: '1:demo:ios:demo',
    messagingSenderId: 'demo',
    projectId: 'demo-project',
    storageBucket: 'demo-project.firebasestorage.app',
    iosBundleId: 'com.wawapp.client',
  );
}
