import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../models/habit.dart';
import '../../models/habit_with_today_status.dart';

/// 스마트 로컬 푸시 알림 서비스
/// - 기기 로컬 타임존(Asia/Seoul 등) 완벽 매핑으로 1초 오차 없는 정시 알림
/// - 오늘 이미 완료된 습관은 오늘 남은 알림을 자동 스킵하고 다음 날부터 발송
/// - 완료 취소 시 오늘 남은 알림 즉시 복원
/// - 주간 시간대(09:00~21:00) 지정 간격 타임 슬롯 스케줄링으로 야간 수면 방해 방지
/// - 설정 화면 전체 알림 ON/OFF 및 앱 기동 시 일괄 동기화 지원
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'three_sec_habit_reminders';
  static const String channelName = '습관 실천 알림';
  static const String channelDesc = '설정된 시간과 간격에 맞춰 습관 실천을 알립니다.';
  static const String prefAllNotificationsKey = 'all_notifications_enabled';

  /// 알림 서비스 초기화 및 타임존 설정
  static Future<void> initialize() async {
    tz.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final String currentTimeZone = timezoneInfo.identifier;
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
      debugPrint('⏰ [NotificationService] Timezone configured to: $currentTimeZone');
    } catch (e) {
      debugPrint('⏰ [NotificationService] Failed to set native timezone, fallback: $e');
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

  /// 전체 알림 허용 여부 확인
  static Future<bool> isAllNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefAllNotificationsKey) ?? true;
  }

  /// 전체 알림 ON/OFF 설정 및 즉시 반영
  static Future<void> setAllNotificationsEnabled(
    bool enabled,
    List<HabitWithTodayStatus> habits,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefAllNotificationsKey, enabled);

    if (!enabled) {
      await cancelAll();
    } else {
      await rescheduleAllHabits(habits);
    }
  }

  /// 모든 활성 습관의 알림 일괄 재동기화 (앱 기동 시 또는 전체 알림 ON 시 호출)
  static Future<void> rescheduleAllHabits(
    List<HabitWithTodayStatus> habits,
  ) async {
    final isGlobalEnabled = await isAllNotificationsEnabled();
    if (!isGlobalEnabled) {
      await cancelAll();
      return;
    }

    for (final item in habits) {
      if (item.habit.reminderEnabled && !item.habit.isArchived) {
        await scheduleHabitReminder(
          item.habit,
          isCompletedToday: item.isCompletedToday,
        );
      } else if (item.habit.id != null) {
        await cancelHabitReminder(item.habit.id!);
      }
    }
    debugPrint('⚡ [NotificationService] All ${habits.length} habits rescheduled successfully.');
  }

  /// 개별 습관 알림 스마트 스케줄링 등록 / 갱신
  /// [isCompletedToday]가 true이면 오늘의 알림을 스킵하고 내일부터 울리도록 스마트 예약합니다.
  static Future<void> scheduleHabitReminder(
    Habit habit, {
    bool isCompletedToday = false,
  }) async {
    if (habit.id == null) return;
    await cancelHabitReminder(habit.id!);

    final isGlobalEnabled = await isAllNotificationsEnabled();
    if (!isGlobalEnabled || !habit.reminderEnabled || habit.isArchived) return;

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
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
        ),
      );

      final now = tz.TZDateTime.now(tz.local);

      if (habit.reminderType == ReminderType.fixed &&
          habit.reminderTime != null) {
        // ==========================================
        // 1. 지정 시각 알림 (오늘 완료 여부에 따른 스마트 스케줄링)
        // ==========================================
        final parts = habit.reminderTime!.split(':');
        if (parts.length >= 2) {
          final hour = int.tryParse(parts[0]) ?? 8;
          final minute = int.tryParse(parts[1]) ?? 0;

          var scheduledDate =
              tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

          if (isCompletedToday || scheduledDate.isBefore(now)) {
            scheduledDate = scheduledDate.add(const Duration(days: 1));
          }

          // 특정 요일 반복인 경우 유효한 다음 요일로 이동
          if (habit.repeatType == RepeatType.weeklyDays &&
              habit.repeatDays.isNotEmpty) {
            while (!habit.repeatDays.contains(scheduledDate.weekday)) {
              scheduledDate = scheduledDate.add(const Duration(days: 1));
            }
          }

          final notifId = _generateNotificationId(habit.id!, 0);
          await _notificationsPlugin.zonedSchedule(
            id: notifId,
            title: title,
            body: body,
            scheduledDate: scheduledDate,
            notificationDetails: notificationDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: (habit.repeatType == RepeatType.weeklyDays)
                ? DateTimeComponents.dayOfWeekAndTime
                : DateTimeComponents.time,
            payload: 'habit_${habit.id}',
          );
        }
      } else if (habit.reminderType == ReminderType.interval) {
        // ==========================================
        // 2. 주기적 반복 간격 알림 (주간 윈도우 슬롯 스케줄링)
        // 시작시간~종료시간 사이에만 울려 야간 수면을 완벽 보호
        // ==========================================
        final startParts = (habit.reminderStartTime ?? '09:00').split(':');
        final endParts = (habit.reminderEndTime ?? '21:00').split(':');

        final startHour = int.tryParse(startParts[0]) ?? 9;
        final startMinute =
            int.tryParse(startParts.length > 1 ? startParts[1] : '0') ?? 0;

        final endHour = int.tryParse(endParts[0]) ?? 21;
        final endMinute =
            int.tryParse(endParts.length > 1 ? endParts[1] : '0') ?? 0;

        final intervalMinutes = (habit.reminderIntervalMinutes ?? 60).clamp(15, 720);

        final startTotalMin = startHour * 60 + startMinute;
        final endTotalMin = endHour * 60 + endMinute;

        if (endTotalMin > startTotalMin) {
          int currentSlotMin = startTotalMin;
          int subId = 0;

          while (currentSlotMin <= endTotalMin && subId < 25) {
            final slotHour = currentSlotMin ~/ 60;
            final slotMin = currentSlotMin % 60;

            var scheduledDate = tz.TZDateTime(
              tz.local,
              now.year,
              now.month,
              now.day,
              slotHour,
              slotMin,
            );

            if (isCompletedToday || scheduledDate.isBefore(now)) {
              scheduledDate = scheduledDate.add(const Duration(days: 1));
            }

            // 특정 요일 반복인 경우 유효한 요일로 이동
            if (habit.repeatType == RepeatType.weeklyDays &&
                habit.repeatDays.isNotEmpty) {
              while (!habit.repeatDays.contains(scheduledDate.weekday)) {
                scheduledDate = scheduledDate.add(const Duration(days: 1));
              }
            }

            final notifId = _generateNotificationId(habit.id!, subId);
            await _notificationsPlugin.zonedSchedule(
              id: notifId,
              title: title,
              body: body,
              scheduledDate: scheduledDate,
              notificationDetails: notificationDetails,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              matchDateTimeComponents:
                  (habit.repeatType == RepeatType.weeklyDays)
                      ? DateTimeComponents.dayOfWeekAndTime
                      : DateTimeComponents.time,
              payload: 'habit_${habit.id}_slot_$subId',
            );

            subId++;
            currentSlotMin += intervalMinutes;
          }
        }
      }
    } catch (e) {
      debugPrint('Error scheduling smart habit reminder: $e');
    }
  }

  /// 습관 알림 취소 (최대 25개 서브 ID 슬롯 일괄 취소)
  static Future<void> cancelHabitReminder(int habitId) async {
    try {
      for (int subId = 0; subId < 25; subId++) {
        final notifId = _generateNotificationId(habitId, subId);
        await _notificationsPlugin.cancel(id: notifId);
      }
    } catch (e) {
      debugPrint('Error cancelling notification for habit $habitId: $e');
    }
  }

  /// 전체 알림 일괄 취소
  static Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('⚡ [NotificationService] All notifications cancelled.');
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }

  /// 테스트 즉시 알림 발송 (상단바 확인용)
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
