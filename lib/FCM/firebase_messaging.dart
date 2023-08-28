import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;


  Future<void> initialize(BuildContext context) async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(context, message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {

    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  void _showNotification(BuildContext context, RemoteMessage message) {
    // Customize the notification appearance and behavior
    final notification = message.notification;

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        priority: Priority.high,
        importance: Importance.max,
      ),
    );

    FlutterLocalNotificationsPlugin().show(
      0,
      notification?.title ?? '',
      notification?.body ?? '',
      notificationDetails,
    );
  }
}
