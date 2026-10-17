import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_sec_habit/core/constants/app_colors.dart';
import 'package:three_sec_habit/core/constants/app_icons.dart';
import 'package:three_sec_habit/models/habit.dart';

/// 어르신 및 시니어를 위한 추천 습관 프리셋 모델
class SeniorHabitPreset {
  final String title;
  final String iconKey;
  final int colorValue;
  final List<TimeOfDay> reminderTimes;
  final ReminderType reminderType;
  final int reminderIntervalMinutes;
  final TimeOfDay? reminderStartTime;
  final TimeOfDay? reminderEndTime;
  final HabitType habitType;
  final int targetCount;
  final String unit;
  final String badgeText;
  final String timeDescription;

  const SeniorHabitPreset({
    required this.title,
    required this.iconKey,
    required this.colorValue,
    this.reminderTimes = const [],
    this.reminderType = ReminderType.fixed,
    this.reminderIntervalMinutes = 60,
    this.reminderStartTime,
    this.reminderEndTime,
    this.habitType = HabitType.check,
    this.targetCount = 1,
    this.unit = '회',
    required this.badgeText,
    required this.timeDescription,
  });
}

/// 어르신을 위한 1-터치 빠른 습관 추천 카드
class SeniorHabitPresetsCard extends StatelessWidget {
  final ValueChanged<SeniorHabitPreset> onSelectPreset;

  const SeniorHabitPresetsCard({
    super.key,
    required this.onSelectPreset,
  });

  static const List<SeniorHabitPreset> presets = [
    SeniorHabitPreset(
      title: '혈압약·당뇨약 복용',
      iconKey: 'medication',
      colorValue: 0xFF8B5CF6, // 바이올렛
      reminderTimes: [
        TimeOfDay(hour: 8, minute: 30),
        TimeOfDay(hour: 12, minute: 30),
        TimeOfDay(hour: 18, minute: 30),
      ],
      badgeText: '건강/필수',
      timeDescription: '식후 3번 알림 (아침·점심·저녁)',
    ),
    SeniorHabitPreset(
      title: '1시간마다 물 마시기',
      iconKey: 'water_drop',
      colorValue: 0xFF0284C7, // 오션 스카이블루
      reminderType: ReminderType.interval,
      reminderIntervalMinutes: 60,
      reminderStartTime: TimeOfDay(hour: 9, minute: 0),
      reminderEndTime: TimeOfDay(hour: 21, minute: 0),
      habitType: HabitType.count,
      targetCount: 8,
      unit: '잔',
      badgeText: '인기/수분',
      timeDescription: '낮 동안 1시간마다 (총 8잔)',
    ),
    SeniorHabitPreset(
      title: '기상 후 미온수 한 잔',
      iconKey: 'water_drop',
      colorValue: 0xFF06B6D4, // 시안 블루
      reminderTimes: [
        TimeOfDay(hour: 7, minute: 0),
      ],
      badgeText: '활력',
      timeDescription: '매일 아침 7:00',
    ),
    SeniorHabitPreset(
      title: '30분 동네 산책하기',
      iconKey: 'directions_run',
      colorValue: 0xFF10B981, // 에메랄드
      reminderTimes: [
        TimeOfDay(hour: 10, minute: 0),
      ],
      badgeText: '운동',
      timeDescription: '상쾌한 오전 10:00',
    ),
    SeniorHabitPreset(
      title: '식후 영양제 챙기기',
      iconKey: 'medication',
      colorValue: 0xFFF97316, // 오렌지
      reminderTimes: [
        TimeOfDay(hour: 12, minute: 30),
      ],
      badgeText: '영양',
      timeDescription: '점심 식사 직후',
    ),
    SeniorHabitPreset(
      title: '허리·관절 스트레칭',
      iconKey: 'self_improvement',
      colorValue: 0xFFF59E0B, // 앰버
      reminderTimes: [
        TimeOfDay(hour: 15, minute: 0),
      ],
      badgeText: '스트레칭',
      timeDescription: '나른한 오후 3:00',
    ),
    SeniorHabitPreset(
      title: '혈압·혈당 수치 체크',
      iconKey: 'monitor_heart',
      colorValue: 0xFFEF4444, // 레드
      reminderTimes: [
        TimeOfDay(hour: 8, minute: 0),
        TimeOfDay(hour: 20, minute: 0),
      ],
      badgeText: '건강기록',
      timeDescription: '아침·저녁 2회',
    ),
    SeniorHabitPreset(
      title: '성경·독서 / 하루 일기',
      iconKey: 'menu_book',
      colorValue: 0xFF6366F1, // 인디고
      reminderTimes: [
        TimeOfDay(hour: 20, minute: 0),
      ],
      badgeText: '마음챙김',
      timeDescription: '하루 마무리 저녁 8:00',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: context.isDarkMode ? 0.35 : 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: context.isDarkMode ? 0.15 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 안내 바
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '인기 추천 습관',
                            style: TextStyle(
                              color: context.textPrimary,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.fireOrange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              '원터치',
                              style: TextStyle(
                                color: AppColors.fireOrange,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '원하는 습관을 터치하면 이름과 알림 시간이 즉시 맞춰져요.',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 가로 스크롤 카드 목록 (더 깊고 진한 좌우 페이드 그라데이션 효과)
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  Color(0x1A000000),
                  Color(0x8A000000),
                  Colors.black,
                  Colors.black,
                  Color(0x8A000000),
                  Color(0x1A000000),
                  Colors.transparent,
                ],
                stops: [0.0, 0.03, 0.07, 0.12, 0.88, 0.93, 0.97, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: SizedBox(
              height: 98,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: presets.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final preset = presets[index];
                  final presetColor = Color(preset.colorValue);

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        try {
                          HapticFeedback.mediumImpact();
                        } catch (_) {}
                        onSelectPreset(preset);
                      },
                      child: Container(
                        width: 176,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: presetColor.withValues(
                            alpha: context.isDarkMode ? 0.12 : 0.07,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: presetColor.withValues(
                              alpha: context.isDarkMode ? 0.35 : 0.25,
                            ),
                            width: 1.1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: presetColor.withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    AppIcons.getIcon(preset.iconKey),
                                    color: presetColor,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.isDarkMode
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    preset.badgeText,
                                    style: TextStyle(
                                      color: presetColor,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              preset.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_filled_rounded,
                                  size: 11,
                                  color: context.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    preset.timeDescription,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: context.textSecondary,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
