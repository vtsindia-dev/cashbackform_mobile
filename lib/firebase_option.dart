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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAAd_tEChMYShy9EqldVLM-JpSldnlfmzg',
    appId: '1:523459218953:web:TODO_REPLACE_WITH_WEB_APP_ID',
    messagingSenderId: '523459218953',
    projectId: 'cashback-90cba',
    storageBucket: 'cashback-90cba.firebasestorage.app',
    authDomain: 'cashback-90cba.firebaseapp.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAAd_tEChMYShy9EqldVLM-JpSldnlfmzg',
    appId: '1:523459218953:android:d4f00cfc6ef07620fff2d8',
    messagingSenderId: '523459218953',
    projectId: 'cashback-90cba',
    storageBucket: 'cashback-90cba.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAAd_tEChMYShy9EqldVLM-JpSldnlfmzg',
    appId: '1:523459218953:ios:TODO_REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '523459218953',
    projectId: 'cashback-90cba',
    storageBucket: 'cashback-90cba.firebasestorage.app',
    iosBundleId: 'com.cashback_farms.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAAd_tEChMYShy9EqldVLM-JpSldnlfmzg',
    appId: '1:523459218953:ios:TODO_REPLACE_WITH_MACOS_APP_ID',
    messagingSenderId: '523459218953',
    projectId: 'cashback-90cba',
    storageBucket: 'cashback-90cba.firebasestorage.app',
    iosBundleId: 'com.cashback_farms.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAAd_tEChMYShy9EqldVLM-JpSldnlfmzg',
    appId: '1:523459218953:web:TODO_REPLACE_WITH_WINDOWS_APP_ID',
    messagingSenderId: '523459218953',
    projectId: 'cashback-90cba',
    storageBucket: 'cashback-90cba.firebasestorage.app',
    authDomain: 'cashback-90cba.firebaseapp.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyAAd_tEChMYShy9EqldVLM-JpSldnlfmzg',
    appId: '1:523459218953:web:TODO_REPLACE_WITH_LINUX_APP_ID',
    messagingSenderId: '523459218953',
    projectId: 'cashback-90cba',
    storageBucket: 'cashback-90cba.firebasestorage.app',
    authDomain: 'cashback-90cba.firebaseapp.com',
  );
}