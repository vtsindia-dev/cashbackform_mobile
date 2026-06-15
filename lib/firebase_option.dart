import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

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
    apiKey: 'AIzaSyDh9swc6rWta-GQY8pubhlFHF8Bj6a8cx4',
    appId: '1:629218686640:android:495a70eafeae402c2eed75',
    messagingSenderId: '629218686640',
    projectId: 'geofarms-53879',
    storageBucket: 'geofarms-53879.firebasestorage.app',
  );


  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAp_DtB4ycrbQoJWSVOsKeQxojvCWhkv80',
    appId: '1:629218686640:ios:db67d076ed4e2e3c2eed75',
    messagingSenderId: '629218686640',
    projectId: 'geofarms-53879',
    storageBucket: 'geofarms-53879.firebasestorage.app',
    iosBundleId: 'com.geofarms.app',
  );

}