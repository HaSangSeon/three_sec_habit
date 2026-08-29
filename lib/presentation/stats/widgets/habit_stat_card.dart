import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
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
      ),
      child: Column(
        children: [
          // 1. 아이콘 + 습관명 + 스트릭 수치
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: habitColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
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
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      habit.repeatSummary,
                      style: TextStyle(
                        color: context.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // 스트릭 강조
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.fireOrange,
                        size: 16,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${habitStatus.currentStreak}일',
                        style: const TextStyle(
                          color: AppColors.fireOrange,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '최고 ${habitStatus.bestStreak}일',
                    style: TextStyle(
                      color: context.textMuted,
                      fontSize: 11,
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: habitStatus.completionRate,
                    minHeight: 6,
                    backgroundColor: context.bg,
                    valueColor: AlwaysStoppedAnimation<Color>(habitColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$ratePercent%',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
