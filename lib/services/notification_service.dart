import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static DateTime? _initTime;
  // Track shown notification IDs to prevent duplicates
  static final Set<String> _shownIds = {};
  static StreamSubscription? _notifSubscription;

  static Future<void> init() async {
    if (_initialized) return;

    // 1. Initialize Local Notifications
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInitSettings = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _localNotifications.initialize(settings: initSettings);

    // Create Notification Channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Request permissions for Android 13+
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initTime = DateTime.now();
    _initialized = true;
  }

  static void startListeningForUser(String userId, String role) {
    if (!_initialized) return;
    _notifSubscription?.cancel();
    _shownIds.clear();

    // Listen to notifications collection - watch latest 5 to catch rapid sends
    _notifSubscription = FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .listen((snapshot) async {
      for (final doc in snapshot.docs) {
        final data = doc.data();

        // Skip already-shown notifications
        if (_shownIds.contains(doc.id)) continue;

        // Prevent triggering for notifications created before the app started listening
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        if (createdAt != null && _initTime != null && createdAt.isBefore(_initTime!)) {
          _shownIds.add(doc.id); // mark as seen so we don't re-check
          continue;
        }

        final targetType = data['targetType'];
        final targetId = data['targetId'];
        final title = data['title'] ?? 'New Notification';
        final message = data['message'] ?? '';

        bool shouldShow = false;

        if (targetType == 'all_students' && role == 'student') {
          shouldShow = true;
        } else if (targetType == 'all_teachers' && role == 'teacher') {
          shouldShow = true;
        } else if (targetType == 'student' && targetId == userId) {
          shouldShow = true;
        } else if (targetType == 'teacher' && targetId == userId) {
          shouldShow = true;
        } else if (targetType == 'class' && role == 'student') {
          final studentDoc = await FirebaseFirestore.instance
              .collection('students')
              .doc(userId)
              .get();
          if (studentDoc.exists) {
            final studentClass = studentDoc.data()?['className'] as String?;
            if (studentClass != null) {
              // Compare normalized class names
              final targetClassNorm = targetId.replaceAll(' ', '').replaceAll('-', '_').toLowerCase();
              final studentClassNorm = studentClass.replaceAll(' ', '').replaceAll('-', '_').toLowerCase();
              if (studentClassNorm == targetClassNorm) {
                shouldShow = true;
              }
            }
          }
        }

        _shownIds.add(doc.id);

        if (shouldShow) {
          _showLocalNotification(doc.id.hashCode, title, message);
        }
      }
    }, onError: (e) {
      debugPrint("Notification listener error: $e");
    });
  }

  static void stopListening() {
    _notifSubscription?.cancel();
    _notifSubscription = null;
    _shownIds.clear();
  }

  static Future<void> _showLocalNotification(int id, String title, String body) async {
    try {
      await _localNotifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }
}
