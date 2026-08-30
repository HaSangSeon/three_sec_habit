import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../models/habit.dart';

/// 로컬 푸시 알림 서비스 (고정 시각 및 주기적 반복 알림 지원)
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'three_sec_habit_reminders';
  static const String channelName = '습관 실천 알림';
  static const String channelDesc = '설정된 시간과 간격에 맞춰 습관 실천을 알립니다.';

  /// 알림 서비스 초기화
  static Future<void> initialize() async {
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

    try {
      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification tapped: ${details.payload}');
        },
      );

      // 안드로이드 알림 채널 등록
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        await androidPlatform.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDesc,
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        );
        await androidPlatform.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('NotificationService initialize error: $e');
    }
  }

  /// 습관 알림 스케줄링 등록 / 갱신
  static Future<void> scheduleHabitReminder(Habit habit) async {
    if (habit.id == null) return;
    await cancelHabitReminder(habit.id!);

    if (!habit.reminderEnabled) return;

    try {
      final title = habit.title;
      final body = habit.habitType == HabitType.count
          ? '💧 [$title] 실천할 시간이에요! 오늘의 목표(${habit.targetCount}${habit.unit})를 달성해보세요.'
          : '⚡ [$title] 실천할 시간이에요! 3초 만에 완료해보세요.';

      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
        ),
      );

      if (habit.reminderType == ReminderType.fixed &&
          habit.reminderTime != null) {
        // 1. 고정 시간 알림
        final notifId = _generateNotificationId(habit.id!, 0);
        await _notificationsPlugin.periodicallyShow(
          id: notifId,
          title: title,
          body: body,
          repeatInterval: RepeatInterval.daily,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: 'habit_${habit.id}',
        );
      } else if (habit.reminderType == ReminderType.interval) {
        // 2. 주기적 반복 알림 (간격 알림)
        final intervalMinutes = habit.reminderIntervalMinutes ?? 60;
        final interval = intervalMinutes <= 60
            ? RepeatInterval.hourly
            : RepeatInterval.daily;

        final notifId = _generateNotificationId(habit.id!, 1);
        await _notificationsPlugin.periodicallyShow(
          id: notifId,
          title: title,
          body: body,
          repeatInterval: interval,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: 'habit_${habit.id}',
        );
      }
    } catch (e) {
      debugPrint('Error scheduling habit reminder: $e');
    }
  }

  /// 습관 알림 취소 (최대 10개 서브 ID 일괄 취소)
  static Future<void> cancelHabitReminder(int habitId) async {
    try {
      for (int subId = 0; subId < 10; subId++) {
        final notifId = _generateNotificationId(habitId, subId);
        await _notificationsPlugin.cancel(id: notifId);
      }
    } catch (e) {
      debugPrint('Error cancelling notification for habit $habitId: $e');
    }
  }

  /// 전체 알림 취소
  static Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }

  /// 테스트 즉시 알림 발송
  static Future<void> showTestNotification({
    String title = '⚡ [3초 습관] 테스트 알림',
    String body = '알림이 정상적으로 작동하고 있습니다! 체크 한 번, 3초 컷 ⚡️',
  }) async {
    try {
      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDesc,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
        ),
      );

      await _notificationsPlugin.show(
        id: 999999,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: 'test_notification',
      );
    } catch (e) {
      debugPrint('Error showing test notification: $e');
    }
  }

  /// 고유 Notification ID 생성 (습관 ID * 100 + subId)
  static int _generateNotificationId(int habitId, int subId) {
    return (habitId * 100 + subId).abs() % 2147483647;
  }
}
