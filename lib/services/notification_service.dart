import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static bool _initialized = false;

  /// Initialize notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();
    
    // Set local timezone (Europe/Rome for Italy)
    final String timeZoneName = 'Europe/Rome';
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions (especially for iOS)
    if (!kIsWeb) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    _initialized = true;
    
    if (kDebugMode) {
      debugPrint('✅ NotificationService initialized');
    }
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      debugPrint('Notification tapped: ${response.payload}');
    }
    // TODO: Navigate to specific screen based on payload
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Cancel specific notification
  static Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  // ==================== DAILY REMINDERS ====================

  /// Schedule daily reminder at specific time
  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String userName,
  }) async {
    await _notifications.zonedSchedule(
      0, // Notification ID for daily reminder
      '🧠 Allenamento Cerebrale',
      'Ciao $userName! È ora di allenare il cervello con Brain Boost! 💪',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Promemoria Quotidiano',
          channelDescription: 'Promemoria per le sessioni di allenamento quotidiane',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    if (kDebugMode) {
      debugPrint('✅ Daily reminder scheduled at $hour:$minute');
    }
  }

  /// Cancel daily reminder
  static Future<void> cancelDailyReminder() async {
    await _notifications.cancel(0);
  }

  // ==================== ACHIEVEMENT CELEBRATIONS ====================

  /// Show level up celebration
  static Future<void> showLevelUpNotification(int newLevel) async {
    await _notifications.show(
      100, // Achievement notification base ID
      '🎉 Livello ${newLevel} Raggiunto!',
      'Complimenti! Hai raggiunto il livello $newLevel! Continua così! 🚀',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'achievements',
          'Celebrazioni Achievement',
          channelDescription: 'Notifiche per celebrare i tuoi successi',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Show badge earned celebration
  static Future<void> showBadgeEarnedNotification(String badgeName, String badgeDesc) async {
    await _notifications.show(
      101,
      '🏆 Badge Sbloccato!',
      '$badgeName: $badgeDesc',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'achievements',
          'Celebrazioni Achievement',
          channelDescription: 'Notifiche per celebrare i tuoi successi',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Show milestone reached celebration
  static Future<void> showMilestoneNotification(String milestone) async {
    await _notifications.show(
      102,
      '🎯 Traguardo Raggiunto!',
      milestone,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'achievements',
          'Celebrazioni Achievement',
          channelDescription: 'Notifiche per celebrare i tuoi successi',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ==================== STREAK ENCOURAGEMENT ====================

  /// Show streak milestone notification
  static Future<void> showStreakMilestoneNotification(int streakDays) async {
    String message;
    String emoji;

    if (streakDays >= 100) {
      message = '100 giorni di fila! Sei una leggenda! 🌟';
      emoji = '🏆';
    } else if (streakDays >= 50) {
      message = '50 giorni di fila! Incredibile costanza! 💎';
      emoji = '💎';
    } else if (streakDays >= 30) {
      message = '30 giorni di fila! Un mese intero! 🎊';
      emoji = '🎊';
    } else if (streakDays >= 14) {
      message = '14 giorni di fila! Due settimane! 🌟';
      emoji = '⭐';
    } else if (streakDays >= 7) {
      message = '7 giorni di fila! Una settimana completa! 🔥';
      emoji = '🔥';
    } else if (streakDays >= 3) {
      message = '$streakDays giorni di fila! Continua così! 💪';
      emoji = '💪';
    } else {
      return; // Don't notify for streaks < 3
    }

    await _notifications.show(
      200, // Streak notification ID
      '$emoji Streak di $streakDays Giorni!',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak',
          'Incoraggiamenti Streak',
          channelDescription: 'Notifiche motivazionali per mantenere la tua serie',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Show streak broken warning
  static Future<void> showStreakBrokenNotification(int lostStreak) async {
    await _notifications.show(
      201,
      '😢 Streak Interrotta',
      'Hai perso uno streak di $lostStreak giorni. Non mollare! Ricomincia oggi! 💪',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak',
          'Incoraggiamenti Streak',
          channelDescription: 'Notifiche motivazionali per mantenere la tua serie',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Show streak at risk warning (evening reminder if not trained today)
  static Future<void> showStreakAtRiskNotification(int currentStreak) async {
    await _notifications.show(
      202,
      '⚠️ Streak a Rischio!',
      'Non perdere il tuo streak di $currentStreak giorni! Gioca ora per mantenerlo! 🔥',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak',
          'Incoraggiamenti Streak',
          channelDescription: 'Notifiche motivazionali per mantenere la tua serie',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ==================== MOTIVATIONAL MESSAGES ====================

  /// Show motivational message after good performance
  static Future<void> showMotivationalNotification(String message) async {
    await _notifications.show(
      300,
      '💡 Brain Boost',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'motivation',
          'Messaggi Motivazionali',
          channelDescription: 'Messaggi per motivarti nel tuo percorso',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
        ),
      ),
    );
  }

  // ==================== HELPER METHODS ====================

  /// Calculate next instance of specific time
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the scheduled time is in the past, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    if (kIsWeb) return false;
    
    final androidImpl = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImpl != null) {
      return await androidImpl.areNotificationsEnabled() ?? false;
    }
    
    return true; // Assume enabled for iOS
  }
}
