import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Callback when notification is tapped
  static Function(String?)? onNotificationTap;

  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        onNotificationTap?.call(response.payload);
      },
    );

    // Request notification permission on Android 13+
    _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  /// Show a warning notification for detected phone number / VA
  static Future<void> showGuardianAlert({
    required String phoneNumber,
    String? lastFour,
  }) async {
    final last4 =
        lastFour ??
        (phoneNumber.length >= 4
            ? phoneNumber.substring(phoneNumber.length - 4)
            : phoneNumber);

    final androidDetails = AndroidNotificationDetails(
      'tampar_guardian',
      'TAMPAR Guardian',
      channelDescription: 'Clipboard Guardian alerts',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF7A5AFC),
      styleInformation: const BigTextStyleInformation(''),
      autoCancel: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(
      42, // notification ID
      '🔥 TAMPAR Guardian — Awas Impulsif!',
      'Nomor ...$last4 terdeteksi! Duit lu sisa tipis, yakin mau checkout? 💀',
      details,
      payload: phoneNumber,
    );
  }
}
