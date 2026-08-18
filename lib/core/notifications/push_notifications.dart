import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';
import 'notification_payload.dart';
import 'pending_product_store.dart';

/// معالج الإشعارات عندما يكون التطبيق في الخلفية أو مغلقاً
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await PushNotifications.handleIncomingMessage(
    message,
    fromBackground: true,
  );
}

/// تهيئة Firebase Cloud Messaging + إشعار واحد قابل للفتح للمنتج
class PushNotifications {
  PushNotifications._();

  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static void Function()? onForegroundMessage;
  static void Function(Map<String, dynamic> data)? _onNotificationTap;
  static String? _pendingProductId;
  static StreamSubscription<RemoteMessage>? _onMessageSub;
  static StreamSubscription<RemoteMessage>? _onOpenedSub;
  static bool _initialized = false;
  static bool _localReady = false;

  static const _collapsedNotificationId = 71001;

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

  static Future<String?> takePendingProductId() async {
    final memory = _pendingProductId;
    _pendingProductId = null;
    if (memory != null && memory.isNotEmpty) {
      await PendingProductStore.take();
      return memory;
    }
    return PendingProductStore.take();
  }

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
    await _ensureLocalReady();

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    await messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );

    await _onMessageSub?.cancel();
    await _onOpenedSub?.cancel();
    _onMessageSub = FirebaseMessaging.onMessage.listen((message) {
      onForegroundMessage?.call();
      handleIncomingMessage(message);
    });
    _onOpenedSub =
        FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessage);

    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      await _handleRemoteMessage(initial);
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

  static Future<void> _ensureLocalReady() async {
    if (_localReady) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _local.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _localReady = true;
  }

  static Map<String, dynamic> _mapFromMessage(RemoteMessage message) {
    return {
      ...message.data,
      if (message.notification?.title != null)
        'title': message.notification!.title,
      if (message.notification?.body != null) 'body': message.notification!.body,
    };
  }

  static Future<void> handleIncomingMessage(
    RemoteMessage message, {
    bool fromBackground = false,
  }) async {
    debugPrint(
      'FCM incoming bg=$fromBackground data=${message.data} '
      'title=${message.notification?.title}',
    );

    final data = _mapFromMessage(message);
    var itemId = NotificationPayload.itemIdFrom(data);
    if (itemId != null) {
      _pendingProductId = itemId;
      await PendingProductStore.save(itemId);
    } else {
      itemId = await PendingProductStore.peek();
      if (itemId != null) {
        data['item_id'] = itemId;
        _pendingProductId = itemId;
      }
    }

    // في الخلفية أندرويد يعرض إشعار FCM تلقائياً إن وُجد حقل notification.
    // إشعار محلي إضافي هنا هو سبب ظهور إشعارين: الأول بدون item_id والثاني معه.
    if (fromBackground && message.notification != null) {
      debugPrint('FCM skip local duplicate; saved item_id=$itemId');
      return;
    }

    await _ensureLocalReady();
    await _showCollapsedNotification(message, data);
  }

  static Future<void> _showCollapsedNotification(
    RemoteMessage message,
    Map<String, dynamic> data,
  ) async {
    final title = message.notification?.title ??
        message.data['title'] ??
        message.data['subject'] ??
        'إشعار';
    final body = message.notification?.body ??
        message.data['body'] ??
        message.data['message'] ??
        '';

    await _local.show(
      id: _collapsedNotificationId,
      title: title,
      body: body,
      payload: jsonEncode(data),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: '@mipmap/ic_launcher',
          tag: 'art_inspiration_fcm',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  static void _onLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      _rememberOrDispatch({});
      return;
    }
    try {
      final data = jsonDecode(payload);
      if (data is Map) {
        _rememberOrDispatch(Map<String, dynamic>.from(data));
        return;
      }
    } catch (_) {}
    _rememberOrDispatch({});
  }

  static Future<void> _handleLaunchFromLocalNotification() async {
    final details = await _local.getNotificationAppLaunchDetails();
    final payload = details?.notificationResponse?.payload;
    if (details == null || !details.didNotificationLaunchApp) return;

    if (payload == null || payload.isEmpty) {
      await _rememberOrDispatch({});
      return;
    }

    try {
      final data = jsonDecode(payload);
      if (data is Map) {
        await _rememberOrDispatch(Map<String, dynamic>.from(data));
        return;
      }
    } catch (_) {}
    await _rememberOrDispatch({});
  }

  static Future<void> _handleRemoteMessage(RemoteMessage message) async {
    debugPrint('FCM opened: data=${message.data}');
    await _rememberOrDispatch(_mapFromMessage(message));
  }

  static Future<void> _rememberOrDispatch(Map<String, dynamic> data) async {
    var itemId = NotificationPayload.itemIdFrom(data);
    if (itemId != null) {
      _pendingProductId = itemId;
      await PendingProductStore.save(itemId);
    } else {
      itemId = await PendingProductStore.peek();
      if (itemId != null) {
        data = {...data, 'item_id': itemId};
        _pendingProductId = itemId;
      }
    }

    debugPrint('FCM item_id=$itemId data=$data');
    _onNotificationTap?.call(data);
  }
}
