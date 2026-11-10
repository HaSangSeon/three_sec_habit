import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../models/habit.dart';
import '../../models/habit_with_today_status.dart';

/// 스마트 로컬 푸시 알림 서비스
/// - 기기 로컬 타임존(Asia/Seoul 등) 매핑 기반 정시 알림 스케줄링
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

  static const String channelId = 'three_sec_habit_reminders_v2';
  static const String channelName = '습관 실천 알림';
  static const String channelDesc = '설정된 시간과 간격에 맞춰 습관 실천을 알립니다.';
  static const String prefAllNotificationsKey = 'all_notifications_enabled';

  /// 알림 탭 시 해당 습관으로 직행하기 위한 전역 노티파이어
  static final ValueNotifier<int?> notificationTappedHabitId = ValueNotifier<int?>(null);

  /// 알람 예약 상한(450개) 초과 시 UI 안내를 위한 노티파이어
  static final ValueNotifier<bool> alarmLimitExceededNotifier = ValueNotifier<bool>(false);
  static bool get isAlarmLimitExceeded => alarmLimitExceededNotifier.value;

  static bool _isTimezoneInitialized = false;
  static bool _isRescheduling = false;
  static List<HabitWithTodayStatus>? _pendingRescheduleHabits;

  /// 비동기 재예약 도중 전체 알림 OFF 등 취소 명령과의 경쟁 상태(Race Condition) 방지용 세대 카운터
  static int _scheduleGeneration = 0;
  static bool _globalNotificationsEnabledCache = true;

  /// 오늘/이번 주 완료 스킵 구간 경과 후 반복 플래그로 자동 전환하기 위한 타이머 및 상태 캐시
  static Timer? _rolloverResyncTimer;
  static tz.TZDateTime? _nextRolloverTime;
  static List<HabitWithTodayStatus>? _lastScheduledHabitsSnapshot;
  static final Map<int, ({Habit habit, bool isCompletedToday, bool isWeeklyCompleted})>
      _individualScheduledHabits = {};

  /// 타임존 안전 초기화 및 갱신 (메인 앱 및 백그라운드 Isolate 공통, 시간대 변경 대응)
  static Future<void> _ensureTimezoneInitialized({bool forceRefresh = false}) async {
    if (!_isTimezoneInitialized) {
      tz.initializeTimeZones();
    }
    if (_isTimezoneInitialized && !forceRefresh) return;
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final String currentTimeZone = timezoneInfo.identifier;
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
      _isTimezoneInitialized = true;
      debugPrint('⏰ [NotificationService] Timezone configured to: $currentTimeZone');
    } catch (e) {
      if (!_isTimezoneInitialized) {
        debugPrint('⏰ [NotificationService] Fallback timezone to Asia/Seoul: $e');
        try {
          tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
          _isTimezoneInitialized = true;
        } catch (_) {}
      }
    }
  }

  /// 기기 시간대(Timezone) 변경 감지를 위한 수동 갱신
  static Future<void> refreshTimezone() async {
    await _ensureTimezoneInitialized(forceRefresh: true);
  }

  /// 메인 앱 기동 시 알림 서비스 초기화
  static Future<void> initialize({bool requestPermissionOnStart = false}) async {
    await _ensureTimezoneInitialized();

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
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
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          debugPrint('🔔 [NotificationService] onDidReceiveNotificationResponse: ${details.payload}');
          if (details.payload != null) {
            _handleNotificationPayload(details.payload!);
          }
        },
      );

      // 콜드 스타트 (앱이 꺼진 상태에서 알림 터치로 앱 기동) 감지 및 화면 이동 연결
      final launchDetails = await _notificationsPlugin.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp == true &&
          launchDetails?.notificationResponse?.payload != null) {
        _handleNotificationPayload(launchDetails!.notificationResponse!.payload!);
      }

      // 안드로이드 알림 채널 등록 (헤드업 팝업 보장을 위해 Importance.max)
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        await androidPlatform.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDesc,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            showBadge: true,
          ),
        );

        if (requestPermissionOnStart) {
          await androidPlatform.requestNotificationsPermission();
        }
      }
    } catch (e) {
      debugPrint('NotificationService initialize error: $e');
    }
  }

  /// 바탕화면 위젯 백그라운드 콜백 Isolate 전용 안전 초기화
  /// (UI/Activity 바인딩 없이 타임존과 플러그인 엔진만 초기화하여 크래시 방지)
  static Future<void> initializeForBackground() async {
    await _ensureTimezoneInitialized();

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notificationsPlugin.initialize(settings: initSettings);
      debugPrint('⚡ [NotificationService] Background isolate initialized successfully');
    } catch (e) {
      debugPrint('NotificationService initializeForBackground error: $e');
    }
  }

  /// 최적의 Android 알람 스케줄 모드 결정 (정확한 알람 권한 허용 시 정시 알람, 미허용 시 절전 모드 폴백)
  static Future<AndroidScheduleMode> getOptimalScheduleMode() async {
    try {
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        final canExact = await androidPlatform.canScheduleExactNotifications();
        if (canExact == true) {
          return AndroidScheduleMode.exactAllowWhileIdle;
        }
      }
    } catch (_) {}
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  /// 정확한 알람(SCHEDULE_EXACT_ALARM) 권한 허용 상태 확인
  static Future<bool> canScheduleExactAlarms() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }
    try {
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        final canExact = await androidPlatform.canScheduleExactNotifications();
        return canExact ?? true;
      }
    } catch (_) {}
    return true;
  }

  /// 정확한 알람 권한 요청 화면 이동
  static Future<bool> requestExactAlarmsPermission() async {
    try {
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        final granted = await androidPlatform.requestExactAlarmsPermission();
        return granted ?? false;
      }
    } catch (_) {}
    return false;
  }

  /// 안드로이드 13+ 시스템 알림 권한 허용 여부 실시간 확인
  static Future<bool> checkSystemNotificationPermission() async {
    try {
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        final enabled = await androidPlatform.areNotificationsEnabled();
        return enabled ?? true;
      }
      return true;
    } catch (e) {
      debugPrint('Error checking notification permission: $e');
      return true;
    }
  }

  /// 안드로이드 시스템 알림 권한 요청
  static Future<bool> requestSystemNotificationPermission() async {
    try {
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        final granted = await androidPlatform.requestNotificationsPermission();
        return granted ?? false;
      }
      return true;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  /// 전체 알림 허용 여부 확인
  static Future<bool> isAllNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(prefAllNotificationsKey) ?? true;
    _globalNotificationsEnabledCache = enabled;
    return enabled;
  }

  /// 전체 알림 ON/OFF 설정 및 즉시 반영 (진행 중인 재예약 작업과의 경쟁 상태 완벽 차단)
  static Future<void> setAllNotificationsEnabled(
    bool enabled,
    List<HabitWithTodayStatus> habits,
  ) async {
    _scheduleGeneration++;
    _globalNotificationsEnabledCache = enabled;
    if (!enabled) {
      _pendingRescheduleHabits = null;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefAllNotificationsKey, enabled);

    if (!enabled) {
      await cancelAll();
    } else {
      await rescheduleAllHabits(habits);
    }
  }

  /// Java의 getNextFireDateMatchingDateTimeComponents(Time) 동작과 동일하게 다음 발생 시각 계산
  @visibleForTesting
  static tz.TZDateTime javaNextDailyOccurrence(tz.TZDateTime now, int hour, int minute) {
    var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (next.isBefore(now)) {
      next = tz.TZDateTime(tz.local, next.year, next.month, next.day + 1, hour, minute);
    }
    return next;
  }

  /// Java의 getNextFireDateMatchingDateTimeComponents(DayOfWeekAndTime) 동작과 동일하게 다음 발생 시각 계산
  @visibleForTesting
  static tz.TZDateTime javaNextWeeklyOccurrence(
    tz.TZDateTime now,
    int targetWeekday,
    int hour,
    int minute,
  ) {
    var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (next.isBefore(now)) {
      next = tz.TZDateTime(tz.local, next.year, next.month, next.day + 1, hour, minute);
    }
    while (next.weekday != targetWeekday) {
      next = tz.TZDateTime(tz.local, next.year, next.month, next.day + 1, hour, minute);
    }
    return next;
  }

  /// scheduledDate에 DateTimeComponents.time 적용 시 오늘(완료일)이나 이번 주(주간완료)로 앞당겨지지 않는지 검증
  @visibleForTesting
  static bool canUseDailyRepeat(tz.TZDateTime now, tz.TZDateTime scheduledDate) {
    final javaNext = javaNextDailyOccurrence(now, scheduledDate.hour, scheduledDate.minute);
    return javaNext.year == scheduledDate.year &&
        javaNext.month == scheduledDate.month &&
        javaNext.day == scheduledDate.day;
  }

  /// scheduledDate에 DateTimeComponents.dayOfWeekAndTime 적용 시 오늘(완료일)이나 이번 주(주간완료)로 앞당겨지지 않는지 검증
  @visibleForTesting
  static bool canUseWeeklyRepeat(tz.TZDateTime now, tz.TZDateTime scheduledDate) {
    final javaNext = javaNextWeeklyOccurrence(
      now,
      scheduledDate.weekday,
      scheduledDate.hour,
      scheduledDate.minute,
    );
    return javaNext.year == scheduledDate.year &&
        javaNext.month == scheduledDate.month &&
        javaNext.day == scheduledDate.day;
  }

  /// 스킵된 오늘/이번 주 시각이 지난 직후 자동으로 반복(DateTimeComponents) 알람으로 승격시키기 위한 타이머 등록
  static void _registerRolloverTime(tz.TZDateTime rolloverTime) {
    final now = tz.TZDateTime.now(tz.local);
    if (!rolloverTime.isAfter(now)) return;
    if (_nextRolloverTime == null || rolloverTime.isBefore(_nextRolloverTime!)) {
      _nextRolloverTime = rolloverTime;
      _rolloverResyncTimer?.cancel();
      final delay = rolloverTime.difference(now) + const Duration(seconds: 1);
      _rolloverResyncTimer = Timer(delay, () async {
        _nextRolloverTime = null;
        if (!_globalNotificationsEnabledCache) return;
        if (_lastScheduledHabitsSnapshot != null) {
          final nowCheck = tz.TZDateTime.now(tz.local);
          final updated = _lastScheduledHabitsSnapshot!.map((item) {
            final isNewDay = item.isCompletedToday &&
                nowCheck.day != rolloverTime.subtract(const Duration(seconds: 2)).day;
            final isNewWeek = item.isWeeklyCompleted &&
                nowCheck.weekday == DateTime.monday &&
                nowCheck.day != rolloverTime.subtract(const Duration(seconds: 2)).day;
            return item.copyWith(
              isCompletedToday: isNewDay ? false : item.isCompletedToday,
              isWeeklyCompleted: isNewWeek ? false : item.isWeeklyCompleted,
            );
          }).toList();
          await rescheduleAllHabits(updated);
        } else if (_individualScheduledHabits.isNotEmpty) {
          final entries = _individualScheduledHabits.values.toList();
          for (final entry in entries) {
            await scheduleHabitReminder(
              entry.habit,
              isCompletedToday: entry.isCompletedToday,
              isWeeklyCompleted: entry.isWeeklyCompleted,
            );
          }
        }
      });
    }
  }

  /// 알림 ID/페이로드가 특정 습관에 속하는지 판별
  static bool _belongsToHabit(int habitId, int? notifId, String? payload) {
    if (payload != null && _extractHabitId(payload) == habitId) return true;
    if (notifId != null && notifId >= habitId * 1000 && notifId < (habitId + 1) * 1000) {
      return true;
    }
    return false;
  }

  /// 상단바에 현재 떠 있는 활성 알림 목록 안전 조회
  static Future<List<ActiveNotification>> _getActiveNotificationsSafe() async {
    try {
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        final active = await androidPlatform.getActiveNotifications();
        return active;
      }
    } catch (_) {}
    return [];
  }

  /// 특정 습관의 상단바 활성 알림만 정리 (아직 완료되지 않은 다른 습관의 상단바 알림은 완벽 보존)
  static Future<void> dismissActiveHabitNotifications(int habitId) async {
    try {
      final active = await _getActiveNotificationsSafe();
      for (final n in active) {
        if (_belongsToHabit(habitId, n.id, n.payload)) {
          if (n.id != null) {
            await _notificationsPlugin.cancel(id: n.id!, tag: n.tag);
          }
        }
      }
    } catch (e) {
      debugPrint('Error dismissing active notifications for habit $habitId: $e');
    }
  }

  /// 모든 활성 습관의 알림 일괄 재동기화 (Latest-wins 대기열 및 세대 검증 적용)
  /// - 미완료 습관의 상단바 알림은 삭제하지 않고 그대로 유지
  /// - 완료/비활성화/보관된 습관의 상단바 알림만 깔끔하게 제거
  static Future<void> rescheduleAllHabits(
    List<HabitWithTodayStatus> habits,
  ) async {
    if (_isRescheduling) {
      _pendingRescheduleHabits = habits;
      debugPrint('⚡ [NotificationService] rescheduleAllHabits already running. Queued latest state.');
      return;
    }
    _isRescheduling = true;
    final int myGeneration = ++_scheduleGeneration;

    try {
      await _ensureTimezoneInitialized(forceRefresh: true);
      final isGlobalEnabled = await isAllNotificationsEnabled();
      if (!isGlobalEnabled || myGeneration != _scheduleGeneration || !_globalNotificationsEnabledCache) {
        if (!isGlobalEnabled || !_globalNotificationsEnabledCache) {
          await cancelAll();
        }
        return;
      }
      _lastScheduledHabitsSnapshot = habits;

      // 1. 기존 예약 알람(AlarmManager)만 1회성 네이티브 일괄 취소 (상단바 알림은 손대지 않음!)
      try {
        await _notificationsPlugin.cancelAllPendingNotifications();
      } catch (_) {}
      _scheduledAlarmCount = 0;
      alarmLimitExceededNotifier.value = false;

      if (myGeneration != _scheduleGeneration || !_globalNotificationsEnabledCache) {
        return;
      }

      // 2. 상단바 활성 알림 중 완료/비활성/보관된 습관의 알림만 정리
      for (final item in habits) {
        if (myGeneration != _scheduleGeneration || !_globalNotificationsEnabledCache) return;
        final habitId = item.habit.id;
        if (habitId == null) continue;
        final isWeeklyDone = item.habit.repeatType == RepeatType.weeklyCount && item.isWeeklyCompleted;
        if (item.isCompletedToday || isWeeklyDone || !item.habit.reminderEnabled || item.habit.isArchived) {
          await dismissActiveHabitNotifications(habitId);
        }
      }

      // 3. 활성 상태인 각 습관의 알림 재등록
      //    (알람 상한 도달 시 알림 횟수가 적은 습관부터 우선 보장되도록 예상 알람 수 오름차순 정렬)
      final targets = habits
          .where((item) => item.habit.reminderEnabled && !item.habit.isArchived)
          .toList()
        ..sort((a, b) => _estimateAlarmCount(a.habit).compareTo(_estimateAlarmCount(b.habit)));
      for (final item in targets) {
        if (myGeneration != _scheduleGeneration || !_globalNotificationsEnabledCache) return;
        await _scheduleHabitInternal(
          item.habit,
          isCompletedToday: item.isCompletedToday,
          isWeeklyCompleted: item.isWeeklyCompleted,
          expectedGeneration: myGeneration,
        );
      }
      debugPrint('⚡ [NotificationService] All ${habits.length} habits rescheduled successfully.');
    } catch (e) {
      debugPrint('Error in rescheduleAllHabits: $e');
    } finally {
      _isRescheduling = false;
      if (_pendingRescheduleHabits != null && _globalNotificationsEnabledCache) {
        final pending = _pendingRescheduleHabits!;
        _pendingRescheduleHabits = null;
        Future.microtask(() => rescheduleAllHabits(pending));
      } else {
        _pendingRescheduleHabits = null;
      }
    }
  }

  /// 개별 습관 알림 스마트 스케줄링 등록 / 갱신
  static Future<void> scheduleHabitReminder(
    Habit habit, {
    bool isCompletedToday = false,
    bool isWeeklyCompleted = false,
  }) async {
    if (habit.id == null) return;
    final int myGeneration = _scheduleGeneration;
    await _ensureTimezoneInitialized();

    final isGlobalEnabled = await isAllNotificationsEnabled();
    if (!isGlobalEnabled || !_globalNotificationsEnabledCache || !habit.reminderEnabled || habit.isArchived) {
      await cancelHabitReminder(habit.id!);
      return;
    }
    if (myGeneration != _scheduleGeneration) return;

    // 기존 예약 알람만 취소 (상단바는 완료된 경우에만 dismiss)
    try {
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      int remaining = 0;
      for (final req in pending) {
        if (_belongsToHabit(habit.id!, req.id, req.payload)) {
          await _notificationsPlugin.cancel(id: req.id);
        } else {
          remaining++;
        }
      }
      _scheduledAlarmCount = remaining;
      if (_scheduledAlarmCount < _maxScheduledAlarms) {
        alarmLimitExceededNotifier.value = false;
      }
    } catch (_) {}

    if (myGeneration != _scheduleGeneration || !_globalNotificationsEnabledCache) return;

    final isWeeklyDone = habit.repeatType == RepeatType.weeklyCount && isWeeklyCompleted;
    if (isCompletedToday || isWeeklyDone) {
      await dismissActiveHabitNotifications(habit.id!);
    }

    _individualScheduledHabits[habit.id!] = (
      habit: habit,
      isCompletedToday: isCompletedToday,
      isWeeklyCompleted: isWeeklyCompleted,
    );

    await _scheduleHabitInternal(
      habit,
      isCompletedToday: isCompletedToday,
      isWeeklyCompleted: isWeeklyCompleted,
      expectedGeneration: myGeneration,
    );
  }

  /// 개별 습관 내부 스케줄링 실행부
  static Future<void> _scheduleHabitInternal(
    Habit habit, {
    required bool isCompletedToday,
    required bool isWeeklyCompleted,
    int? expectedGeneration,
  }) async {
    if (habit.id == null) return;
    final int gen = expectedGeneration ?? _scheduleGeneration;
    if (gen != _scheduleGeneration || !_globalNotificationsEnabledCache) return;

    try {
      final title = habit.title;
      final isMedication = habit.title.contains('약') ||
          habit.title.contains('비타민') ||
          habit.title.contains('영양제') ||
          habit.title.contains('유산균') ||
          habit.iconName.contains('medication') ||
          habit.iconName.contains('pill');

      final String body;
      if (isMedication) {
        body = '💊 [$title] 잊지 말고 챙겨 드실 시간이에요! 건강을 위해 꼭 챙겨주세요.';
      } else if (habit.habitType == HabitType.count) {
        body = '💧 [$title] 실천할 시간이에요! 오늘의 목표(${habit.targetCount}${habit.unit})를 달성해보세요.';
      } else {
        body = '⚡ [$title] 실천할 시간이에요! 3초 만에 완료해보세요.';
      }

      final notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDesc,
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/launcher_icon',
          playSound: true,
          enableVibration: true,
          groupKey: 'habit_${habit.id}',
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: const DarwinNotificationDetails(
          sound: 'default',
        ),
      );

      final scheduleMode = await getOptimalScheduleMode();
      if (gen != _scheduleGeneration || !_globalNotificationsEnabledCache) return;

      final now = tz.TZDateTime.now(tz.local);
      final isWeeklyDone = habit.repeatType == RepeatType.weeklyCount && isWeeklyCompleted;

      final times = habit.reminderTimes;
      if (habit.reminderType == ReminderType.fixed && times.isNotEmpty) {
        // ==========================================
        // 1. 다중 지정 시각 알림
        // ==========================================
        final isDaily = habit.repeatType == RepeatType.daily ||
            habit.repeatType == RepeatType.weeklyCount ||
            habit.repeatDays.length == 7;

        for (int timeIdx = 0; timeIdx < times.length; timeIdx++) {
          if (gen != _scheduleGeneration || !_globalNotificationsEnabledCache) return;
          final parts = times[timeIdx].split(':');
          if (parts.length < 2) continue;
          final hour = int.tryParse(parts[0]) ?? 8;
          final minute = int.tryParse(parts[1]) ?? 0;

          if (isWeeklyDone) {
            // 이번 주 목표 횟수를 다 채웠으므로 이번 주는 건너뛰고 차주 월요일부터 스케줄 등록
            int daysUntilNextMonday = (DateTime.monday - now.weekday + 7) % 7;
            if (daysUntilNextMonday == 0) daysUntilNextMonday = 7;

            // 차주 7일간 각각 요일별 알림으로 스케줄링 (이번 주 잔여일 울림 완벽 차단 및 장기 반복 유지)
            for (int d = 0; d < 7; d++) {
              final dayDate = tz.TZDateTime(
                tz.local,
                now.year,
                now.month,
                now.day,
                hour,
                minute,
              ).add(Duration(days: daysUntilNextMonday + d));

              final notifId = _generateNotificationId(habit.id!, dayDate.weekday * 10 + timeIdx);
              final canRepeat = canUseWeeklyRepeat(now, dayDate);
              await _safeZonedSchedule(
                id: notifId,
                title: title,
                body: body,
                scheduledDate: dayDate,
                notificationDetails: notificationDetails,
                androidScheduleMode: scheduleMode,
                matchDateTimeComponents: canRepeat ? DateTimeComponents.dayOfWeekAndTime : null,
                payload: 'habit_${habit.id}_d${dayDate.weekday}_t$timeIdx',
                expectedGeneration: gen,
              );
              if (!canRepeat) {
                final midnight = tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, 0, 0, 5);
                _registerRolloverTime(midnight);
              }
            }
            continue;
          }

          if (isDaily) {
            if (isCompletedToday) {
              // 오늘 이미 완료된 경우: 오늘 남은 시간 울림을 완벽 차단하면서 장기 반복 유지
              final tomorrow = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute)
                  .add(const Duration(days: 1));

              if (canUseDailyRepeat(now, tomorrow)) {
                // 이미 오늘 시각이 지나서 네이티브가 내일로 계산하는 경우: 1개의 일일 반복 알람 사용
                final notifId = _generateNotificationId(habit.id!, timeIdx);
                await _safeZonedSchedule(
                  id: notifId,
                  title: title,
                  body: body,
                  scheduledDate: tomorrow,
                  notificationDetails: notificationDetails,
                  androidScheduleMode: scheduleMode,
                  matchDateTimeComponents: DateTimeComponents.time,
                  payload: 'habit_${habit.id}_t$timeIdx',
                  expectedGeneration: gen,
                );
              } else {
                // 오늘 시각이 아직 지나지 않은 경우: 네이티브가 오늘로 당기는 것을 차단하기 위해 요일별 분산 등록
                for (int dayOffset = 1; dayOffset <= 7; dayOffset++) {
                  final targetDayDate = tz.TZDateTime(
                    tz.local,
                    now.year,
                    now.month,
                    now.day,
                    hour,
                    minute,
                  ).add(Duration(days: dayOffset));

                  final notifId = _generateNotificationId(habit.id!, targetDayDate.weekday * 10 + timeIdx);
                  final canRepeat = canUseWeeklyRepeat(now, targetDayDate);
                  await _safeZonedSchedule(
                    id: notifId,
                    title: title,
                    body: body,
                    scheduledDate: targetDayDate,
                    notificationDetails: notificationDetails,
                    androidScheduleMode: scheduleMode,
                    matchDateTimeComponents: canRepeat ? DateTimeComponents.dayOfWeekAndTime : null,
                    payload: 'habit_${habit.id}_d${targetDayDate.weekday}_t$timeIdx',
                    expectedGeneration: gen,
                  );
                }
                final midnight = tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, 0, 0, 5);
                _registerRolloverTime(midnight);
              }
            } else {
              // 오늘 미완료: 오늘 시각이 지났으면 내일, 안 지났으면 오늘 등록 (일일 반복)
              var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
              if (scheduledDate.isBefore(now)) {
                scheduledDate = scheduledDate.add(const Duration(days: 1));
              }

              final notifId = _generateNotificationId(habit.id!, timeIdx);
              await _safeZonedSchedule(
                id: notifId,
                title: title,
                body: body,
                scheduledDate: scheduledDate,
                notificationDetails: notificationDetails,
                androidScheduleMode: scheduleMode,
                matchDateTimeComponents: DateTimeComponents.time,
                payload: 'habit_${habit.id}_t$timeIdx',
                expectedGeneration: gen,
              );
            }
          } else if (habit.repeatDays.isNotEmpty) {
            // 요일별 반복
            for (final day in habit.repeatDays) {
              if (gen != _scheduleGeneration || !_globalNotificationsEnabledCache) return;
              int daysUntil = (day - now.weekday) % 7;
              if (daysUntil < 0) daysUntil += 7;

              var scheduledDate = tz.TZDateTime(
                tz.local,
                now.year,
                now.month,
                now.day,
                hour,
                minute,
              ).add(Duration(days: daysUntil));

              if (daysUntil == 0 && (isCompletedToday || scheduledDate.isBefore(now))) {
                scheduledDate = scheduledDate.add(const Duration(days: 7));
              }

              final notifId = _generateNotificationId(habit.id!, day * 10 + timeIdx);
              final canRepeat = canUseWeeklyRepeat(now, scheduledDate);

              await _safeZonedSchedule(
                id: notifId,
                title: title,
                body: body,
                scheduledDate: scheduledDate,
                notificationDetails: notificationDetails,
                androidScheduleMode: scheduleMode,
                matchDateTimeComponents: canRepeat ? DateTimeComponents.dayOfWeekAndTime : null,
                payload: 'habit_${habit.id}_d${day}_t$timeIdx',
                expectedGeneration: gen,
              );

              if (!canRepeat) {
                final midnight = tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, 0, 0, 5);
                _registerRolloverTime(midnight);
              }
            }
          }
        }
      } else if (habit.reminderType == ReminderType.interval) {
        // ==========================================
        // 2. 주기적 반복 간격 알림
        // ==========================================
        final startParts = (habit.reminderStartTime ?? '09:00').split(':');
        final endParts = (habit.reminderEndTime ?? '21:00').split(':');

        final startHour = int.tryParse(startParts[0]) ?? 9;
        final startMinute = int.tryParse(startParts.length > 1 ? startParts[1] : '0') ?? 0;

        final endHour = int.tryParse(endParts[0]) ?? 21;
        final endMinute = int.tryParse(endParts.length > 1 ? endParts[1] : '0') ?? 0;

        final intervalMinutes = (habit.reminderIntervalMinutes ?? 60).clamp(15, 720);

        final startTotalMin = startHour * 60 + startMinute;
        int endTotalMin = endHour * 60 + endMinute;

        if (endTotalMin <= startTotalMin) {
          endTotalMin += 24 * 60;
        }

        if (isWeeklyDone) {
          // 주 N회 목표 완료 시 차주 월요일부터 슬롯당 1개의 일일 반복 알람으로 등록 (48슬롯 = 48개 알람)
          int daysUntilNextMonday = (DateTime.monday - now.weekday + 7) % 7;
          if (daysUntilNextMonday == 0) daysUntilNextMonday = 7;

          int currentSlotMin = startTotalMin;
          int slotIdx = 0;

          while (currentSlotMin <= endTotalMin && slotIdx < 48) {
            if (gen != _scheduleGeneration || !_globalNotificationsEnabledCache) return;
            final rawHour = currentSlotMin ~/ 60;
            final slotHour = rawHour % 24;
            final slotMin = currentSlotMin % 60;
            final extraDays = rawHour >= 24 ? 1 : 0;

            final scheduledDate = tz.TZDateTime(
              tz.local,
              now.year,
              now.month,
              now.day,
              slotHour,
              slotMin,
            ).add(Duration(days: daysUntilNextMonday + extraDays));

            final notifId = _generateNotificationId(habit.id!, slotIdx);
            final canRepeat = canUseDailyRepeat(now, scheduledDate);
            await _safeZonedSchedule(
              id: notifId,
              title: title,
              body: body,
              scheduledDate: scheduledDate,
              notificationDetails: notificationDetails,
              androidScheduleMode: scheduleMode,
              matchDateTimeComponents: canRepeat ? DateTimeComponents.time : null,
              payload: 'habit_${habit.id}_slot_$slotIdx',
              expectedGeneration: gen,
            );
            if (!canRepeat) {
              final midnight = tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, 0, 0, 5);
              _registerRolloverTime(midnight);
            }

            slotIdx++;
            currentSlotMin += intervalMinutes;
          }
          return;
        }

        final isDaily = habit.repeatType == RepeatType.daily ||
            habit.repeatType == RepeatType.weeklyCount ||
            habit.repeatDays.length == 7;

        if (isDaily) {
          int currentSlotMin = startTotalMin;
          int slotIdx = 0;

          while (currentSlotMin <= endTotalMin && slotIdx < 48) {
            if (gen != _scheduleGeneration || !_globalNotificationsEnabledCache) return;
            final rawHour = currentSlotMin ~/ 60;
            final slotHour = rawHour % 24;
            final slotMin = currentSlotMin % 60;
            final extraDays = rawHour >= 24 ? 1 : 0;

            final notifId = _generateNotificationId(habit.id!, slotIdx);

            if (isCompletedToday) {
              // 오늘 이미 완료된 경우: 오늘 남은 알림은 당겨짐 방지를 위해 검증 후 등록
              final scheduledDate = tz.TZDateTime(
                tz.local,
                now.year,
                now.month,
                now.day,
                slotHour,
                slotMin,
              ).add(Duration(days: 1 + extraDays));

              final canRepeat = canUseDailyRepeat(now, scheduledDate);
              await _safeZonedSchedule(
                id: notifId,
                title: title,
                body: body,
                scheduledDate: scheduledDate,
                notificationDetails: notificationDetails,
                androidScheduleMode: scheduleMode,
                matchDateTimeComponents: canRepeat ? DateTimeComponents.time : null,
                payload: 'habit_${habit.id}_slot_$slotIdx',
                expectedGeneration: gen,
              );
              if (!canRepeat) {
                final midnight = tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, 0, 0, 5);
                _registerRolloverTime(midnight);
              }
            } else {
              // 자정 넘김(extraDays == 1) 슬롯이 새벽 현재 시각 이후라면 오늘 새벽에 바로 울리도록 보존
              var scheduledDate = tz.TZDateTime(
                tz.local,
                now.year,
                now.month,
                now.day,
                slotHour,
                slotMin,
              );
              if (scheduledDate.isBefore(now)) {
                scheduledDate = scheduledDate.add(const Duration(days: 1));
              }

              await _safeZonedSchedule(
                id: notifId,
                title: title,
                body: body,
                scheduledDate: scheduledDate,
                notificationDetails: notificationDetails,
                androidScheduleMode: scheduleMode,
                matchDateTimeComponents: DateTimeComponents.time,
                payload: 'habit_${habit.id}_slot_$slotIdx',
                expectedGeneration: gen,
              );
            }

            slotIdx++;
            currentSlotMin += intervalMinutes;
          }
        } else if (habit.repeatDays.isNotEmpty) {
          // 특정 요일 간격 알림 (자정을 넘기는 새벽 슬롯 및 주간 반복 유지)
          for (final day in habit.repeatDays) {
            if (gen != _scheduleGeneration || !_globalNotificationsEnabledCache) return;
            int daysUntil = (day - now.weekday) % 7;
            if (daysUntil < 0) daysUntil += 7;

            int currentSlotMin = startTotalMin;
            int slotIdx = 0;

            while (currentSlotMin <= endTotalMin && slotIdx < 48) {
              if (gen != _scheduleGeneration || !_globalNotificationsEnabledCache) return;
              final rawHour = currentSlotMin ~/ 60;
              final slotHour = rawHour % 24;
              final slotMin = currentSlotMin % 60;
              final extraDays = rawHour >= 24 ? 1 : 0;

              tz.TZDateTime scheduledDate;
              // 전날 시작한 야간~새벽(extraDays == 1) 슬롯이 오늘 새벽(daysUntil == 6) 아직 지나지 않은 경우 오늘 새벽으로 유지
              final todaySlotTime = tz.TZDateTime(
                tz.local,
                now.year,
                now.month,
                now.day,
                slotHour,
                slotMin,
              );
              if (extraDays == 1 && daysUntil == 6 && !isCompletedToday && !todaySlotTime.isBefore(now)) {
                scheduledDate = todaySlotTime;
              } else {
                var effectiveDaysUntil = daysUntil;
                if (effectiveDaysUntil == 0 && isCompletedToday) {
                  effectiveDaysUntil = 7;
                }
                scheduledDate = todaySlotTime.add(Duration(days: effectiveDaysUntil + extraDays));
                if (scheduledDate.isBefore(now)) {
                  scheduledDate = scheduledDate.add(const Duration(days: 7));
                }
              }

              final subId = ((day - 1) * 50 + slotIdx) % 1000;
              final notifId = _generateNotificationId(habit.id!, subId);
              final canRepeat = canUseWeeklyRepeat(now, scheduledDate);

              await _safeZonedSchedule(
                id: notifId,
                title: title,
                body: body,
                scheduledDate: scheduledDate,
                notificationDetails: notificationDetails,
                androidScheduleMode: scheduleMode,
                matchDateTimeComponents: canRepeat ? DateTimeComponents.dayOfWeekAndTime : null,
                payload: 'habit_${habit.id}_day_${day}_slot_$slotIdx',
                expectedGeneration: gen,
              );
              if (!canRepeat) {
                final midnight = tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, 0, 0, 5);
                _registerRolloverTime(midnight);
              }

              slotIdx++;
              currentSlotMin += intervalMinutes;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error scheduling smart habit reminder: $e');
    }
  }

  /// 습관 알림 취소 (예약 알람 취소 및 상단바 알림 즉시 제거)
  static Future<void> cancelHabitReminder(int habitId) async {
    _individualScheduledHabits.remove(habitId);
    try {
      try {
        final pending = await _notificationsPlugin.pendingNotificationRequests();
        for (final req in pending) {
          if (_belongsToHabit(habitId, req.id, req.payload)) {
            await _notificationsPlugin.cancel(id: req.id);
          }
        }
      } catch (_) {}
      await dismissActiveHabitNotifications(habitId);
    } catch (e) {
      debugPrint('Error cancelling notification for habit $habitId: $e');
    }
  }

  /// 페이로드에서 습관 ID 추출 헬퍼
  static int? _extractHabitId(String? payload) {
    if (payload == null) return null;
    final match = RegExp(r'habit_(\d+)').firstMatch(payload);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  /// 알림 탭 페이로드 처리 헬퍼
  static void _handleNotificationPayload(String payload) {
    final habitId = _extractHabitId(payload);
    if (habitId != null) {
      notificationTappedHabitId.value = habitId;
    }
  }

  /// 전체 알림 일괄 취소
  static Future<void> cancelAll() async {
    _scheduleGeneration++;
    _pendingRescheduleHabits = null;
    _lastScheduledHabitsSnapshot = null;
    _individualScheduledHabits.clear();
    _rolloverResyncTimer?.cancel();
    _nextRolloverTime = null;
    _scheduledAlarmCount = 0;
    alarmLimitExceededNotifier.value = false;
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('⚡ [NotificationService] All notifications cancelled.');
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }

  /// 테스트 즉시 알림 발송 (상단바 확인용)
  static Future<bool> showTestNotification({
    String title = '⚡ [3초 습관] 테스트 알림',
    String body = '알림이 정상적으로 작동하고 있습니다! 체크 한 번, 3초 컷 ⚡️',
  }) async {
    try {
      await _ensureTimezoneInitialized();
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        final granted = await androidPlatform.requestNotificationsPermission();
        if (granted == false) {
          debugPrint('Notification permission denied by user.');
          return false;
        }
      }

      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDesc,
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/launcher_icon',
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
      return true;
    } catch (e) {
      debugPrint('Error showing test notification: $e');
      return false;
    }
  }

  /// 고유 Notification ID 생성 (습관 ID * 1000 + subId)
  static int _generateNotificationId(int habitId, int subId) {
    return (habitId * 1000 + subId).abs() % 2147483647;
  }

  /// Android AlarmManager 앱당 동시 알람 한도(500개) 초과 방지용 안전 상한
  static const int _maxScheduledAlarms = 450;
  static int _scheduledAlarmCount = 0;

  /// 습관 1개가 예약하는 최대 알람 수 추정 (상한 도달 시 우선순위 정렬용)
  static int _estimateAlarmCount(Habit habit) {
    final days = (habit.repeatType == RepeatType.daily ||
            habit.repeatType == RepeatType.weeklyCount ||
            habit.repeatDays.length == 7)
        ? 1
        : habit.repeatDays.length.clamp(1, 7);
    if (habit.reminderType == ReminderType.interval) {
      final s = (habit.reminderStartTime ?? '09:00').split(':');
      final e = (habit.reminderEndTime ?? '21:00').split(':');
      final startMin = (int.tryParse(s[0]) ?? 9) * 60 + (int.tryParse(s.length > 1 ? s[1] : '0') ?? 0);
      var endMin = (int.tryParse(e[0]) ?? 21) * 60 + (int.tryParse(e.length > 1 ? e[1] : '0') ?? 0);
      if (endMin <= startMin) endMin += 24 * 60;
      final interval = (habit.reminderIntervalMinutes ?? 60).clamp(15, 720);
      final slots = ((endMin - startMin) ~/ interval + 1).clamp(1, 48);
      return slots * days;
    }
    return habit.reminderTimes.length.clamp(1, 6) * days;
  }

  /// 예약 알람 상한 검사 + 세대 검증 + 개별 실패 격리
  static Future<void> _safeZonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    DateTimeComponents? matchDateTimeComponents,
    String? payload,
    int? expectedGeneration,
  }) async {
    if (expectedGeneration != null && expectedGeneration != _scheduleGeneration) {
      return;
    }
    if (!_globalNotificationsEnabledCache) {
      return;
    }
    if (_scheduledAlarmCount >= _maxScheduledAlarms) {
      alarmLimitExceededNotifier.value = true;
      debugPrint('⚠️ [NotificationService] Alarm limit ($_maxScheduledAlarms) reached. Skip id=$id');
      return;
    }
    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: androidScheduleMode,
        matchDateTimeComponents: matchDateTimeComponents,
        payload: payload,
      );
      if ((expectedGeneration != null && expectedGeneration != _scheduleGeneration) ||
          !_globalNotificationsEnabledCache) {
        await _notificationsPlugin.cancel(id: id);
        return;
      }
      _scheduledAlarmCount++;
    } catch (e) {
      debugPrint('Error scheduling notification id=$id: $e');
    }
  }
}
