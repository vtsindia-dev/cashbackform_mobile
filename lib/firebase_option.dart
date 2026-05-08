import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAAd_tEChMYShy9EqldVLM-JpSldnlfmzg',
    appId: '1:523459218953:android:d4f00cfc6ef07620fff2d8',
    messagingSenderId: '523459218953',
    projectId: 'cashback-90cba',
    storageBucket: 'cashback-90cba.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAAd_tEChMYShy9EqldVLM-JpSldnlfmzg',
    appId: '1:523459218953:android:d4f00cfc6ef07620fff2d8',
    messagingSenderId: '523459218953',
    projectId: 'cashback-90cba',
    storageBucket: 'cashback-90cba.firebasestorage.app',
    iosBundleId: 'com.cashback_farms.app',
  );
}