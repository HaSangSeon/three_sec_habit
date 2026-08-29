import 'package:sqflite/sqflite.dart';
import '../constants/app_constants.dart';
import '../utils/date_util.dart';
import '../utils/streak_calculator.dart';
import '../../models/habit.dart';
import '../../models/habit_log.dart';
import '../../models/habit_with_today_status.dart';
import 'database_helper.dart';

/// 습관 및 일자별 체크 로그 데이터베이스 접근 객체 (DAO)
class HabitDao {
  final DatabaseHelper _dbHelper;

  HabitDao({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Database> get _db => _dbHelper.database;

  // ==========================================
  // 1. 습관 (Habits) CRUD
  // ==========================================

  /// 습관 등록
  Future<int> insertHabit(Habit habit) async {
    final db = await _db;
    return await db.insert(
      AppConstants.tableHabits,
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 습관 정보 수정
  Future<int> updateHabit(Habit habit) async {
    final db = await _db;
    if (habit.id == null) return 0;
    return await db.update(
      AppConstants.tableHabits,
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  /// 습관 삭제 (Cascade로 관련 habit_logs도 자동 삭제됨)
  Future<int> deleteHabit(int habitId) async {
    final db = await _db;
    return await db.delete(
      AppConstants.tableHabits,
      where: 'id = ?',
      whereArgs: [habitId],
    );
  }

  /// 특정 습관 단건 조회
  Future<Habit?> getHabitById(int habitId) async {
    final db = await _db;
    final maps = await db.query(
      AppConstants.tableHabits,
      where: 'id = ?',
      whereArgs: [habitId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Habit.fromMap(maps.first);
    }
    return null;
  }

  /// 모든 습관 목록 조회
  Future<List<Habit>> getAllHabits({bool includeArchived = false}) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableHabits,
      where: includeArchived ? null : 'is_archived = 0',
      orderBy: 'id ASC',
    );
    return maps.map((map) => Habit.fromMap(map)).toList();
  }

  // ==========================================
  // 2. 체크 기록 (Habit Logs) 처리
  // ==========================================

  /// 습관 체크 토글 (체크 또는 해제)
  /// - isCompleted == true: 레코드 삽입/갱신
  /// - isCompleted == false: 레코드 삭제
  Future<void> toggleCheck({
    required int habitId,
    required String date,
    required bool isCompleted,
  }) async {
    final db = await _db;
    if (isCompleted) {
      final log = HabitLog(
        habitId: habitId,
        date: date,
        isCompleted: true,
        completedAt: DateTime.now().toIso8601String(),
      );
      await db.insert(
        AppConstants.tableHabitLogs,
        log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await db.delete(
        AppConstants.tableHabitLogs,
        where: 'habit_id = ? AND date = ?',
        whereArgs: [habitId, date],
      );
    }
  }

  /// 특정 날짜에 완료된 습관 ID 집합 조회 (초고속 O(1) 인메모리 비교용)
  Future<Set<int>> getCompletedHabitIdsForDate(String date) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableHabitLogs,
      columns: ['habit_id'],
      where: 'date = ? AND is_completed = 1',
      whereArgs: [date],
    );
    return maps.map((m) => m['habit_id'] as int).toSet();
  }

  /// 특정 습관의 완료된 전체 날짜 집합 조회 (스트릭 계산용)
  Future<Set<String>> getCompletedDatesForHabit(int habitId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableHabitLogs,
      columns: ['date'],
      where: 'habit_id = ? AND is_completed = 1',
      whereArgs: [habitId],
      orderBy: 'date ASC',
    );
    return maps.map((m) => m['date'] as String).toSet();
  }

  // ==========================================
  // 3. 종합 뷰 및 통계 쿼리
  // ==========================================

  /// 특정 날짜 기준 전체 습관 목록과 완료 상태 + 스트릭 일괄 조회
  Future<List<HabitWithTodayStatus>> getHabitsWithStatusForDate(
      DateTime targetDate) async {
    final dateStr = DateUtil.formatDate(targetDate);
    final habits = await getAllHabits(includeArchived: false);
    final completedIds = await getCompletedHabitIdsForDate(dateStr);

    final results = <HabitWithTodayStatus>[];

    for (final habit in habits) {
      if (habit.id == null) continue;

      // 해당 날짜에 예정된 습관이거나, 이미 완료된 경우 목록에 포함
      final isScheduled = habit.isScheduledForDate(targetDate);
      final isCompleted = completedIds.contains(habit.id);

      if (isScheduled || isCompleted) {
        // 스트릭 및 달성률 계산
        final completedDates = await getCompletedDatesForHabit(habit.id!);
        final streakResult = StreakCalculator.calculate(
          habit: habit,
          completedDates: completedDates,
          referenceDate: targetDate,
        );

        results.add(HabitWithTodayStatus(
          habit: habit,
          isCompletedToday: isCompleted,
          currentStreak: streakResult.currentStreak,
          bestStreak: streakResult.bestStreak,
          totalCompletedCount: streakResult.totalCount,
          completionRate: streakResult.completionRate,
        ));
      }
    }

    return results;
  }

  /// 월간 캘린더 히트맵 데이터 조회 (날짜 -> 해당 날짜 완료된 습관 개수)
  Future<Map<String, int>> getMonthlyHeatmapLogs(int year, int month) async {
    final db = await _db;
    final startDate =
        '$year-${month.toString().padLeft(2, '0')}-01';
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    final endDate =
        '$nextYear-${nextMonth.toString().padLeft(2, '0')}-01';

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT date, COUNT(*) as count
      FROM ${AppConstants.tableHabitLogs}
      WHERE is_completed = 1 AND date >= ? AND date < ?
      GROUP BY date
    ''', [startDate, endDate]);

    final result = <String, int>{};
    for (final row in maps) {
      final date = row['date'] as String;
      final count = (row['count'] as num).toInt();
      result[date] = count;
    }
    return result;
  }

  /// 특정 습관의 월별 완료 날짜 집합 조회
  Future<Set<String>> getHabitCompletedDatesForMonth(
      int habitId, int year, int month) async {
    final db = await _db;
    final startDate =
        '$year-${month.toString().padLeft(2, '0')}-01';
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    final endDate =
        '$nextYear-${nextMonth.toString().padLeft(2, '0')}-01';

    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableHabitLogs,
      columns: ['date'],
      where: 'habit_id = ? AND is_completed = 1 AND date >= ? AND date < ?',
      whereArgs: [habitId, startDate, endDate],
    );

    return maps.map((m) => m['date'] as String).toSet();
  }
}
