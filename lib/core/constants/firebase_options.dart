import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyUSMA-DemoApiKeyForLocalDevelopment',
    appId: '1:108291029:web:usma102938102',
    messagingSenderId: '108291029',
    projectId: 'usma-scholarship-mota',
    authDomain: 'usma-scholarship-mota.firebaseapp.com',
    storageBucket: 'usma-scholarship-mota.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyUSMA-DemoApiKeyForLocalDevelopment',
    appId: '1:108291029:android:usma102938102',
    messagingSenderId: '108291029',
    projectId: 'usma-scholarship-mota',
    storageBucket: 'usma-scholarship-mota.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyUSMA-DemoApiKeyForLocalDevelopment',
    appId: '1:108291029:ios:usma102938102',
    messagingSenderId: '108291029',
    projectId: 'usma-scholarship-mota',
    storageBucket: 'usma-scholarship-mota.appspot.com',
    iosBundleId: 'in.gov.tribal.scholarship.usma',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyUSMA-DemoApiKeyForLocalDevelopment',
    appId: '1:108291029:ios:usma102938102',
    messagingSenderId: '108291029',
    projectId: 'usma-scholarship-mota',
    storageBucket: 'usma-scholarship-mota.appspot.com',
    iosBundleId: 'in.gov.tribal.scholarship.usma',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyUSMA-DemoApiKeyForLocalDevelopment',
    appId: '1:108291029:web:usma102938102',
    messagingSenderId: '108291029',
    projectId: 'usma-scholarship-mota',
    authDomain: 'usma-scholarship-mota.firebaseapp.com',
    storageBucket: 'usma-scholarship-mota.appspot.com',
  );
}
