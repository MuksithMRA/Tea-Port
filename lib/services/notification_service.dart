import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tea_port/services/appwrite_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/tea_order.dart';



class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseMessaging? _messaging;
  FlutterLocalNotificationsPlugin? _localNotifications;
  bool _isInitialized = false;

  bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> initialize() async {
    _messaging = FirebaseMessaging.instance;

    if (!kIsWeb) {
      if (!_isInitialized) {
        _localNotifications = FlutterLocalNotificationsPlugin();
        await _initializeLocalNotifications();
        _isInitialized = true;
      }
    }

    // Always try to initialize Firebase messaging and update token
    await _initializeFirebaseMessaging();
  }

  Future<void> _initializeFirebaseMessaging() async {
    if (_messaging == null) return;

    // Request permission
    NotificationSettings settings = await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM token
      String? token = await _messaging!.getToken();
      if (token != null) {
        await _updateUserFCMToken(token);
      }

      // Listen for token refresh
      _messaging!.onTokenRefresh.listen(_updateUserFCMToken);

      // Handle messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);
      }
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    }
  }

  Future<void> _initializeLocalNotifications() async {
    if (kIsWeb || _localNotifications == null) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _localNotifications!.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _localNotifications!
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              'tea_port_channel',
              'Tea Serve Notifications',
              description: 'Notifications from Tea Serve app',
              importance: Importance.high,
            ),
          );
    }
  }

  Future<void> _updateUserFCMToken(String token) async {
    AppwriteService appwrite = AppwriteService();
    try {
      final currentUser = await appwrite.account.get();
      
      // Get the current user document to check existing tokens
      final userDoc = await appwrite.databases.getDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.usersCollectionId,
        documentId: currentUser.$id,
      );

      // Get existing tokens or initialize empty list
      List<String> tokens = List<String>.from(userDoc.data['fcmTokens'] ?? []);

      // Add new token if it doesn't exist
      if (!tokens.contains(token)) {
        tokens.add(token);

        // Update the document with the new token list
        await appwrite.databases.updateDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.usersCollectionId,
          documentId: currentUser.$id,
          data: {'fcmTokens': tokens},
        );
      }

      // Store the current token locally for cleanup during sign out
      if (!kIsWeb) {
        await _storeCurrentToken(token);
      }
    } catch (e) {
      debugPrint('Error updating FCM tokens: $e');
    }
  }

  Future<void> _storeCurrentToken(String token) async {
    // Store the token for the current device
    if (!kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_fcm_token', token);
    }
  }

  Future<String?> getCurrentToken() async {
    if (!kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('current_fcm_token');
    }
    return null;
  }

  Future<void> removeCurrentToken() async {
    if (!isSupported) return;

    try {
      final token = await getCurrentToken();
      if (token == null) return;

      AppwriteService appwrite = AppwriteService();
      final currentUser = await appwrite.account.get();

      // Get current user document
      final userDoc = await appwrite.databases.getDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.usersCollectionId,
        documentId: currentUser.$id,
      );

      // Remove the token from the list
      List<String> tokens = List<String>.from(userDoc.data['fcmTokens'] ?? []);
      tokens.remove(token);

      // Update the document with the updated token list
      await appwrite.databases.updateDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.usersCollectionId,
        documentId: currentUser.$id,
        data: {'fcmTokens': tokens},
      );

      // Clear the stored token
      if (!kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('current_fcm_token');
      }
    } catch (e) {
      debugPrint('Error removing FCM token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) async {
    if (kIsWeb) {
      // For web, show a dialog
      if (message.notification != null) {
        showDialog(
          context: navkey.currentState!.context,
          builder: (context) => AlertDialog(
            title: Text(message.notification!.title ?? 'New Notification'),
            content: Text(message.notification!.body ?? ''),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else if (isSupported) {
      await _showLocalNotification(message);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (!isSupported) return;

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      await _localNotifications!.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'tea_port_channel',
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
      'tea_port_channel',
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

    await _localNotifications!.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload != null ? jsonEncode(payload) : null,
    );
  }

  Future<void> sendJanitorNotification(TeaOrder order) async {
    try {
      debugPrint('Sending janitor notification for order ${order.id}');
      // Get all users with janitor role
      final janitors = await AppwriteService().databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.usersCollectionId,
        queries: [Query.equal('role', 'janitor')],
      );

      // Send notification to each janitor
      for (final janitor in janitors.documents) {
        final tokens = List<String>.from(janitor.data['fcmTokens'] ?? []);
        debugPrint('Found FCM tokens for janitor: $tokens');
        
        for (final token in tokens) {
          try {
            await AppwriteService().functions.createExecution(
              functionId: 'sendPushNotification',
              body: json.encode({
                'token': token,
                'title': 'New Tea Order',
                'body':
                    'New ${order.drinkType.toString().split('.').last} order from ${order.userName}',
                'data': {
                  'orderId': order.id,
                  'type': 'new_order',
                },
              }),
            );
            debugPrint('Successfully sent notification to token: $token');
          } catch (e) {
            debugPrint('Error sending notification to token $token: $e');
            continue;
          }
        }
      }
    } catch (e) {
      debugPrint('Error sending janitor notification: $e');
    }
  }

  Future<void> sendOrderStatusNotification(TeaOrder order) async {
    try {
      // Get the employee who placed the order
      final employee = await AppwriteService().databases.getDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.usersCollectionId,
        documentId: order.userId,
      );

      final tokens = List<String>.from(employee.data['fcmTokens'] ?? []);
      if (tokens.isNotEmpty) {
        String statusMessage;
        switch (order.status) {
          case OrderStatus.pending:
            statusMessage = 'Your order has been received';
            break;
          case OrderStatus.preparing:
            statusMessage = 'Your drink is being prepared';
            break;
          case OrderStatus.cancelled:
            statusMessage = 'Your order has been cancelled';
            break;
          case OrderStatus.completed:
            statusMessage = 'Your drink is ready for pickup';
            break;
          default:
            statusMessage = 'Your order status has been updated';
        }

        for (final token in tokens) {
          try {
            await AppwriteService().functions.createExecution(
              functionId: 'sendPushNotification',
              body: json.encode({
                'token': token,
                'title': 'Order Update',
                'body': statusMessage,
                'data': {
                  'orderId': order.id,
                  'type': 'status_update',
                  'status': order.status.toString(),
                },
              }),
            );
            debugPrint('Successfully sent status update to token: $token');
          } catch (e) {
            debugPrint('Error sending status update to token $token: $e');
            continue;
          }
        }
      }
    } catch (e) {
      debugPrint('Error sending order status notification: $e');
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
