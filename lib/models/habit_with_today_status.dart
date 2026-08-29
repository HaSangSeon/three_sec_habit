import 'habit.dart';

/// 홈 화면 및 위젯에서 습관의 오늘 완료 상태 및 스트릭 정보를 함께 전달하는 뷰 모델
class HabitWithTodayStatus {
  final Habit habit;
  final bool isCompletedToday;
  final int currentStreak;
  final int bestStreak;
  final int totalCompletedCount;
  final double completionRate;

  const HabitWithTodayStatus({
    required this.habit,
    required this.isCompletedToday,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalCompletedCount = 0,
    this.completionRate = 0.0,
  });

  HabitWithTodayStatus copyWith({
    Habit? habit,
    bool? isCompletedToday,
    int? currentStreak,
    int? bestStreak,
    int? totalCompletedCount,
    double completionRate = 0.0,
  }) {
    return HabitWithTodayStatus(
      habit: habit ?? this.habit,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalCompletedCount: totalCompletedCount ?? this.totalCompletedCount,
      completionRate: completionRate != 0.0 ? completionRate : this.completionRate,
    );
  }
}
