import 'package:flutter/material.dart';

/// 습관 아이콘 정보 모델
class HabitIconInfo {
  final String key;
  final String label;
  final IconData icon;

  const HabitIconInfo({
    required this.key,
    required this.label,
    required this.icon,
  });
}

/// 습관 선택용 기본 아이콘 15종 및 헬퍼
class AppIcons {
  AppIcons._();

  static const List<HabitIconInfo> icons = [
    HabitIconInfo(key: 'water_drop', label: '물 마시기', icon: Icons.water_drop_rounded),
    HabitIconInfo(key: 'fitness_center', label: '운동/헬스', icon: Icons.fitness_center_rounded),
    HabitIconInfo(key: 'directions_run', label: '러닝/산책', icon: Icons.directions_run_rounded),
    HabitIconInfo(key: 'menu_book', label: '독서/공부', icon: Icons.menu_book_rounded),
    HabitIconInfo(key: 'bed', label: '수면/기상', icon: Icons.bed_rounded),
    HabitIconInfo(key: 'self_improvement', label: '명상/스트레칭', icon: Icons.self_improvement_rounded),
    HabitIconInfo(key: 'code', label: '코딩/개발', icon: Icons.code_rounded),
    HabitIconInfo(key: 'psychology', label: '뇌훈련/학습', icon: Icons.psychology_rounded),
    HabitIconInfo(key: 'brush', label: '창작/그림', icon: Icons.brush_rounded),
    HabitIconInfo(key: 'coffee', label: '카페인 조절', icon: Icons.coffee_rounded),
    HabitIconInfo(key: 'savings', label: '가계부/절약', icon: Icons.savings_rounded),
    HabitIconInfo(key: 'clean_hands', label: '청소/정리', icon: Icons.clean_hands_rounded),
    HabitIconInfo(key: 'music_note', label: '악기/음악', icon: Icons.music_note_rounded),
    HabitIconInfo(key: 'wb_sunny', label: '아침 햇살', icon: Icons.wb_sunny_rounded),
    HabitIconInfo(key: 'check_circle', label: '기타/할일', icon: Icons.check_circle_rounded),
  ];

  static IconData getIcon(String key) {
    final item = icons.firstWhere(
      (e) => e.key == key,
      orElse: () => icons.last,
    );
    return item.icon;
  }
}
