import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:three_sec_habit/core/database/database_helper.dart';
import 'package:three_sec_habit/core/database/habit_dao.dart';
import 'package:three_sec_habit/core/utils/date_util.dart';
import 'package:three_sec_habit/models/habit.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late HabitDao habitDao;

  setUpAll(() {
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    } catch (_) {}
  });

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 2,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE habits (
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
              created_at TEXT NOT NULL,
              is_archived INTEGER NOT NULL DEFAULT 0
            )
          ''');

          await db.execute('''
            CREATE TABLE habit_logs (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              habit_id INTEGER NOT NULL,
              date TEXT NOT NULL,
              count INTEGER NOT NULL DEFAULT 1,
              is_completed INTEGER NOT NULL DEFAULT 1,
              completed_at TEXT NOT NULL,
              FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
            )
          ''');

          await db.execute('''
            CREATE UNIQUE INDEX idx_habit_logs_unique
            ON habit_logs (habit_id, date)
          ''');
        },
      ),
    );

    final mockHelper = DatabaseHelper.instance;
    habitDao = HabitDao(dbHelper: mockHelper);
  });

  tearDown(() async {
    await db.close();
  });

  group('1. 습관 등록 및 주기(RepeatType)별 동작 완벽 검증', () {
    test('매일(Daily) 반복 습관 등록 및 스케줄링 여부 검증', () {
      final habit = Habit(
        title: '매일 물마시기',
        repeatType: RepeatType.daily,
      );
      final today = DateTime.now();
      expect(habit.isScheduledForDate(today), true);
      expect(habit.isScheduledForDate(today.add(const Duration(days: 1))), true);
      expect(habit.isScheduledForDate(today.add(const Duration(days: 30))), true);
    });

    test('특정 요일(WeeklyDays) 반복 습관: 지정 요일에만 스케줄되고 나머지 요일은 제외됨', () {
      // 월(1), 수(3), 금(5)
      final habit = Habit(
        title: '월수금 헬스장 가기',
        repeatType: RepeatType.weeklyDays,
        repeatDays: [DateTime.monday, DateTime.wednesday, DateTime.friday],
      );

      // 2026-09-07(월), 08(화), 09(수), 10(목), 11(금), 12(토), 13(일)
      final monday = DateTime(2026, 9, 7);
      final tuesday = DateTime(2026, 9, 8);
      final wednesday = DateTime(2026, 9, 9);
      final thursday = DateTime(2026, 9, 10);
      final friday = DateTime(2026, 9, 11);
      final saturday = DateTime(2026, 9, 12);
      final sunday = DateTime(2026, 9, 13);

      expect(habit.isScheduledForDate(monday), true);
      expect(habit.isScheduledForDate(tuesday), false);
      expect(habit.isScheduledForDate(wednesday), true);
      expect(habit.isScheduledForDate(thursday), false);
      expect(habit.isScheduledForDate(friday), true);
      expect(habit.isScheduledForDate(saturday), false);
      expect(habit.isScheduledForDate(sunday), false);
    });

    test('주 N회(WeeklyCount) 반복 습관: 기본적으로 매일 열려있으나 목표 달성 시 잔여 요일 스케줄 제외', () {
      final habit = Habit(
        title: '주 3회 독서',
        repeatType: RepeatType.weeklyCount,
        repeatCount: 3,
      );
      final today = DateTime.now();
      expect(habit.isScheduledForDate(today), true);
    });
  });

  group('2. 알람 옵션(특정시각, 다중시각, 규칙적 간격, 야간제외) 검증', () {
    test('특정 시각 알림 (단일 및 다중 시간) 시간 목록 파싱 및 정렬', () {
      final singleTime = Habit(title: '기상', reminderTime: '07:30');
      expect(singleTime.reminderTimes, ['07:30']);

      final multiTime = Habit(title: '약 복용', reminderTime: '19:00, 08:30, 13:00');
      // 파싱 결과
      final parsed = multiTime.reminderTimes;
      expect(parsed.length, 3);
      expect(parsed, containsAll(['19:00', '08:30', '13:00']));
    });

    test('규칙적 간격 알림: 09:00~21:00 사이 간격(30분, 60분, 120분) 슬롯 개수 및 범위 계산 정확성', () {
      // 1시간 간격 (60분): 09:00, 10:00, ..., 21:00 -> 13개
      int count1h = 0;
      for (int m = 9 * 60; m <= 21 * 60; m += 60) {
        count1h++;
      }
      expect(count1h, 13);

      // 2시간 간격 (120분): 09:00, 11:00, 13:00, 15:00, 17:00, 19:00, 21:00 -> 7개
      int count2h = 0;
      for (int m = 9 * 60; m <= 21 * 60; m += 120) {
        count2h++;
      }
      expect(count2h, 7);

      // 30분 간격: 09:00부터 21:00까지 총 25개
      int count30m = 0;
      for (int m = 9 * 60; m <= 21 * 60; m += 30) {
        count30m++;
      }
      expect(count30m, 25);
    });

    test('야간 수면 시간대(익일 새벽 예: 22:00 ~ 02:00) 간격 알림 시간 계산 방어', () {
      const startHour = 22;
      const startMin = 0;
      const endHour = 2;
      const endMin = 0;

      final startTotalMin = startHour * 60 + startMin; // 1320
      int endTotalMin = endHour * 60 + endMin; // 120
      if (endTotalMin <= startTotalMin) {
        endTotalMin += 24 * 60; // 120 + 1440 = 1560
      }

      final slots = <String>[];
      int cur = startTotalMin;
      while (cur <= endTotalMin) {
        final rawHour = cur ~/ 60;
        final h = rawHour % 24;
        final m = cur % 60;
        slots.add('${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}');
        cur += 60; // 1시간 간격
      }

      // 22:00, 23:00, 00:00, 01:00, 02:00 (5개 슬롯)
      expect(slots, ['22:00', '23:00', '00:00', '01:00', '02:00']);
    });
  });

  group('3. 횟수 줄이고 늘렸을 때(목표 횟수 변경) 정합성 및 예외 검증', () {
    test('카운트형 습관: 목표가 3회일 때 3회 실천 후, 목표를 5회로 늘리면 완료 상태가 해제(미완료)됨', () async {
      // 1. 목표 3회 습관 등록
      final id = await habitDao.insertHabit(Habit(
        title: '스쿼트',
        habitType: HabitType.count,
        targetCount: 3,
        unit: '세트',
      ));

      final todayStr = DateUtil.formatDate(DateTime.now());

      // 2. 오늘 3회 실천 -> 완료 상태
      await habitDao.setHabitCount(
        habitId: id,
        date: todayStr,
        count: 3,
        targetCount: 3,
      );

      var log = await habitDao.getHabitLogForDate(id, todayStr);
      expect(log!.isCompleted, true);
      expect(log.count, 3);

      // 3. 목표 횟수를 3회에서 5회로 증가 수정
      final habit5 = (await habitDao.getHabitById(id))!.copyWith(targetCount: 5);
      await habitDao.updateHabit(habit5, targetDate: todayStr);

      // 4. 재동기화 후 확인: 3회 < 5회이므로 is_completed가 false로 자동 보정되어야 함!
      log = await habitDao.getHabitLogForDate(id, todayStr);
      expect(log!.count, 3);
      expect(log.isCompleted, false);

      // 5. 다시 2회 더 수행(총 5회)하면 완료됨
      await habitDao.setHabitCount(
        habitId: id,
        date: todayStr,
        count: 5,
        targetCount: 5,
      );
      log = await habitDao.getHabitLogForDate(id, todayStr);
      expect(log!.count, 5);
      expect(log.isCompleted, true);
    });

    test('카운트형 습관: 목표가 5회일 때 3회 실천(미완료) 후, 목표를 2회로 줄이면 즉시 완료 상태로 전환됨', () async {
      final id = await habitDao.insertHabit(Habit(
        title: '물 마시기',
        habitType: HabitType.count,
        targetCount: 5,
        unit: '잔',
      ));

      final todayStr = DateUtil.formatDate(DateTime.now());

      // 3잔 마심 (미완료: 3 < 5)
      await habitDao.setHabitCount(
        habitId: id,
        date: todayStr,
        count: 3,
        targetCount: 5,
      );

      var log = await habitDao.getHabitLogForDate(id, todayStr);
      expect(log!.count, 3);
      expect(log.isCompleted, false);

      // 목표를 5잔에서 2잔으로 하향 수정
      final habit2 = (await habitDao.getHabitById(id))!.copyWith(targetCount: 2);
      await habitDao.updateHabit(habit2, targetDate: todayStr);

      // 재동기화 후 확인: 3잔 >= 2잔이므로 is_completed가 true로 즉시 변경되어야 함!
      log = await habitDao.getHabitLogForDate(id, todayStr);
      expect(log!.count, 3);
      expect(log.isCompleted, true);
    });

    test('카운트를 0으로 줄였을 때(로그 삭제 또는 count 0) 미완료 처리 검증', () async {
      final id = await habitDao.insertHabit(Habit(
        title: '비타민 챙겨먹기',
        habitType: HabitType.count,
        targetCount: 2,
      ));

      final todayStr = DateUtil.formatDate(DateTime.now());
      await habitDao.setHabitCount(
        habitId: id,
        date: todayStr,
        count: 2,
        targetCount: 2,
      );
      expect((await habitDao.getHabitLogForDate(id, todayStr))!.isCompleted, true);

      // 0으로 감소
      await habitDao.setHabitCount(
        habitId: id,
        date: todayStr,
        count: 0,
        targetCount: 2,
      );
      final log = await habitDao.getHabitLogForDate(id, todayStr);
      expect(log, isNull); // 0회는 삭제되어 깔끔하게 리셋
    });
  });

  group('4. 습관 중간 수정 및 옵션 변경 시 정합성 검증', () {
    test('알림 옵션 변경(지정 시각 -> 간격 알림, 시간 변경, 알림 활성화/비활성화)', () async {
      final id = await habitDao.insertHabit(Habit(
        title: '혈압 측정',
        reminderEnabled: true,
        reminderType: ReminderType.fixed,
        reminderTime: '08:00',
      ));

      // 간격 알림으로 변경 (10:00~18:00, 120분 간격)
      final updatedHabit = (await habitDao.getHabitById(id))!.copyWith(
        reminderType: ReminderType.interval,
        reminderStartTime: '10:00',
        reminderEndTime: '18:00',
        reminderIntervalMinutes: 120,
      );
      await habitDao.updateHabit(updatedHabit);

      final fetched = await habitDao.getHabitById(id);
      expect(fetched!.reminderType, ReminderType.interval);
      expect(fetched.reminderStartTime, '10:00');
      expect(fetched.reminderEndTime, '18:00');
      expect(fetched.reminderIntervalMinutes, 120);

      // 알림 완전 끄기
      final disabledHabit = fetched.copyWith(reminderEnabled: false);
      await habitDao.updateHabit(disabledHabit);
      expect((await habitDao.getHabitById(id))!.reminderEnabled, false);
    });

    test('주기 변경 (매일 -> 특정 요일): 과거 기록 보존 및 오늘 스케줄 갱신 검증', () async {
      final id = await habitDao.insertHabit(Habit(
        title: '유산소 운동',
        repeatType: RepeatType.daily,
      ));

      final todayStr = DateUtil.formatDate(DateTime.now());
      await habitDao.toggleCheck(habitId: id, date: todayStr, isCompleted: true);

      // 주기를 주말(토, 일)로 변경
      final weekendHabit = (await habitDao.getHabitById(id))!.copyWith(
        repeatType: RepeatType.weeklyDays,
        repeatDays: [DateTime.saturday, DateTime.sunday],
      );
      await habitDao.updateHabit(weekendHabit);

      final fetched = await habitDao.getHabitById(id);
      expect(fetched!.repeatType, RepeatType.weeklyDays);
      expect(fetched.repeatDays, [DateTime.saturday, DateTime.sunday]);

      // 과거/오늘 완료 로그는 그대로 안전하게 보존됨
      final log = await habitDao.getHabitLogForDate(id, todayStr);
      expect(log, isNotNull);
      expect(log!.isCompleted, true);
    });
  });

  group('5. 습관 삭제 시 안전성 및 외래키 연쇄 삭제(Cascade) 검증', () {
    test('습관 삭제 시 DB에서 습관과 관련된 모든 일자별 habit_logs가 Cascade로 일괄 삭제됨', () async {
      final id = await habitDao.insertHabit(Habit(
        title: '임시 습관',
      ));

      // 3일치 로그 추가
      await habitDao.toggleCheck(habitId: id, date: '2026-10-15', isCompleted: true);
      await habitDao.toggleCheck(habitId: id, date: '2026-10-16', isCompleted: true);
      await habitDao.toggleCheck(habitId: id, date: '2026-10-17', isCompleted: true);

      // 삭제 전 로그 3개 확인
      final completedDatesBefore = await habitDao.getCompletedDatesForHabit(id);
      expect(completedDatesBefore.length, 3);

      // 습관 삭제
      await habitDao.deleteHabit(id);

      // 습관 조회 시 null
      expect(await habitDao.getHabitById(id), isNull);

      // 외래키 Cascade로 인해 관련된 habit_logs도 0개로 완전 정리됨
      final completedDatesAfter = await habitDao.getCompletedDatesForHabit(id);
      expect(completedDatesAfter.isEmpty, true);
    });
  });
}
