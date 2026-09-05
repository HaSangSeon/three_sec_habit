import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:three_sec_habit/core/database/database_helper.dart';
import 'package:three_sec_habit/core/database/habit_dao.dart';
import 'package:three_sec_habit/models/habit.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late HabitDao habitDao;

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

          await db.execute('''
            CREATE INDEX idx_habit_logs_date
            ON habit_logs (date)
          ''');
        },
      ),
    );

    DatabaseHelper.setDatabaseForTesting(db);
    habitDao = HabitDao();
  });

  tearDown(() async {
    await db.close();
    DatabaseHelper.resetForTesting();
  });

  group('HabitDao SQLite 데이터베이스 테스트', () {
    test('1. 습관 추가 및 단건/전체 조회', () async {
      final habit1 = Habit(
        title: '아침 기상 물 한 잔',
        iconName: 'water_drop',
        colorValue: 0xFF06B6D4,
        habitType: HabitType.count,
        targetCount: 8,
        unit: '잔',
        repeatType: RepeatType.daily,
        reminderType: ReminderType.interval,
        reminderIntervalMinutes: 60,
      );

      final id1 = await habitDao.insertHabit(habit1);
      expect(id1, isPositive);

      final fetched = await habitDao.getHabitById(id1);
      expect(fetched, isNotNull);
      expect(fetched!.title, '아침 기상 물 한 잔');
      expect(fetched.iconName, 'water_drop');
      expect(fetched.habitType, HabitType.count);
      expect(fetched.targetCount, 8);
      expect(fetched.unit, '잔');
      expect(fetched.reminderType, ReminderType.interval);
      expect(fetched.reminderIntervalMinutes, 60);

      final all = await habitDao.getAllHabits();
      expect(all.length, 1);
    });

    test('2. 습관 수정 및 삭제 (Cascade 로그 삭제 검증)', () async {
      final habit = Habit(title: '임시 습관');
      final id = await habitDao.insertHabit(habit);

      final updated = habit.copyWith(id: id, title: '수정된 습관');
      await habitDao.updateHabit(updated);

      final fetched = await habitDao.getHabitById(id);
      expect(fetched!.title, '수정된 습관');

      await habitDao.toggleCheck(
          habitId: id, date: '2026-08-29', isCompleted: true);
      final logsBefore = await habitDao.getCompletedDatesForHabit(id);
      expect(logsBefore.length, 1);

      await habitDao.deleteHabit(id);
      final fetchedAfter = await habitDao.getHabitById(id);
      expect(fetchedAfter, isNull);

      final logsAfter = await habitDao.getCompletedDatesForHabit(id);
      expect(logsAfter.isEmpty, isTrue);
    });

    test('3. 오늘 체크 토글 (체크 -> 해제 -> 재체크)', () async {
      final id = await habitDao.insertHabit(Habit(title: '영양제 먹기'));
      const date = '2026-08-29';

      await habitDao.toggleCheck(
          habitId: id, date: date, isCompleted: true);
      var completedIds = await habitDao.getCompletedHabitIdsForDate(date);
      expect(completedIds.contains(id), isTrue);

      await habitDao.toggleCheck(
          habitId: id, date: date, isCompleted: false);
      completedIds = await habitDao.getCompletedHabitIdsForDate(date);
      expect(completedIds.contains(id), isFalse);

      await habitDao.toggleCheck(
          habitId: id, date: date, isCompleted: true);
      completedIds = await habitDao.getCompletedHabitIdsForDate(date);
      expect(completedIds.contains(id), isTrue);
    });

    test('4. 카운트형 습관(물 8잔) 카운트 증감 및 목표 달성 판정 검증', () async {
      final id = await habitDao.insertHabit(Habit(
        title: '물 8잔 마시기',
        habitType: HabitType.count,
        targetCount: 8,
        unit: '잔',
      ));
      const date = '2026-08-29';

      // 1. 물 3잔 마심 -> 미완료
      await habitDao.setHabitCount(
          habitId: id, date: date, count: 3, targetCount: 8);
      var log = await habitDao.getHabitLogForDate(id, date);
      expect(log, isNotNull);
      expect(log!.count, 3);
      expect(log.isCompleted, isFalse);

      var completedIds = await habitDao.getCompletedHabitIdsForDate(date);
      expect(completedIds.contains(id), isFalse);

      // 2. 물 8잔 마심 -> 완료
      await habitDao.setHabitCount(
          habitId: id, date: date, count: 8, targetCount: 8);
      log = await habitDao.getHabitLogForDate(id, date);
      expect(log!.count, 8);
      expect(log.isCompleted, isTrue);

      completedIds = await habitDao.getCompletedHabitIdsForDate(date);
      expect(completedIds.contains(id), isTrue);
    });

    test('5. 월간 히트맵 잔디밭 데이터 집계 쿼리 검증', () async {
      final id1 = await habitDao.insertHabit(Habit(title: '습관 1'));
      final id2 = await habitDao.insertHabit(Habit(title: '습관 2'));

      await habitDao.toggleCheck(
          habitId: id1, date: '2026-08-10', isCompleted: true);
      await habitDao.toggleCheck(
          habitId: id1, date: '2026-08-15', isCompleted: true);
      await habitDao.toggleCheck(
          habitId: id2, date: '2026-08-15', isCompleted: true);

      final heatmap = await habitDao.getMonthlyHeatmapLogs(2026, 8);
      expect(heatmap['2026-08-10'], 1);
      expect(heatmap['2026-08-15'], 2);
      expect(heatmap['2026-08-20'], isNull);
    });

    test('6. 습관 형태 및 목표 횟수 변경 시 당일 로그 정합성 동기화 및 과거 보존 검증', () async {
      // 1) 단순 체크형 습관 생성 후 오늘 완료 처리
      final habit = Habit(
        title: '독서하기',
        habitType: HabitType.check,
        targetCount: 1,
      );
      final id = await habitDao.insertHabit(habit);
      const today = '2026-08-30';
      const pastDay = '2026-08-29';

      // 과거일 완료 처리 (스트릭용)
      await habitDao.toggleCheck(habitId: id, date: pastDay, isCompleted: true);
      // 오늘 완료 처리 (1회 완료)
      await habitDao.toggleCheck(habitId: id, date: today, isCompleted: true);

      var todayLog = await habitDao.getHabitLogForDate(id, today);
      expect(todayLog!.count, 1);
      expect(todayLog.isCompleted, isTrue);

      // 2) 습관을 목표 5회형으로 변경
      final countHabit = habit.copyWith(
        id: id,
        habitType: HabitType.count,
        targetCount: 5,
        unit: '쪽',
      );
      await habitDao.updateHabit(countHabit, targetDate: today);

      // 오늘의 로그: 1/5회이므로 isCompleted가 false(미완료)로 자동 동기화되어야 함!
      todayLog = await habitDao.getHabitLogForDate(id, today);
      expect(todayLog!.count, 1);
      expect(todayLog.isCompleted, isFalse);

      // 과거일의 로그: 이전 룰에 의해 완료되었던 과거 기록은 true로 안전하게 보존되어야 함!
      final pastLog = await habitDao.getHabitLogForDate(id, pastDay);
      expect(pastLog!.isCompleted, isTrue);

      // 뷰모델 상태 조회 검증
      final statusList = await habitDao.getHabitsWithStatusForDate(DateTime(2026, 8, 30));
      final status = statusList.firstWhere((s) => s.habit.id == id);
      expect(status.todayCount, 1);
      expect(status.isCompletedToday, isFalse); // 초록 체크가 아니라 미완료여야 함!

      // 3) 반대 케이스: 횟수형에서 2회 진행 중 단순 체크형으로 변경 시 완료로 승격
      await habitDao.setHabitCount(habitId: id, date: today, count: 2, targetCount: 5);
      todayLog = await habitDao.getHabitLogForDate(id, today);
      expect(todayLog!.isCompleted, isFalse); // 2/5회라 아직 미완료

      final checkHabit = habit.copyWith(
        id: id,
        habitType: HabitType.check,
        targetCount: 1,
      );
      await habitDao.updateHabit(checkHabit, targetDate: today);

      // 단순 체크형 기준 1회 이상 했으므로 isCompleted가 true로 자동 동기화되어야 함!
      todayLog = await habitDao.getHabitLogForDate(id, today);
      expect(todayLog!.isCompleted, isTrue);

      final statusList2 = await habitDao.getHabitsWithStatusForDate(DateTime(2026, 8, 30));
      final status2 = statusList2.firstWhere((s) => s.habit.id == id);
      expect(status2.isCompletedToday, isTrue);
    });
  });
}
