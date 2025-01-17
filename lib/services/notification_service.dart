import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'appwrite_service.dart';
import '../models/tea_order.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final AppwriteService _appwrite = AppwriteService();

  Future<void> initialize() async {
    // Request notification permissions
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    final fcmToken = await _firebaseMessaging.getToken();
    if (fcmToken != null) {
      await _updateUserFCMToken(fcmToken);
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen(_updateUserFCMToken);

    // Initialize local notifications
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  Future<void> _updateUserFCMToken(String token) async {
    try {
      final currentUser = _appwrite.account.get();
      if (currentUser != null) {
        await _appwrite.databases.updateDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.usersCollectionId,
          documentId: (await currentUser).$id,
          data: {'fcmToken': token},
        );
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.data}');
    await showNotification(
      title: message.notification?.title ?? 'New Order',
      body: message.notification?.body ?? 'You have a new order to prepare',
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'tea_serve_channel',
      'Tea Service Notifications',
      channelDescription: 'Notifications for tea service orders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> sendJanitorNotification(TeaOrder order) async {
    try {
      // Get all users with janitor role
      final janitors = await _appwrite.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.usersCollectionId,
        queries: [Query.equal('role', 'janitor')],
      );

      // Send notification to each janitor
      for (final janitor in janitors.documents) {
        final fcmToken = janitor.data['fcmToken'];
        if (fcmToken != null) {
          await _appwrite.functions.createExecution(
            functionId: 'sendPushNotification',
            body: json.encode({
              'token': fcmToken,
              'title': 'New Tea Order',
              'body':
                  'New ${order.drinkType.toString().split('.').last} order from ${order.userName}',
              'data': {
                'orderId': order.id,
                'type': 'new_order',
              },
            }),
          );
        }
      }
    } catch (e) {
      print('Error sending janitor notification: $e');
    }
  }
}

// Top-level function for handling background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.data}');
  // Initialize Firebase if needed
  // await Firebase.initializeApp();

  // Show notification
  await NotificationService().showNotification(
    title: message.notification?.title ?? 'New Order',
    body: message.notification?.body ?? 'You have a new order to prepare',
  );
}
