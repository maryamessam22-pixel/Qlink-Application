import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show RealtimeChannel, PostgresChangeEvent, PostgresChangeFilter, PostgresChangeFilterType;
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/services/supabase_service.dart';

/// Handles background FCM messages (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(const InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  ));
  await plugin.show(
    message.hashCode,
    message.notification?.title ?? 'QLink',
    message.notification?.body ?? '',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'qlink_channel', 'QLink Notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
  );
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  FirebaseMessaging? _fcm;

  RealtimeChannel? _realtimeChannel;

  Future<void> initialize() async {
    if (kIsWeb) return;

    _fcm ??= FirebaseMessaging.instance;

    // ── Local notifications setup ──
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    await _fcm!.requestPermission(alert: true, badge: true, sound: true);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(
        title: message.notification?.title ?? 'QLink',
        body: message.notification?.body ?? '',
      );
      AppState().incrementUnreadNotifications();
    });

    final token = await _fcm!.getToken();
    debugPrint('[FCM] Token: $token');
    if (token != null) await _saveFcmToken(token);
    _fcm!.onTokenRefresh.listen(_saveFcmToken);
  }

  Future<void> _saveFcmToken(String token) async {
    final userId = SupabaseService().client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await SupabaseService().client.from('user_fcm_tokens').upsert({
        'guardian_id': userId,
        'token': token,
        'platform': 'android',
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'guardian_id');
    } catch (e) {
      debugPrint('[FCM] Token save error: $e');
    }
  }

  /// Call after user logs in
  void startRealtimeListener() {
    final userId = SupabaseService().client.auth.currentUser?.id;
    if (userId == null) return;

    _loadUnreadCount(userId);

    _realtimeChannel = SupabaseService()
        .client
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'guardian_id',
            value: userId,
          ),
          callback: (payload) {
            final newRow = payload.newRecord;
            _showLocalNotification(
              title: newRow['title'] ?? 'QLink',
              body: newRow['body'] ?? '',
            );
            AppState().incrementUnreadNotifications();
          },
        )
        .subscribe();
  }

  Future<void> _loadUnreadCount(String userId) async {
    try {
      final response = await SupabaseService()
          .client
          .from('notifications')
          .select()
          .eq('guardian_id', userId)
          .eq('is_read', false);
      AppState().setUnreadNotificationCount((response as List).length);
    } catch (e) {
      debugPrint('[Notifications] Load error: $e');
    }
  }

  Future<void> markAllRead() async {
    final userId = SupabaseService().client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await SupabaseService()
          .client
          .from('notifications')
          .update({'is_read': true})
          .eq('guardian_id', userId)
          .eq('is_read', false);
      AppState().clearUnreadNotifications();
    } catch (e) {
      debugPrint('[Notifications] Mark read error: $e');
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'qlink_channel',
          'QLink Notifications',
          channelDescription: 'QLink real-time alerts',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  void stopRealtimeListener() {
    _realtimeChannel?.unsubscribe();
    _realtimeChannel = null;
  }
}
