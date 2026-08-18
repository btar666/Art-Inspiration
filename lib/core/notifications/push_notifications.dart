import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';
import 'notification_payload.dart';

/// معالج الإشعارات عندما يكون التطبيق في الخلفية أو مغلقاً
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('FCM background: ${message.messageId}');
}

/// تهيئة Firebase Cloud Messaging + إشعارات محلية للعرض في المقدمة
class PushNotifications {
  PushNotifications._();

  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  /// يُستدعى عند وصول إشعار في المقدمة — لتحديث قائمة الإشعارات
  static void Function()? onForegroundMessage;

  static void Function(Map<String, dynamic> data)? _onNotificationTap;
  static String? _pendingProductId;

  static void Function(Map<String, dynamic> data)? get onNotificationTap =>
      _onNotificationTap;

  static set onNotificationTap(
    void Function(Map<String, dynamic> data)? callback,
  ) {
    _onNotificationTap = callback;
  }

  static String? get pendingProductId => _pendingProductId;

  static set pendingProductId(String? value) {
    _pendingProductId = value;
  }

  static String? takePendingProductId() {
    final id = _pendingProductId;
    _pendingProductId = null;
    return id;
  }

  static StreamSubscription<RemoteMessage>? _onMessageSub;
  static StreamSubscription<RemoteMessage>? _onOpenedSub;
  static bool _initialized = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'art_inspiration_default',
    'إشعارات إلهام الفن',
    description: 'إشعارات التطبيق العامة',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _local.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    final androidPlugin = _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);
    await androidPlugin?.requestNotificationsPermission();

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    await messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );

    await _onMessageSub?.cancel();
    await _onOpenedSub?.cancel();
    _onMessageSub =
        FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    _onOpenedSub =
        FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessage);

    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      _rememberOrDispatch(initial.data);
    }

    await _handleLaunchFromLocalNotification();

    final token = await messaging.getToken();
    debugPrint('FCM token: $token');

    try {
      await messaging.subscribeToTopic('notification-public');
      await messaging.unsubscribeFromTopic('notification-offers');
      debugPrint('FCM subscribed to topic: notification-public');
    } catch (error) {
      debugPrint('FCM topic subscribe failed: $error');
    }
  }

  static void _onLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    try {
      final data = jsonDecode(payload);
      if (data is Map) {
        _rememberOrDispatch(Map<String, dynamic>.from(data));
      }
    } catch (_) {}
  }

  static Future<void> _handleLaunchFromLocalNotification() async {
    final details = await _local.getNotificationAppLaunchDetails();
    final payload = details?.notificationResponse?.payload;
    if (details == null ||
        !details.didNotificationLaunchApp ||
        payload == null ||
        payload.isEmpty) {
      return;
    }

    try {
      final data = jsonDecode(payload);
      if (data is Map) {
        _rememberOrDispatch(Map<String, dynamic>.from(data));
      }
    } catch (_) {}
  }

  static void _handleRemoteMessage(RemoteMessage message) {
    _rememberOrDispatch(message.data);
  }

  static void _rememberOrDispatch(Map<String, dynamic> data) {
    final itemId = NotificationPayload.itemIdFrom(data);
    if (itemId != null) {
      _pendingProductId = itemId;
    }

    final tap = _onNotificationTap;
    if (tap != null) {
      tap(data);
      return;
    }
  }

  static void _showForegroundNotification(RemoteMessage message) {
    debugPrint(
      'FCM foreground: ${message.messageId} '
      'title=${message.notification?.title} data=${message.data}',
    );

    onForegroundMessage?.call();

    // في الخلفية النظام يعرض إشعار FCM — لا نكرر محلياً
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle != null && lifecycle != AppLifecycleState.resumed) {
      return;
    }

    final title = message.notification?.title ??
        message.data['title'] ??
        message.data['subject'];
    final body = message.notification?.body ??
        message.data['body'] ??
        message.data['message'];
    if (title == null && body == null) return;

    _local.show(
      id: message.hashCode.abs().clamp(1, 2147483647),
      title: title,
      body: body,
      payload: message.data.isEmpty ? null : jsonEncode(message.data),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
