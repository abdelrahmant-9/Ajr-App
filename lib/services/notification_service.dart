import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  FlutterLocalNotificationsPlugin get plugin => _plugin;

  static const int _dailyReminderId = 1;

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
    } catch (e) {
      debugPrint('TimeZone error: $e');
    }

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  /// الحصول على قائمة الإشعارات المجدولة التي لم تظهر بعد
  Future<List<PendingNotificationRequest>> pendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }

  /// Schedule a daily notification at the given [time].
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    // تنظيف الكل قبل الجدولة الجديدة لضمان عدم وجود تكرار
    await cancelDailyReminder();

    // حفظ الوقت في SharedPreferences للرجوع إليه في الداشبورد
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_hour', time.hour);
    await prefs.setInt('reminder_minute', time.minute);

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year, now.month, now.day,
      time.hour, time.minute, 0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'ajr_alarm_channel_v4',
      'تنبيهات أجر المنبهة',
      channelDescription: 'تذكير يومي بأذكار التسبيح بصيغة منبه',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      playSound: true,
    );

    await _plugin.zonedSchedule(
      _dailyReminderId,
      '🤲 وقت الأذكار',
      'لا تنسَ ذكر الله — اضغط للبدء',
      tzScheduled,
      const NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails()),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// إرسال تنبيه تجريبي فوراً
  Future<void> sendTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'ajr_test_channel_v4',
      'تجربة التنبيهات',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
    );

    await _plugin.show(
      99,
      '🔔 تجربة التنبيه',
      'إذا ظهر لك هذا، فالأذونات سليمة!',
      const NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails()),
    );
  }

  /// مسح كافة الإشعارات المجدولة والظاهرة
  Future<void> cancelDailyReminder() async {
    await _plugin.cancelAll(); // 🔥 مسح الكل لضمان تصفير الـ Pending
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('reminder_hour');
    await prefs.remove('reminder_minute');
  }
}
