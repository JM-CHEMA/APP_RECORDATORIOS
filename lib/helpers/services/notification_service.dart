import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Única puerta de entrada a las notificaciones programadas en el dispositivo.
class LocalNotificationService {
  LocalNotificationService._();
  static final instance = LocalNotificationService._();
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    // El paquete timezone no conoce automáticamente la zona del teléfono.
    tzdata.initializeTimeZones();
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await initialize();
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _plugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ?? true;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ?? true;
    }
    return true;
  }

  /// ID persistente: no utilizar String.hashCode (puede variar entre ejecuciones).
  int notificationId(String uid, String reminderId) {
    var hash = 0x811c9dc5;
    for (final unit in '$uid/$reminderId'.codeUnits) {
      hash = (hash ^ unit) * 0x01000193 & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }

  Future<void> schedule({
    required String uid,
    required String reminderId,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    if (!scheduledAt.isAfter(DateTime.now())) {
      throw ArgumentError('La fecha del recordatorio debe ser futura.');
    }
    await initialize();
    await _plugin.zonedSchedule(
      id: notificationId(uid, reminderId),
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledAt, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'frepy_reminders',
          'Recordatorios',
          channelDescription: 'Avisos de recordatorios programados',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // No exige permiso de alarmas exactas en Android 14+.
      // La entrega es aproximada y puede retrasarse por ahorro de batería.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancel(String uid, String reminderId) async {
    await initialize();
    await _plugin.cancel(id: notificationId(uid, reminderId));
  }

  /// Evita que avisos de otra cuenta sigan activos al cambiar de usuario.
  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }
}
