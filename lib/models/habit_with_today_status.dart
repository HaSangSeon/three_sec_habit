import 'habit.dart';

/// 홈 화면 및 위젯에서 습관의 오늘 완료 상태, 카운트 및 스트릭 정보를 함께 전달하는 뷰 모델
class HabitWithTodayStatus {
  final Habit habit;
  final int todayCount;
  final bool isCompletedToday;
  final int currentStreak;
  final int bestStreak;
  final int totalCompletedCount;
  final double completionRate;

  const HabitWithTodayStatus({
    required this.habit,
    this.todayCount = 0,
    required this.isCompletedToday,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalCompletedCount = 0,
    this.completionRate = 0.0,
  });

  /// 오늘 목표 대비 달성률 (0.0 ~ 1.0)
  double get todayProgress {
    if (habit.targetCount <= 0) return isCompletedToday ? 1.0 : 0.0;
    final rate = todayCount / habit.targetCount;
    return rate.clamp(0.0, 1.0);
  }

  HabitWithTodayStatus copyWith({
    Habit? habit,
    int? todayCount,
    bool? isCompletedToday,
    int? currentStreak,
    int? bestStreak,
    int? totalCompletedCount,
    double? completionRate,
  }) {
    return HabitWithTodayStatus(
      habit: habit ?? this.habit,
      todayCount: todayCount ?? this.todayCount,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalCompletedCount: totalCompletedCount ?? this.totalCompletedCount,
      completionRate: completionRate ?? this.completionRate,
    );
  }
}
