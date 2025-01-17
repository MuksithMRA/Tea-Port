import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tea_serve/services/appwrite_service.dart';

import '../models/tea_order.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late final FirebaseMessaging _messaging;
  late final FlutterLocalNotificationsPlugin _localNotifications;

  bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> initialize() async {
    if (!isSupported) return;

    _messaging = FirebaseMessaging.instance;
    _localNotifications = FlutterLocalNotificationsPlugin();

    await _initializeFirebaseMessaging();
    await _initializeLocalNotifications();
  }

  Future<void> _initializeFirebaseMessaging() async {
    if (!isSupported) return;

    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM token
      String? token = await _messaging.getToken();
      if (token != null) {
        await _updateUserFCMToken(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_updateUserFCMToken);

      // Handle messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    }
  }

  Future<void> _initializeLocalNotifications() async {
    if (!isSupported) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              'tea_serve_channel',
              'Tea Serve Notifications',
              description: 'Notifications from Tea Serve app',
              importance: Importance.high,
            ),
          );
    }
  }

  Future<void> _updateUserFCMToken(String token) async {
    if (!isSupported) return;

    AppwriteService appwrite = AppwriteService();
    try {
      final currentUser = appwrite.account.get();
      await appwrite.databases.updateDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.usersCollectionId,
        documentId: (await currentUser).$id,
        data: {'fcmToken': token},
      );
    } catch (e) {
      debugPrint('Error updating FCM token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) async {
    if (!isSupported) return;
    await _showLocalNotification(message);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (!isSupported) return;

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'tea_serve_channel',
            'Tea Serve Notifications',
            channelDescription: 'Notifications from Tea Serve app',
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  void _handleNotificationTap(NotificationResponse response) {
    if (!isSupported) return;

    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      debugPrint('Notification tapped: $data');
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    if (!isSupported) return;
    debugPrint('App opened from notification: ${message.data}');
  }

  Future<void> showNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    if (!isSupported) return;

    const androidDetails = AndroidNotificationDetails(
      'tea_serve_channel',
      'Tea Serve Notifications',
      channelDescription: 'Notifications from Tea Serve app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload != null ? jsonEncode(payload) : null,
    );
  }

  Future<void> sendJanitorNotification(TeaOrder order) async {
    try {
      // Get all users with janitor role
      final janitors = await AppwriteService().databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.usersCollectionId,
        queries: [Query.equal('role', 'janitor')],
      );

      // Send notification to each janitor
      for (final janitor in janitors.documents) {
        final fcmToken = janitor.data['fcmToken'];
        if (fcmToken != null) {
          await AppwriteService().functions.createExecution(
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

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    debugPrint('Handling background message: ${message.messageId}');
    await NotificationService().showNotification(
      title: message.notification?.title ?? 'New Order',
      body: message.notification?.body ?? 'You have a new order to prepare',
      payload: message.data,
    );
  }
}
