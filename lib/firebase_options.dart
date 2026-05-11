import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD4X_U4zX8QFmZoB-PZOFzpQhwtu12fBNg',
    appId: '1:530748718250:web:cf138928b1a7c6193424d3',
    messagingSenderId: '530748718250',
    projectId: 'schooladminproject-66cb7',
    authDomain: 'schooladminproject-66cb7.firebaseapp.com',
    storageBucket: 'schooladminproject-66cb7.firebasestorage.app',
  );

  // TODO: Replace with your actual Web configuration from Firebase Console

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA6tVkUr72On5msiPcJYSn6HEjqpR-T3Q0',
    appId: '1:530748718250:android:d55ec709901f370f3424d3',
    messagingSenderId: '530748718250',
    projectId: 'schooladminproject-66cb7',
    storageBucket: 'schooladminproject-66cb7.firebasestorage.app',
  );

  // TODO: Replace with your actual Android configuration from Firebase Console

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAwzh4W5u6Qp3ZqaqrfdJlXyq4ql1g2_YQ',
    appId: '1:530748718250:ios:2b8b2b24351dd7383424d3',
    messagingSenderId: '530748718250',
    projectId: 'schooladminproject-66cb7',
    storageBucket: 'schooladminproject-66cb7.firebasestorage.app',
    iosBundleId: 'com.cleverstudio.schoolapp',
  );

  // TODO: Replace with your actual iOS configuration from Firebase Console
}