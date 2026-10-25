import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:to_do_app/features/tasks/data/task_model.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'tasks_channel',
      'Task Reminders',
      channelDescription: 'Reminders for your tasks',
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    await requestPermissions();
  }

  Future<void> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  DateTime? _scheduledDateTime(TaskModel task) {
    if (task.date == null || task.time == null) return null;
    return DateTime(
      task.date!.year,
      task.date!.month,
      task.date!.day,
      task.time!.hour,
      task.time!.minute,
    );
  }

  /// بيجدول إشعار للـ task (لو pending ووقتها في المستقبل).
  /// بيلغي القديم الأول، فتقدر تناديه عند الإضافة أو التعديل.
  Future<void> schedule(TaskModel task) async {
    if (task.id == null) return;
    await cancel(task.id!);

    if (task.status == Status.completed) return;

    final when = _scheduledDateTime(task);
    if (when == null || !when.isAfter(DateTime.now())) return;

    final scheduledDate = tz.TZDateTime.from(when, tz.local);
    final body = (task.description != null && task.description!.isNotEmpty)
        ? task.description
        : 'It\'s time for your task';

    try {
      await _plugin.zonedSchedule(
        id: task.id!,
        title: task.title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      // لو إذن الميعاد الدقيق مش متاح، نجدول بميعاد تقريبي بدل ما نفشل
      await _plugin.zonedSchedule(
        id: task.id!,
        title: task.title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }
}