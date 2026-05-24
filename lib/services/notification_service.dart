import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'database_service.dart';

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance = NotificationService._privateConstructor();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initializes local notifications and configures timezone database.
  Future<void> init() async {
    if (_initialized) return;

    try {
      // 1. Initialize timezone database
      tz.initializeTimeZones();
      // Safe fallback for local location if platform channel isn't available
      try {
        final String timeZoneName = 'Asia/Jakarta'; // Default matching local time UTC+7
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        if (kDebugMode) print('TimeZone initialization warning: $e');
      }

      // 2. Android Initialization Settings
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');

      // 3. iOS Initialization Settings
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      // 4. Combine Settings
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // 5. Initialize plugin
      await _notificationsPlugin.initialize(
        settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (kDebugMode) {
            print('Notification clicked: ${response.payload}');
          }
        },
      );

      _initialized = true;
      if (kDebugMode) print('NotificationService initialized successfully.');
    } catch (e) {
      if (kDebugMode) print('Error initializing NotificationService: $e');
    }
  }

  /// Requests permissions on Android 13+ and iOS.
  Future<bool> requestPermissions() async {
    try {
      final bool? iosGranted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      final bool? androidGranted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      return (iosGranted ?? false) || (androidGranted ?? false);
    } catch (e) {
      if (kDebugMode) print('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Sends an instant notification (useful for testing and instant feedback).
  Future<void> sendInstantNotification(String title, String body) async {
    if (!_initialized) await init();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'instant_channel',
      'Notifikasi Instan',
      channelDescription: 'Saluran untuk notifikasi langsung',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      999, // Unique ID for instant notifications
      title,
      body,
      details,
    );
  }

  /// Schedules (or updates) a daily smart reminder notification at 8:00 PM.
  Future<void> scheduleSmartReminder(int pendingTasksCount) async {
    if (!_initialized) await init();

    // Check if user has enabled notifications in settings
    final isEnabled = await isNotificationsEnabled();
    if (!isEnabled) {
      // Cancel any existing scheduled reminder
      await _notificationsPlugin.cancel(100);
      if (kDebugMode) print('Notifications disabled. Cancelled scheduled reminder.');
      return;
    }

    try {
      // Set target time: today at 8:00 PM (20:00)
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        20, // 8 PM
        0,  // 00 minutes
        0,  // 00 seconds
      );

      // If 8:00 PM has already passed today, schedule it for tomorrow at 8:00 PM
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Configure Dynamic Teks & Title based on pending tasks
      String title;
      String body;

      if (pendingTasksCount > 0) {
        title = 'Tugas Belum Selesai';
        body = 'Hey Adrian! Sudah jam 8 malam nih, tapi ada $pendingTasksCount tugas utama kamu yang belum selesai. Selesaikan sekarang yuk, jangan ditunda-tunda terus!';
      } else {
        title = 'Luar Biasa';
        body = 'Hebat sekali Adrian! Semua tugas harianmu hari ini sudah selesai dikerjakan. Selamat beristirahat malam!';
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'smart_reminder_channel',
        'Pengingat Pintar',
        channelDescription: 'Mengingatkan tugas harian Anda pada jam 8 malam',
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Cancel old schedule first to avoid duplicates
      await _notificationsPlugin.cancel(100);

      // Schedule timezone-aware notification
      await _notificationsPlugin.zonedSchedule(
        100, // Unique ID for smart reminder
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at the same time
      );

      if (kDebugMode) {
        print('Smart Reminder scheduled at $scheduledDate (Pending Tasks: $pendingTasksCount)');
      }
    } catch (e) {
      if (kDebugMode) print('Error scheduling smart reminder: $e');
    }
  }

  /// Cancels any scheduled smart reminders.
  Future<void> cancelSmartReminder() async {
    await _notificationsPlugin.cancel(100);
  }

  /// Checks if notifications are enabled in settings.
  Future<bool> isNotificationsEnabled() async {
    try {
      final val = await DatabaseService.instance.fetchSessionValue('notifications_enabled');
      // Default to true (1) if never set before, to encourage productivity
      return val != '0';
    } catch (e) {
      return true;
    }
  }

  /// Saves the user's preference for notifications.
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      await DatabaseService.instance.saveSessionValue(
        'notifications_enabled',
        enabled ? '1' : '0',
      );
    } catch (e) {
      if (kDebugMode) print('Error saving notifications preference: $e');
    }
  }
}
