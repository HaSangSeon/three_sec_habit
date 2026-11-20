import 'package:flutter/material.dart';

/// 습관 알림 사운드 모델
class HabitSoundInfo {
  final String key;
  final String label;
  final String description;
  final String emoji;

  const HabitSoundInfo({
    required this.key,
    required this.label,
    required this.description,
    required this.emoji,
  });

  bool get isDefault => key == 'default';
}

/// 습관 알림 사운드 11종 (기본 띵동음 + 카테고리별 한국어 음성 10종)
class AppSounds {
  AppSounds._();

  static const String defaultSoundKey = 'default';

  static const List<HabitSoundInfo> sounds = [
    HabitSoundInfo(
      key: 'default',
      label: '기본 알림음',
      description: '기기 기본 알림음 (조용한 환경 추천)',
      emoji: '🔔',
    ),
    HabitSoundInfo(
      key: 'voice_water',
      label: '물 마셔!',
      description: '"물 마실 시간이에요! 시원하게 한 잔 마셔요."',
      emoji: '💧',
    ),
    HabitSoundInfo(
      key: 'voice_medicine',
      label: '약 드세요!',
      description: '"약 챙겨 드실 시간이에요! 잊지 말고 꼭 드세요."',
      emoji: '💊',
    ),
    HabitSoundInfo(
      key: 'voice_walk',
      label: '산책·운동 시간',
      description: '"움직일 시간이에요! 가볍게 산책이나 운동을 해볼까요?"',
      emoji: '🏃',
    ),
    HabitSoundInfo(
      key: 'voice_stretch',
      label: '스트레칭·명상',
      description: '"스트레칭할 시간이에요! 몸을 쭉 펴고 숨을 쉬어보세요."',
      emoji: '🧘',
    ),
    HabitSoundInfo(
      key: 'voice_health',
      label: '건강 수치 체크',
      description: '"건강 체크할 시간이에요! 오늘의 수치를 확인해보세요."',
      emoji: '❤️',
    ),
    HabitSoundInfo(
      key: 'voice_study',
      label: '독서·집중 시간',
      description: '"집중할 시간이에요! 오늘의 배움을 시작해볼까요?"',
      emoji: '📖',
    ),
    HabitSoundInfo(
      key: 'voice_morning',
      label: '상쾌한 기상',
      description: '"좋은 아침이에요! 상쾌하게 하루를 시작해봐요."',
      emoji: '☀️',
    ),
    HabitSoundInfo(
      key: 'voice_sleep',
      label: '수면·휴식 마무리',
      description: '"오늘 하루도 수고했어요! 편안하게 쉴 시간이에요."',
      emoji: '🌙',
    ),
    HabitSoundInfo(
      key: 'voice_diet',
      label: '식단·절제 응원',
      description: '"건강한 하루를 위해 딱 3초만 더 힘내봐요!"',
      emoji: '🥗',
    ),
    HabitSoundInfo(
      key: 'voice_life',
      label: '3초 컷 실천',
      description: '"3초 컷! 지금 바로 습관을 실천해 볼까요?"',
      emoji: '⚡',
    ),
  ];

  /// 아이콘 키에 맞춰 최적의 한국어 사운드를 자동 추천
  static String suggestSoundForIcon(String iconKey) {
    switch (iconKey) {
      case 'water_drop':
        return 'voice_water';
      case 'medication':
      case 'capsule':
      case 'local_pharmacy':
        return 'voice_medicine';
      case 'directions_run':
      case 'directions_bike':
      case 'fitness_center':
      case 'sports_basketball':
        return 'voice_walk';
      case 'self_improvement':
      case 'church':
      case 'spa':
        return 'voice_stretch';
      case 'monitor_heart':
      case 'favorite':
        return 'voice_health';
      case 'menu_book':
      case 'edit_note':
      case 'code':
      case 'psychology':
      case 'translate':
      case 'laptop_mac':
      case 'brush':
      case 'music_note':
        return 'voice_study';
      case 'wb_sunny':
      case 'alarm':
        return 'voice_morning';
      case 'bed':
      case 'bathtub':
      case 'face_retouching_natural':
        return 'voice_sleep';
      case 'restaurant':
      case 'local_fire_department':
      case 'coffee':
      case 'cookie':
      case 'no_drinks':
      case 'smoke_free':
      case 'cruelty_free':
        return 'voice_diet';
      case 'clean_hands':
      case 'savings':
      case 'payments':
      case 'pets':
      case 'eco':
      case 'flight_takeoff':
      case 'emoji_events':
      case 'check_circle':
      default:
        return 'voice_life';
    }
  }

  /// 사운드 키로 정보 조회
  static HabitSoundInfo getSound(String? key) {
    final targetKey = (key == null || key.isEmpty) ? defaultSoundKey : key;
    return sounds.firstWhere(
      (s) => s.key == targetKey,
      orElse: () => sounds.first,
    );
  }

  /// 사운드별 아이콘 위젯 도우미
  static IconData getSoundIcon(String? key) {
    switch (key) {
      case 'voice_water':
        return Icons.water_drop_rounded;
      case 'voice_medicine':
        return Icons.medication_rounded;
      case 'voice_walk':
        return Icons.directions_run_rounded;
      case 'voice_stretch':
        return Icons.self_improvement_rounded;
      case 'voice_health':
        return Icons.monitor_heart_rounded;
      case 'voice_study':
        return Icons.menu_book_rounded;
      case 'voice_morning':
        return Icons.wb_sunny_rounded;
      case 'voice_sleep':
        return Icons.bedtime_rounded;
      case 'voice_diet':
        return Icons.restaurant_rounded;
      case 'voice_life':
        return Icons.bolt_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }
}
