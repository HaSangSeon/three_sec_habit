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
  // 2. 체크 및 카운트 기록 (Habit Logs) 처리
  // ==========================================

  /// 특정 습관의 특정 날짜 로그 조회
  Future<HabitLog?> getHabitLogForDate(int habitId, String date) async {
    final db = await _db;
    final maps = await db.query(
      AppConstants.tableHabitLogs,
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, date],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return HabitLog.fromMap(maps.first);
    }
    return null;
  }

  /// 습관 체크 토글 (체크 또는 해제)
  Future<void> toggleCheck({
    required int habitId,
    required String date,
    required bool isCompleted,
    int targetCount = 1,
  }) async {
    final db = await _db;
    if (isCompleted) {
      final log = HabitLog(
        habitId: habitId,
        date: date,
        count: targetCount,
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

  /// 카운트형 습관 수치 직접 설정 (물 1잔, 2잔 등)
  Future<void> setHabitCount({
    required int habitId,
    required String date,
    required int count,
    required int targetCount,
  }) async {
    final db = await _db;
    if (count <= 0) {
      await db.delete(
        AppConstants.tableHabitLogs,
        where: 'habit_id = ? AND date = ?',
        whereArgs: [habitId, date],
      );
    } else {
      final isCompleted = count >= targetCount;
      final log = HabitLog(
        habitId: habitId,
        date: date,
        count: count,
        isCompleted: isCompleted,
        completedAt: DateTime.now().toIso8601String(),
      );
      await db.insert(
        AppConstants.tableHabitLogs,
        log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// 특정 날짜에 완료된(목표 달성) 습관 ID 집합 조회
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

  /// 특정 날짜의 모든 습관 로그 맵 조회 (habitId -> HabitLog)
  Future<Map<int, HabitLog>> getHabitLogsMapForDate(String date) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableHabitLogs,
      where: 'date = ?',
      whereArgs: [date],
    );
    final result = <int, HabitLog>{};
    for (final map in maps) {
      final log = HabitLog.fromMap(map);
      result[log.habitId] = log;
    }
    return result;
  }

  /// 특정 습관의 목표를 완료한 전체 날짜 집합 조회 (스트릭 계산용)
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

  /// 특정 날짜 기준 전체 습관 목록과 완료 상태 + 카운트 + 스트릭 일괄 조회
  Future<List<HabitWithTodayStatus>> getHabitsWithStatusForDate(
      DateTime targetDate) async {
    final dateStr = DateUtil.formatDate(targetDate);
    final habits = await getAllHabits(includeArchived: false);
    final logsMap = await getHabitLogsMapForDate(dateStr);

    final results = <HabitWithTodayStatus>[];

    for (final habit in habits) {
      if (habit.id == null) continue;

      final log = logsMap[habit.id];
      final isScheduled = habit.isScheduledForDate(targetDate);
      final todayCount = log?.count ?? 0;
      final isCompleted = log?.isCompleted ?? false;

      // 스트릭 및 달성률 계산
      final completedDates = await getCompletedDatesForHabit(habit.id!);
      final streakResult = StreakCalculator.calculate(
        habit: habit,
        completedDates: completedDates,
        referenceDate: targetDate,
      );

      results.add(HabitWithTodayStatus(
        habit: habit,
        todayCount: todayCount,
        isCompletedToday: isCompleted,
        isScheduledToday: isScheduled,
        currentStreak: streakResult.currentStreak,
        bestStreak: streakResult.bestStreak,
        totalCompletedCount: streakResult.totalCount,
        completionRate: streakResult.completionRate,
      ));
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
    for (final map in maps) {
      result[map['date'] as String] = map['count'] as int;
    }
    return result;
  }

  /// 특정 날짜에 완료된 습관 목록 조회 (로그 정보 포함)
  Future<List<Map<String, dynamic>>> getCompletedHabitsForDate(String dateStr) async {
    final db = await _db;
    final sql = '''
      SELECT 
        h.id, h.title, h.icon_name, h.color_value, h.habit_type, h.target_count, h.unit,
        h.repeat_type, h.repeat_days, h.repeat_count,
        l.count as log_count, l.is_completed as log_completed, l.completed_at
      FROM ${AppConstants.tableHabits} h
      INNER JOIN ${AppConstants.tableHabitLogs} l
        ON h.id = l.habit_id
      WHERE l.date = ? AND l.is_completed = 1 AND h.is_archived = 0
      ORDER BY h.id ASC
    ''';
    return await db.rawQuery(sql, [dateStr]);
  }

  /// 요일별 완료 집계 통계 (1: 월요일 ~ 7: 일요일)
  Future<Map<int, int>> getDayOfWeekStats() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableHabitLogs,
      columns: ['date'],
      where: 'is_completed = 1',
    );
    final stats = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    for (final map in maps) {
      final dateStr = map['date'] as String?;
      if (dateStr != null) {
        final d = DateTime.tryParse(dateStr);
        if (d != null) {
          stats[d.weekday] = (stats[d.weekday] ?? 0) + 1;
        }
      }
    }
    return stats;
  }

  /// 월간 요약 데이터 조회 (해당 월 총 실천 수, 최다 실천 습관 등)
  Future<Map<String, dynamic>> getMonthlyOverviewStats(int year, int month) async {
    final db = await _db;
    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    final endDate = '$nextYear-${nextMonth.toString().padLeft(2, '0')}-01';

    // 해당 월 총 완료 횟수
    final countResult = await db.rawQuery('''
      SELECT COUNT(*) as total
      FROM ${AppConstants.tableHabitLogs}
      WHERE is_completed = 1 AND date >= ? AND date < ?
    ''', [startDate, endDate]);
    final totalCount = (countResult.first['total'] as int?) ?? 0;

    // 해당 월 최다 실천 습관
    final topHabitResult = await db.rawQuery('''
      SELECT h.title, h.icon_name, h.color_value, COUNT(l.id) as completion_count
      FROM ${AppConstants.tableHabits} h
      INNER JOIN ${AppConstants.tableHabitLogs} l ON h.id = l.habit_id
      WHERE l.is_completed = 1 AND l.date >= ? AND l.date < ?
      GROUP BY h.id
      ORDER BY completion_count DESC
      LIMIT 1
    ''', [startDate, endDate]);

    Map<String, dynamic>? topHabit;
    if (topHabitResult.isNotEmpty) {
      topHabit = topHabitResult.first;
    }

    return {
      'totalCompletions': totalCount,
      'topHabit': topHabit,
    };
  }
}
