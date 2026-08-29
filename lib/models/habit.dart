/// 습관 반복 주기 타입
enum RepeatType {
  daily,        // 매일
  weeklyDays,   // 주 특정 요일 선택 (예: 월, 수, 금)
  weeklyCount,  // 주 N회 (예: 주 3회)
}

extension RepeatTypeExtension on RepeatType {
  String toDbString() {
    switch (this) {
      case RepeatType.daily:
        return 'daily';
      case RepeatType.weeklyDays:
        return 'weekly_days';
      case RepeatType.weeklyCount:
        return 'weekly_count';
    }
  }

  static RepeatType fromDbString(String str) {
    switch (str) {
      case 'weekly_days':
        return RepeatType.weeklyDays;
      case 'weekly_count':
        return RepeatType.weeklyCount;
      case 'daily':
      default:
        return RepeatType.daily;
    }
  }

  String get label {
    switch (this) {
      case RepeatType.daily:
        return '매일';
      case RepeatType.weeklyDays:
        return '특정 요일';
      case RepeatType.weeklyCount:
        return '주 N회';
    }
  }
}

/// 습관 엔티티 모델
class Habit {
  final int? id;
  final String title;
  final String iconName;
  final int colorValue;
  final RepeatType repeatType;
  final List<int> repeatDays;   // 1(월) ~ 7(일) 리스트 (weeklyDays일 때 사용)
  final int? repeatCount;       // 주 N회 (weeklyCount일 때 사용, 1~7)
  final String? reminderTime;   // 'HH:mm'
  final bool reminderEnabled;
  final String createdAt;
  final bool isArchived;

  Habit({
    this.id,
    required this.title,
    this.iconName = 'check_circle',
    this.colorValue = 0xFF8B5CF6,
    this.repeatType = RepeatType.daily,
    List<int>? repeatDays,
    this.repeatCount,
    this.reminderTime,
    this.reminderEnabled = false,
    String? createdAt,
    this.isArchived = false,
  })  : repeatDays = repeatDays ?? const [1, 2, 3, 4, 5, 6, 7],
        createdAt = createdAt ?? DateTime.now().toIso8601String();

  /// 특정 일자에 해당 습관이 수행 예정인지 여부
  bool isScheduledForDate(DateTime date) {
    switch (repeatType) {
      case RepeatType.daily:
        return true;
      case RepeatType.weeklyDays:
        return repeatDays.contains(date.weekday);
      case RepeatType.weeklyCount:
        return true; // 주 N회는 모든 요일에 열려있음
    }
  }

  /// 반복 주기 설명 텍스트
  String get repeatSummary {
    switch (repeatType) {
      case RepeatType.daily:
        return '매일';
      case RepeatType.weeklyDays:
        if (repeatDays.length == 7) return '매일';
        if (repeatDays.length == 5 &&
            repeatDays.contains(1) &&
            repeatDays.contains(2) &&
            repeatDays.contains(3) &&
            repeatDays.contains(4) &&
            repeatDays.contains(5)) {
          return '평일(월~금)';
        }
        if (repeatDays.length == 2 &&
            repeatDays.contains(6) &&
            repeatDays.contains(7)) {
          return '주말(토,일)';
        }
        const days = ['', '월', '화', '수', '목', '금', '토', '일'];
        final sorted = List<int>.from(repeatDays)..sort();
        return sorted.map((d) => days[d]).join(', ');
      case RepeatType.weeklyCount:
        return '주 ${repeatCount ?? 1}회';
    }
  }

  Habit copyWith({
    int? id,
    String? title,
    String? iconName,
    int? colorValue,
    RepeatType? repeatType,
    List<int>? repeatDays,
    int? repeatCount,
    String? reminderTime,
    bool? reminderEnabled,
    String? createdAt,
    bool? isArchived,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      repeatType: repeatType ?? this.repeatType,
      repeatDays: repeatDays ?? this.repeatDays,
      repeatCount: repeatCount ?? this.repeatCount,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'icon_name': iconName,
      'color_value': colorValue,
      'repeat_type': repeatType.toDbString(),
      'repeat_days': repeatDays.join(','),
      'repeat_count': repeatCount,
      'reminder_time': reminderTime,
      'reminder_enabled': reminderEnabled ? 1 : 0,
      'created_at': createdAt,
      'is_archived': isArchived ? 1 : 0,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    final rawDays = map['repeat_days'] as String?;
    final daysList = (rawDays != null && rawDays.isNotEmpty)
        ? rawDays.split(',').map((e) => int.tryParse(e.trim()) ?? 1).toList()
        : <int>[1, 2, 3, 4, 5, 6, 7];

    return Habit(
      id: map['id'] as int?,
      title: map['title'] as String,
      iconName: (map['icon_name'] as String?) ?? 'check_circle',
      colorValue: (map['color_value'] as int?) ?? 0xFF8B5CF6,
      repeatType: RepeatTypeExtension.fromDbString(
          (map['repeat_type'] as String?) ?? 'daily'),
      repeatDays: daysList,
      repeatCount: map['repeat_count'] as int?,
      reminderTime: map['reminder_time'] as String?,
      reminderEnabled: (map['reminder_enabled'] as int? ?? 0) == 1,
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
      isArchived: (map['is_archived'] as int? ?? 0) == 1,
    );
  }
}
