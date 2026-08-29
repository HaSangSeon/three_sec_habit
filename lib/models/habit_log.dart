/// 일자별 습관 체크 기록 모델
class HabitLog {
  final int? id;
  final int habitId;
  final String date;          // 'YYYY-MM-DD'
  final bool isCompleted;
  final String completedAt;   // ISO timestamp

  HabitLog({
    this.id,
    required this.habitId,
    required this.date,
    this.isCompleted = true,
    String? completedAt,
  }) : completedAt = completedAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'habit_id': habitId,
      'date': date,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt,
    };
  }

  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      id: map['id'] as int?,
      habitId: map['habit_id'] as int,
      date: map['date'] as String,
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      completedAt: map['completed_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  HabitLog copyWith({
    int? id,
    int? habitId,
    String? date,
    bool? isCompleted,
    String? completedAt,
  }) {
    return HabitLog(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
