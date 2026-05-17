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
    apiKey: 'AIzaSyDaEbUKLYGEYGVLlhjypVfOFFjCEKHqxTg',
    appId: '1:1006897282967:web:f8295ac50f6e5eb5448ed2',
    messagingSenderId: '1006897282967',
    projectId: 'school-app-csdese',
    authDomain: 'school-app-csdese.firebaseapp.com',
    storageBucket: 'school-app-csdese.firebasestorage.app',
    measurementId: 'G-488YW63WMP',
  );

  // TODO: Replace with your actual Web configuration from Firebase Console

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBcgPy7R2plQaIU2RWoGYpk_OQ9dFcjsj8',
    appId: '1:1006897282967:android:d4cf228cb7989993448ed2',
    messagingSenderId: '1006897282967',
    projectId: 'school-app-csdese',
    storageBucket: 'school-app-csdese.firebasestorage.app',
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