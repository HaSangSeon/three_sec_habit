import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../models/habit.dart';
import '../../../models/habit_with_today_status.dart';

/// 습관별 스트릭 및 달성률 카드 위젯
class HabitStatCard extends StatelessWidget {
  final HabitWithTodayStatus habitStatus;

  const HabitStatCard({super.key, required this.habitStatus});

  @override
  Widget build(BuildContext context) {
    final habit = habitStatus.habit;
    final habitColor = Color(habit.colorValue);
    final ratePercent = (habitStatus.completionRate * 100).toInt();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.surfaceBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.18 : 0.035),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. 아이콘 + 습관명 + 스트릭 수치
          Row(
            children: [
              // 좌측 습관 고유 컬러 세로 액센트 바
              Container(
                width: 3.5,
                height: 40,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [habitColor, habitColor.withValues(alpha: 0.45)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      habitColor.withValues(alpha: 0.26),
                      habitColor.withValues(alpha: 0.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: habitColor.withValues(alpha: 0.36),
                    width: 1.1,
                  ),
                ),
                child: Icon(
                  AppIcons.getIcon(habit.iconName),
                  color: habitColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      habit.habitType == HabitType.count
                          ? '${habit.repeatSummary} · 목표 ${habit.targetCount}${habit.unit}'
                          : habit.repeatSummary,
                      style: TextStyle(
                        color: context.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // 스트릭 강조
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.fireOrange.withValues(
                          alpha: context.isDarkMode ? 0.16 : 0.10),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: AppColors.fireOrange.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: AppColors.fireOrange,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${habitStatus.currentStreak}일',
                          style: const TextStyle(
                            color: AppColors.fireOrange,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '최고 ${habitStatus.bestStreak}일',
                    style: TextStyle(
                      color: context.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. 달성률 프로그레스 바
          Row(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final fillWidth =
                        constraints.maxWidth * habitStatus.completionRate.clamp(0.0, 1.0);
                    return Container(
                      height: 7,
                      decoration: BoxDecoration(
                        color: context.isDarkMode
                            ? Colors.white.withValues(alpha: 0.07)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          width: fillWidth,
                          height: 7,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                habitColor.withValues(alpha: 0.78),
                                habitColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$ratePercent%',
                style: TextStyle(
                  color: ratePercent >= 80 ? habitColor : context.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
