import '../../models/habit.dart';
import 'date_util.dart';

/// 스트릭 계산 결과
class StreakResult {
  final int currentStreak;
  final int bestStreak;
  final int totalCount;
  final double completionRate;

  const StreakResult({
    required this.currentStreak,
    required this.bestStreak,
    required this.totalCount,
    required this.completionRate,
  });
}

/// 주기별(매일 / 특정 요일 / 주 N회) 연속 달성일수(스트릭) 계산 엔진
class StreakCalculator {
  StreakCalculator._();

  /// 습관과 완료된 날짜 목록(Set of 'YYYY-MM-DD')을 기반으로 스트릭 계산
  static StreakResult calculate({
    required Habit habit,
    required Set<String> completedDates,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();

    if (completedDates.isEmpty) {
      return const StreakResult(
        currentStreak: 0,
        bestStreak: 0,
        totalCount: 0,
        completionRate: 0.0,
      );
    }

    final totalCount = completedDates.length;

    // 생성일부터 오늘까지의 총 예정 일수 계산 (완료율용)
    final createdDate = DateTime.tryParse(habit.createdAt) ?? now;
    final normalizedCreated = DateTime(createdDate.year, createdDate.month, createdDate.day);
    final normalizedToday = DateTime(now.year, now.month, now.day);
    
    int totalScheduledDays = 0;
    DateTime temp = normalizedCreated;
    while (!temp.isAfter(normalizedToday)) {
      if (habit.isScheduledForDate(temp)) {
        totalScheduledDays++;
      }
      temp = temp.add(const Duration(days: 1));
    }
    if (totalScheduledDays == 0) totalScheduledDays = 1;
    final rate = (totalCount / totalScheduledDays).clamp(0.0, 1.0);

    switch (habit.repeatType) {
      case RepeatType.daily:
        return _calculateDaily(completedDates, now, totalCount, rate);
      case RepeatType.weeklyDays:
        return _calculateWeeklyDays(habit, completedDates, now, totalCount, rate);
      case RepeatType.weeklyCount:
        return _calculateWeeklyCount(habit, completedDates, now, totalCount, rate);
    }
  }

  /// 1) 매일(daily) 습관 스트릭 계산
  static StreakResult _calculateDaily(
    Set<String> completedDates,
    DateTime now,
    int totalCount,
    double completionRate,
  ) {
    final todayStr = DateUtil.formatDate(now);
    final isTodayDone = completedDates.contains(todayStr);

    int currentStreak = 0;
    // 오늘 완료했으면 오늘부터, 아니면 어제부터 역방향 탐색
    DateTime checkDate = isTodayDone
        ? now
        : now.subtract(const Duration(days: 1));

    while (true) {
      final dateStr = DateUtil.formatDate(checkDate);
      if (completedDates.contains(dateStr)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    // 역대 최장 스트릭(Best Streak) 계산
    final sortedDates = completedDates.map(DateUtil.parseDate).toList()..sort();
    int bestStreak = 0;
    int tempStreak = 0;
    DateTime? prevDate;

    for (final d in sortedDates) {
      final cur = DateTime(d.year, d.month, d.day);
      if (prevDate == null) {
        tempStreak = 1;
      } else {
        final diff = cur.difference(prevDate).inDays;
        if (diff == 1) {
          tempStreak++;
        } else if (diff > 1) {
          tempStreak = 1;
        }
      }
      if (tempStreak > bestStreak) {
        bestStreak = tempStreak;
      }
      prevDate = cur;
    }

    if (currentStreak > bestStreak) {
      bestStreak = currentStreak;
    }

    return StreakResult(
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      totalCount: totalCount,
      completionRate: completionRate,
    );
  }

  /// 2) 특정 요일(weeklyDays) 습관 스트릭 계산
  static StreakResult _calculateWeeklyDays(
    Habit habit,
    Set<String> completedDates,
    DateTime now,
    int totalCount,
    double completionRate,
  ) {
    final todayStr = DateUtil.formatDate(now);
    final isTodayScheduled = habit.repeatDays.contains(now.weekday);
    final isTodayDone = completedDates.contains(todayStr);

    int currentStreak = 0;
    DateTime checkDate = now;

    // 오늘이 예정일인데 아직 안 했거나, 오늘이 예정일이 아닌 경우 이전 예정일부터 검사
    if (isTodayScheduled && !isTodayDone) {
      checkDate = _getPreviousScheduledDate(habit, now);
    } else if (!isTodayScheduled) {
      checkDate = _getPreviousScheduledDate(habit, now);
    }

    while (true) {
      final dateStr = DateUtil.formatDate(checkDate);
      if (completedDates.contains(dateStr)) {
        currentStreak++;
        checkDate = _getPreviousScheduledDate(habit, checkDate);
      } else {
        break;
      }
    }

    // 최장 스트릭 계산
    final sortedDates = completedDates.map(DateUtil.parseDate).toList()..sort();
    int bestStreak = 0;
    int tempStreak = 0;
    DateTime? prevScheduled;

    for (final d in sortedDates) {
      if (!habit.repeatDays.contains(d.weekday)) continue;
      final cur = DateTime(d.year, d.month, d.day);

      if (prevScheduled == null) {
        tempStreak = 1;
      } else {
        final expectedPrev = _getPreviousScheduledDate(habit, cur);
        final normalizedExpected = DateTime(expectedPrev.year, expectedPrev.month, expectedPrev.day);
        if (normalizedExpected.isAtSameMomentAs(prevScheduled)) {
          tempStreak++;
        } else {
          tempStreak = 1;
        }
      }
      if (tempStreak > bestStreak) {
        bestStreak = tempStreak;
      }
      prevScheduled = cur;
    }

    if (currentStreak > bestStreak) {
      bestStreak = currentStreak;
    }

    return StreakResult(
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      totalCount: totalCount,
      completionRate: completionRate,
    );
  }

  /// 3) 주 N회(weeklyCount) 습관 스트릭 계산
  static StreakResult _calculateWeeklyCount(
    Habit habit,
    Set<String> completedDates,
    DateTime now,
    int totalCount,
    double completionRate,
  ) {
    final targetCount = habit.repeatCount ?? 1;

    // 주(Week: 월요일 시작)별 완료 횟수 집계
    final weekCompletions = <String, int>{}; // 'YYYY-Www' -> count
    for (final dateStr in completedDates) {
      final date = DateUtil.parseDate(dateStr);
      final weekKey = _getWeekKey(date);
      weekCompletions[weekKey] = (weekCompletions[weekKey] ?? 0) + 1;
    }

    final currentWeekKey = _getWeekKey(now);
    final currentWeekCount = weekCompletions[currentWeekKey] ?? 0;

    int currentStreak = 0;
    DateTime currentWeekMonday = _getMondayOfWeek(now);

    // 이번 주 목표 달성 시 이번 주 포함
    if (currentWeekCount >= targetCount) {
      currentStreak++;
      currentWeekMonday = currentWeekMonday.subtract(const Duration(days: 7));
    } else {
      // 아직 이번 주 진행 중이면 지난주부터 역추적
      currentWeekMonday = currentWeekMonday.subtract(const Duration(days: 7));
    }

    while (true) {
      final weekKey = _getWeekKey(currentWeekMonday);
      final count = weekCompletions[weekKey] ?? 0;
      if (count >= targetCount) {
        currentStreak++;
        currentWeekMonday = currentWeekMonday.subtract(const Duration(days: 7));
      } else {
        break;
      }
    }

    // 최장 주간 스트릭
    int bestStreak = currentStreak;
    int tempStreak = 0;
    // 주 키 정렬 후 연속 주인지 계산
    final sortedWeeks = weekCompletions.keys.toList()..sort();
    for (final w in sortedWeeks) {
      if ((weekCompletions[w] ?? 0) >= targetCount) {
        tempStreak++;
        if (tempStreak > bestStreak) {
          bestStreak = tempStreak;
        }
      } else {
        tempStreak = 0;
      }
    }

    return StreakResult(
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      totalCount: totalCount,
      completionRate: completionRate,
    );
  }

  /// 이전 예정일 찾기
  static DateTime _getPreviousScheduledDate(Habit habit, DateTime fromDate) {
    DateTime temp = fromDate.subtract(const Duration(days: 1));
    while (!habit.repeatDays.contains(temp.weekday)) {
      temp = temp.subtract(const Duration(days: 1));
    }
    return temp;
  }

  /// 날짜가 속한 주의 월요일 구하기
  static DateTime _getMondayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  /// 연도-주차 키 (예: '2026-W34')
  static String _getWeekKey(DateTime date) {
    final monday = _getMondayOfWeek(date);
    final dayOfYear = monday.difference(DateTime(monday.year, 1, 1)).inDays;
    final weekNumber = (dayOfYear / 7).floor() + 1;
    return '${monday.year}-W${weekNumber.toString().padLeft(2, '0')}';
  }
}
