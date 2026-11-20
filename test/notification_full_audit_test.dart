import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:three_sec_habit/core/constants/app_constants.dart';
import 'package:three_sec_habit/core/constants/app_sounds.dart';
import 'package:three_sec_habit/core/database/database_helper.dart';
import 'package:three_sec_habit/core/database/habit_dao.dart';
import 'package:three_sec_habit/core/services/notification_service.dart';
import 'package:three_sec_habit/models/habit.dart';
import 'package:three_sec_habit/models/habit_with_today_status.dart';
import 'package:three_sec_habit/providers/habit_provider.dart';

/// 안드로이드 네이티브 FlutterLocalNotificationsPlugin.getNextFireDateMatchingDateTimeComponents 시뮬레이터
DateTime simulateAndroidEffectiveFireDate(
  DateTime now,
  DateTime requestedDate,
  int? matchComponentsIndex,
) {
  if (matchComponentsIndex == null) return requestedDate;
  var next = DateTime(now.year, now.month, now.day, requestedDate.hour, requestedDate.minute);
  while (next.isBefore(now)) {
    next = next.add(const Duration(days: 1));
  }
  if (matchComponentsIndex == 0) {
    // DateTimeComponents.time
    return next;
  } else if (matchComponentsIndex == 1) {
    // DateTimeComponents.dayOfWeekAndTime
    while (next.weekday != requestedDate.weekday) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }
  return requestedDate;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  const notifChannel = MethodChannel('dexterous.com/flutter/local_notifications');
  const timezoneChannel = MethodChannel('flutter_timezone');
  const homeWidgetChannel = MethodChannel('home_widget');

  final Map<int, Map<String, dynamic>> scheduledAlarms = {};

  setUpAll(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
  });

  tearDownAll(() {
    debugDefaultTargetPlatformOverride = null;
  });

  setUp(() async {
    scheduledAlarms.clear();
    SharedPreferences.setMockInitialValues({'all_notifications_enabled': true});

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(timezoneChannel, (call) async {
      return 'Asia/Seoul';
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(homeWidgetChannel, (call) async {
      return true;
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notifChannel, (call) async {
      switch (call.method) {
        case 'initialize':
        case 'createNotificationChannel':
        case 'requestNotificationsPermission':
        case 'areNotificationsEnabled':
        case 'canScheduleExactNotifications':
          return true;
        case 'getNotificationAppLaunchDetails':
          return {'notificationLaunchedApp': false};
        case 'getActiveNotifications':
          return <Map<String, dynamic>>[];
        case 'pendingNotificationRequests':
          return scheduledAlarms.values
              .map((e) => {
                    'id': e['id'],
                    'title': e['title'],
                    'body': e['body'],
                    'payload': e['payload'],
                  })
              .toList();
        case 'cancelAll':
        case 'cancelAllPendingNotifications':
          scheduledAlarms.clear();
          return null;
        case 'cancel':
          final args = Map<String, dynamic>.from(call.arguments as Map);
          scheduledAlarms.remove(args['id']);
          return null;
        case 'zonedSchedule':
          final args = Map<String, dynamic>.from(call.arguments as Map);
          scheduledAlarms[args['id'] as int] = args;
          return null;
        default:
          return null;
      }
    });

    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: AppConstants.dbVersion,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE ${AppConstants.tableHabits} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              icon_name TEXT NOT NULL DEFAULT 'check_circle',
              color_value INTEGER NOT NULL DEFAULT 4287332342,
              habit_type TEXT NOT NULL DEFAULT 'check',
              target_count INTEGER NOT NULL DEFAULT 1,
              unit TEXT NOT NULL DEFAULT '회',
              repeat_type TEXT NOT NULL DEFAULT 'daily',
              repeat_days TEXT,
              repeat_count INTEGER,
              reminder_type TEXT NOT NULL DEFAULT 'fixed',
              reminder_time TEXT,
              reminder_interval_minutes INTEGER,
              reminder_start_time TEXT,
              reminder_end_time TEXT,
              reminder_enabled INTEGER NOT NULL DEFAULT 0,
              sound_key TEXT NOT NULL DEFAULT 'default',
              created_at TEXT NOT NULL,
              is_archived INTEGER NOT NULL DEFAULT 0
            )
          ''');
          await db.execute('''
            CREATE TABLE ${AppConstants.tableHabitLogs} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              habit_id INTEGER NOT NULL,
              date TEXT NOT NULL,
              count INTEGER NOT NULL DEFAULT 1,
              is_completed INTEGER NOT NULL DEFAULT 1,
              completed_at TEXT NOT NULL,
              FOREIGN KEY (habit_id) REFERENCES ${AppConstants.tableHabits} (id) ON DELETE CASCADE
            )
          ''');
          await db.execute('''
            CREATE UNIQUE INDEX idx_habit_logs_unique
            ON ${AppConstants.tableHabitLogs} (habit_id, date)
          ''');
        },
      ),
    );
    DatabaseHelper.setDatabaseForTesting(db);
    await NotificationService.initialize();
  });

  tearDown(() async {
    await NotificationService.cancelAll();
    await DatabaseHelper.instance.close();
    DatabaseHelper.resetForTesting();
  });

  DateTime parseScheduledDate(Map<String, dynamic> args) {
    return DateTime.parse(args['scheduledDateTime'] as String);
  }

  group('1. 특정 시각 & 규칙적 간격 알림 개수 및 새벽 시간 제외 전수 검증', () {
    test('특정 시각 다중 알림(1개, 3개, 6개) + 사운드 채널 정확성 검증', () async {
      final h1 = Habit(
        id: 1,
        title: '혈압약 복용',
        iconName: 'medication',
        reminderType: ReminderType.fixed,
        reminderTime: '08:30,12:30,18:30',
        reminderEnabled: true,
        soundKey: 'voice_medicine',
      );
      await NotificationService.rescheduleAllHabits([
        HabitWithTodayStatus(habit: h1, isCompletedToday: false),
      ]);

      expect(scheduledAlarms.length, 3);
      for (final alarm in scheduledAlarms.values) {
        final ps = Map<String, dynamic>.from(alarm['platformSpecifics'] as Map);
        expect(ps['channelId'], 'three_sec_habit_voice_medicine_v1');
        expect(ps['sound'], 'voice_medicine');
      }

      final h2 = Habit(
        id: 2,
        title: '6회 알림',
        reminderType: ReminderType.fixed,
        reminderTime: '07:00,10:00,13:00,16:00,19:00,22:00',
        reminderEnabled: true,
        soundKey: 'default',
      );
      await NotificationService.rescheduleAllHabits([
        HabitWithTodayStatus(habit: h2, isCompletedToday: false),
      ]);
      expect(scheduledAlarms.length, 6);
      for (final alarm in scheduledAlarms.values) {
        final ps = Map<String, dynamic>.from(alarm['platformSpecifics'] as Map);
        expect(ps['channelId'], NotificationService.channelId);
      }
    });

    test('간격 알림 - 새벽 시간 제외 ON(09:00~21:00) 시 모든 간격별 개수 및 새벽 시각 0건 검증', () async {
      final cases = {
        30: 25,
        60: 13,
        120: 7,
        180: 5,
      };

      for (final entry in cases.entries) {
        final habit = Habit(
          id: 10,
          title: '물 마시기',
          iconName: 'water_drop',
          reminderType: ReminderType.interval,
          reminderIntervalMinutes: entry.key,
          reminderStartTime: '09:00',
          reminderEndTime: '21:00',
          reminderEnabled: true,
          soundKey: AppSounds.suggestSoundForIcon('water_drop'),
        );
        await NotificationService.rescheduleAllHabits([
          HabitWithTodayStatus(habit: habit, isCompletedToday: false),
        ]);

        expect(scheduledAlarms.length, entry.value,
            reason: '${entry.key}분 간격(09:00~21:00)은 ${entry.value}개여야 함');
        for (final alarm in scheduledAlarms.values) {
          final dt = parseScheduledDate(alarm);
          final mins = dt.hour * 60 + dt.minute;
          expect(mins >= 9 * 60 && mins <= 21 * 60, true,
              reason: '새벽 시간 제외 ON인데 범위 밖 시각(${dt.hour}:${dt.minute})이 예약됨');
        }
      }
    });

    test('간격 알림 - 새벽 시간 제외 OFF(24시간, 00:00~23:59) 시 모든 간격별 개수 검증', () async {
      final cases = {
        30: 48,
        60: 24,
        120: 12,
        180: 8,
      };

      for (final entry in cases.entries) {
        final habit = Habit(
          id: 11,
          title: '24시간 간격',
          reminderType: ReminderType.interval,
          reminderIntervalMinutes: entry.key,
          reminderStartTime: '00:00',
          reminderEndTime: '23:59',
          reminderEnabled: true,
        );
        await NotificationService.rescheduleAllHabits([
          HabitWithTodayStatus(habit: habit, isCompletedToday: false),
        ]);

        expect(scheduledAlarms.length, entry.value,
            reason: '${entry.key}분 간격(24시간)은 ${entry.value}개여야 함');
      }
    });
  });

  group('2. 습관 CRUD(추가/수정/삭제) & 완료/되돌리기 & 카운트형 & 주 N회 전체 시나리오', () {
    test('단순 체크형: 추가 → 완료(오늘 스킵+장기반복) → 완료 되돌리기(오늘 복원) → 삭제(0개)', () async {
      final provider = HabitProvider(habitDao: HabitDao());
      final now = DateTime.now();
      // 현재 시각 + 2분 뒤(오늘 남은 시각, 자정 직전이면 23:59)
      final futureTime = now.hour == 23 && now.minute >= 57
          ? DateTime(now.year, now.month, now.day, 23, 59)
          : now.add(const Duration(minutes: 2));
      final hhmm =
          '${futureTime.hour.toString().padLeft(2, '0')}:${futureTime.minute.toString().padLeft(2, '0')}';

      final id = await provider.addHabit(Habit(
        title: '스트레칭',
        iconName: 'self_improvement',
        reminderType: ReminderType.fixed,
        reminderTime: hhmm,
        reminderEnabled: true,
        soundKey: 'voice_stretch',
      ));

      // 1) 등록 직후: 오늘 울리는 알람 1개 (매일 반복)
      expect(scheduledAlarms.length, 1);
      final initialAlarm = scheduledAlarms.values.first;
      expect(initialAlarm['matchDateTimeComponents'], 0); // Time

      // 2) 완료 체크: 오늘 날짜로 계산되는 알람이 단 1개도 없어야 하며(안드로이드 시뮬레이션 포함), 내일~6일 후 주간 반복 유지!
      await provider.toggleHabit(id);
      expect(scheduledAlarms.isNotEmpty, true);
      int repeatingCount = 0;
      for (final alarm in scheduledAlarms.values) {
        final requested = parseScheduledDate(alarm);
        final effective = simulateAndroidEffectiveFireDate(
          now,
          requested,
          alarm['matchDateTimeComponents'] as int?,
        );
        final isToday = effective.year == now.year &&
            effective.month == now.month &&
            effective.day == now.day;
        expect(isToday, false, reason: '완료된 습관이 오늘($effective) 다시 울림!');
        if (alarm['matchDateTimeComponents'] != null) repeatingCount++;
      }
      expect(repeatingCount >= 1, true, reason: '장기 반복 알람이 유지되어야 함');

      // 3) 목록에서 완료 되돌리기(해제): 다시 오늘 알림(1개, 매일 반복) 즉시 복원!
      await provider.toggleHabit(id);
      expect(scheduledAlarms.length, 1);
      expect(scheduledAlarms.values.first['matchDateTimeComponents'], 0);

      // 4) 습관 삭제: 예약 알람 0개로 완전 삭제!
      await provider.deleteHabit(id);
      expect(scheduledAlarms.isEmpty, true);
    });

    test('카운트형 습관: 1/3·2/3 진행 중(유지) → 3/3 완료(오늘 스킵) → 2/3 감소(복원) → 목표 3→5 수정 시 복원', () async {
      final provider = HabitProvider(habitDao: HabitDao());
      final now = DateTime.now();
      final id = await provider.addHabit(Habit(
        title: '물 마시기',
        iconName: 'water_drop',
        habitType: HabitType.count,
        targetCount: 3,
        unit: '잔',
        reminderType: ReminderType.interval,
        reminderIntervalMinutes: 120,
        reminderStartTime: '09:00',
        reminderEndTime: '21:00',
        reminderEnabled: true,
        soundKey: 'voice_water',
      ));

      // 0/3 -> 7개 슬롯(매일 반복)
      expect(scheduledAlarms.length, 7);

      // 1/3, 2/3 -> 아직 미완료이므로 7개 매일 반복 유지
      await provider.incrementHabitCount(id);
      expect(scheduledAlarms.length, 7);
      await provider.incrementHabitCount(id);
      expect(scheduledAlarms.length, 7);

      // 3/3 -> 완료! 오늘 남은 시각은 안드로이드 시뮬레이션상 절대 오늘 울리지 않아야 함
      await provider.incrementHabitCount(id);
      for (final alarm in scheduledAlarms.values) {
        final requested = parseScheduledDate(alarm);
        final effective = simulateAndroidEffectiveFireDate(
          now,
          requested,
          alarm['matchDateTimeComponents'] as int?,
        );
        final isToday = effective.year == now.year &&
            effective.month == now.month &&
            effective.day == now.day;
        expect(isToday, false, reason: '카운트 3/3 완료 후 오늘($effective) 재발송됨!');
      }

      // 3/3 상태에서 습관 목표 횟수를 3 -> 5로 수정하면 자동으로 미완료 전환 + 오늘 알림(7개) 즉시 복원!
      final currentHabit = provider.habits.firstWhere((e) => e.habit.id == id).habit;
      await provider.updateHabit(currentHabit.copyWith(targetCount: 5));
      expect(scheduledAlarms.length, 7);

      // 5/5로 완료 후 다시 4/5로 감소(되돌리기) -> 오늘 알림 7개 즉시 복원!
      await provider.setHabitCount(id, 5);
      await provider.decrementHabitCount(id);
      expect(scheduledAlarms.length, 7);
    });

    test('습관 수정: 알림 OFF, 지정시각→간격 변경, 사운드 변경 즉시 반영 검증', () async {
      final provider = HabitProvider(habitDao: HabitDao());
      final id = await provider.addHabit(Habit(
        title: '운동',
        iconName: 'fitness_center',
        reminderType: ReminderType.fixed,
        reminderTime: '08:00',
        reminderEnabled: true,
        soundKey: 'voice_walk',
      ));
      expect(scheduledAlarms.length, 1);

      // 알림 OFF 수정 -> 알람 0개
      final h = provider.habits.firstWhere((e) => e.habit.id == id).habit;
      await provider.updateHabit(h.copyWith(reminderEnabled: false));
      expect(scheduledAlarms.isEmpty, true);

      // 다시 알림 ON + 간격 알림(09:00~21:00, 180분=5개) + 사운드 기본음 변경
      await provider.updateHabit(h.copyWith(
        reminderEnabled: true,
        reminderType: ReminderType.interval,
        reminderStartTime: '09:00',
        reminderEndTime: '21:00',
        reminderIntervalMinutes: 180,
        soundKey: 'default',
      ));
      expect(scheduledAlarms.length, 5);
      for (final alarm in scheduledAlarms.values) {
        final ps = Map<String, dynamic>.from(alarm['platformSpecifics'] as Map);
        expect(ps['channelId'], NotificationService.channelId);
      }
    });

    test('주 N회 목표 완료(간격 알림 2개 x 24시간 30분=48슬롯): 450 상한 미초과 + 이번 주 울림 0건 검증', () async {
      final now = DateTime.now();
      int daysUntilNextMonday = (DateTime.monday - now.weekday + 7) % 7;
      if (daysUntilNextMonday == 0) daysUntilNextMonday = 7;
      final nextMondayStart = DateTime(now.year, now.month, now.day)
          .add(Duration(days: daysUntilNextMonday));

      final h1 = Habit(
        id: 101,
        title: '주3회 물1',
        repeatType: RepeatType.weeklyCount,
        repeatCount: 3,
        reminderType: ReminderType.interval,
        reminderStartTime: '00:00',
        reminderEndTime: '23:59',
        reminderIntervalMinutes: 30,
        reminderEnabled: true,
      );
      final h2 = Habit(
        id: 102,
        title: '주3회 물2',
        repeatType: RepeatType.weeklyCount,
        repeatCount: 3,
        reminderType: ReminderType.interval,
        reminderStartTime: '00:00',
        reminderEndTime: '23:59',
        reminderIntervalMinutes: 30,
        reminderEnabled: true,
      );

      await NotificationService.rescheduleAllHabits([
        HabitWithTodayStatus(habit: h1, isCompletedToday: true, isWeeklyCompleted: true),
        HabitWithTodayStatus(habit: h2, isCompletedToday: true, isWeeklyCompleted: true),
      ]);

      expect(NotificationService.isAlarmLimitExceeded, false,
          reason: '두 습관 모두 450개 상한 이내로 안전하게 예약되어야 함');

      final h1Count = scheduledAlarms.values
          .where((a) => (a['payload'] as String).startsWith('habit_101_'))
          .length;
      final h2Count = scheduledAlarms.values
          .where((a) => (a['payload'] as String).startsWith('habit_102_'))
          .length;
      expect(h1Count >= 48, true);
      expect(h2Count >= 48, true);

      // 모든 알람이 이번 주에 울리지 않고 차주 월요일 이후에만 울리는지 검증
      for (final alarm in scheduledAlarms.values) {
        final requested = parseScheduledDate(alarm);
        final effective = simulateAndroidEffectiveFireDate(
          now,
          requested,
          alarm['matchDateTimeComponents'] as int?,
        );
        expect(effective.isBefore(nextMondayStart), false,
            reason: '주간 목표 완료 습관이 차주 월요일($nextMondayStart) 이전($effective)에 울림!');
      }
    });
  });
}
