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
    HabitIconInfo(key: 'medication', label: '영양제/약 복용', icon: Icons.medication_rounded),
    HabitIconInfo(key: 'local_fire_department', label: '다이어트/칼로리', icon: Icons.local_fire_department_rounded),
    HabitIconInfo(key: 'favorite', label: '마음챙김/건강', icon: Icons.favorite_rounded),
    HabitIconInfo(key: 'restaurant', label: '식단/건강식', icon: Icons.restaurant_rounded),
    HabitIconInfo(key: 'edit_note', label: '일기/감사노트', icon: Icons.edit_note_rounded),
    HabitIconInfo(key: 'translate', label: '외국어/어학', icon: Icons.translate_rounded),
    HabitIconInfo(key: 'directions_bike', label: '자전거/라이딩', icon: Icons.directions_bike_rounded),
    HabitIconInfo(key: 'pets', label: '반려동물 산책', icon: Icons.pets_rounded),
    HabitIconInfo(key: 'eco', label: '친환경/식물', icon: Icons.eco_rounded),
    HabitIconInfo(key: 'emoji_events', label: '목표/성취', icon: Icons.emoji_events_rounded),
    HabitIconInfo(key: 'alarm', label: '기상/시간관리', icon: Icons.alarm_rounded),
    HabitIconInfo(key: 'spa', label: '스킨케어/휴식', icon: Icons.spa_rounded),
    HabitIconInfo(key: 'laptop_mac', label: '업무/자기계발', icon: Icons.laptop_mac_rounded),
    HabitIconInfo(key: 'sports_basketball', label: '구기운동/스포츠', icon: Icons.sports_basketball_rounded),
    HabitIconInfo(key: 'bathtub', label: '샤워/반신욕', icon: Icons.bathtub_rounded),
    // 새로 추가된 10종의 다목적 아이콘
    HabitIconInfo(key: 'monitor_heart', label: '건강/혈압 체크', icon: Icons.monitor_heart_rounded),
    HabitIconInfo(key: 'cookie', label: '간식/야식 참기', icon: Icons.cookie_rounded),
    HabitIconInfo(key: 'no_drinks', label: '금주/절주', icon: Icons.no_drinks_rounded),
    HabitIconInfo(key: 'smoke_free', label: '금연', icon: Icons.smoke_free_rounded),
    HabitIconInfo(key: 'payments', label: '재테크/가계부', icon: Icons.payments_rounded),
    HabitIconInfo(key: 'church', label: '종교/기도/명상', icon: Icons.church_rounded),
    HabitIconInfo(key: 'cruelty_free', label: '비건/환경보호', icon: Icons.cruelty_free_rounded),
    HabitIconInfo(key: 'flight_takeoff', label: '여행/버킷리스트', icon: Icons.flight_takeoff_rounded),
    HabitIconInfo(key: 'face_retouching_natural', label: '피부/뷰티 관리', icon: Icons.face_retouching_natural_rounded),
    HabitIconInfo(key: 'local_pharmacy', label: '약국/병원 방문', icon: Icons.local_pharmacy_rounded),
    HabitIconInfo(key: 'capsule', label: '알약/영양제', icon: IconData(0xf484, fontFamily: 'FontAwesomeSolid', fontPackage: 'font_awesome_flutter')),
  ];

  static IconData getIcon(String key) {
    final item = icons.firstWhere(
      (e) => e.key == key,
      orElse: () => icons.last,
    );
    return item.icon;
  }
}
