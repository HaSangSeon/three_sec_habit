import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:three_sec_habit/core/database/database_helper.dart';
import 'package:three_sec_habit/core/database/habit_dao.dart';
import 'package:three_sec_habit/models/habit.dart';

void main() {
  // sqflite_common_ffi 초기화
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late HabitDao habitDao;

  setUp(() async {
    // 인메모리 SQLite DB 생성
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
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
              repeat_type TEXT NOT NULL DEFAULT 'daily',
              repeat_days TEXT,
              repeat_count INTEGER,
              reminder_time TEXT,
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
        repeatType: RepeatType.daily,
      );

      final id1 = await habitDao.insertHabit(habit1);
      expect(id1, isPositive);

      final fetched = await habitDao.getHabitById(id1);
      expect(fetched, isNotNull);
      expect(fetched!.title, '아침 기상 물 한 잔');
      expect(fetched.iconName, 'water_drop');
      expect(fetched.repeatType, RepeatType.daily);

      final all = await habitDao.getAllHabits();
      expect(all.length, 1);
    });

    test('2. 습관 수정 및 삭제 (Cascade 로그 삭제 검증)', () async {
      final habit = Habit(title: '임시 습관');
      final id = await habitDao.insertHabit(habit);

      // 수정
      final updated = habit.copyWith(id: id, title: '수정된 습관');
      await habitDao.updateHabit(updated);

      final fetched = await habitDao.getHabitById(id);
      expect(fetched!.title, '수정된 습관');

      // 체크 로그 추가
      await habitDao.toggleCheck(habitId: id, date: '2026-08-29', isCompleted: true);
      final logsBefore = await habitDao.getCompletedDatesForHabit(id);
      expect(logsBefore.length, 1);

      // 습관 삭제 시 Cascade로 로그도 함께 자동 삭제되는지 확인
      await habitDao.deleteHabit(id);
      final fetchedAfter = await habitDao.getHabitById(id);
      expect(fetchedAfter, isNull);

      final logsAfter = await habitDao.getCompletedDatesForHabit(id);
      expect(logsAfter.isEmpty, isTrue);
    });

    test('3. 오늘 체크 토글 (체크 -> 해제 -> 재체크)', () async {
      final id = await habitDao.insertHabit(Habit(title: '영양제 먹기'));
      const date = '2026-08-29';

      // 체크
      await habitDao.toggleCheck(habitId: id, date: date, isCompleted: true);
      var completedIds = await habitDao.getCompletedHabitIdsForDate(date);
      expect(completedIds.contains(id), isTrue);

      // 체크 해제
      await habitDao.toggleCheck(habitId: id, date: date, isCompleted: false);
      completedIds = await habitDao.getCompletedHabitIdsForDate(date);
      expect(completedIds.contains(id), isFalse);

      // 재체크 (중복 insert 에러 없이 정상 처리되는지)
      await habitDao.toggleCheck(habitId: id, date: date, isCompleted: true);
      completedIds = await habitDao.getCompletedHabitIdsForDate(date);
      expect(completedIds.contains(id), isTrue);
    });

    test('4. 월간 히트맵 잔디밭 데이터 집계 쿼리 검증', () async {
      final id1 = await habitDao.insertHabit(Habit(title: '습관 1'));
      final id2 = await habitDao.insertHabit(Habit(title: '습관 2'));

      // 8월 10일에 습관1 완료
      await habitDao.toggleCheck(habitId: id1, date: '2026-08-10', isCompleted: true);
      // 8월 15일에 습관1, 2 둘 다 완료
      await habitDao.toggleCheck(habitId: id1, date: '2026-08-15', isCompleted: true);
      await habitDao.toggleCheck(habitId: id2, date: '2026-08-15', isCompleted: true);

      final heatmap = await habitDao.getMonthlyHeatmapLogs(2026, 8);
      expect(heatmap['2026-08-10'], 1);
      expect(heatmap['2026-08-15'], 2);
      expect(heatmap['2026-08-20'], isNull);
    });
  });
}
