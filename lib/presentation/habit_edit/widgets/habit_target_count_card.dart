import 'package:flutter/material.dart';
import 'package:three_sec_habit/core/constants/app_colors.dart';
import 'package:three_sec_habit/models/habit.dart';

/// 하루 목표 횟수 설정 카드 (체크형 vs 누적 카운트형, 스테퍼, 단위 선택)
class HabitTargetCountCard extends StatelessWidget {
  final HabitType habitType;
  final int targetCount;
  final TextEditingController unitController;
  final List<String> suggestedUnits;
  final ValueChanged<bool> onHabitTypeToggled;
  final ValueChanged<int> onTargetCountChanged;
  final ValueChanged<String> onUnitSelected;
  final VoidCallback onHelpPressed;

  const HabitTargetCountCard({
    super.key,
    required this.habitType,
    required this.targetCount,
    required this.unitController,
    required this.suggestedUnits,
    required this.onHabitTypeToggled,
    required this.onTargetCountChanged,
    required this.onUnitSelected,
    required this.onHelpPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isCount = habitType == HabitType.count;

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCount
              ? AppColors.primary.withValues(alpha: 0.4)
              : context.surfaceBorder,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: context.isDarkMode ? 0.15 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isCount
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : (context.isDarkMode
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.04)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.format_list_numbered_rounded,
                    size: 18,
                    color: isCount ? AppColors.primaryLight : context.textMuted,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '하루 목표 횟수 설정',
                            style: TextStyle(
                              color: context.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: onHelpPressed,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(
                                    alpha: context.isDarkMode ? 0.2 : 0.1),
                              ),
                              child: const Icon(
                                Icons.help_outline_rounded,
                                size: 14,
                                color: AppColors.primaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isCount
                            ? '하루 목표 $targetCount${unitController.text} 누적 완료'
                            : '기본 1일 1회 체크 (비활성)',
                        style: TextStyle(
                          color: isCount
                              ? AppColors.primaryLight
                              : context.textMuted,
                          fontSize: 12,
                          fontWeight:
                              isCount ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isCount,
                  activeTrackColor: AppColors.primary,
                  activeThumbColor: Colors.white,
                  onChanged: onHabitTypeToggled,
                ),
              ],
            ),
          ),
          if (isCount) ...[
            Divider(color: context.surfaceBorder, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 목표 횟수 스테퍼 컨트롤러
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '하루 목표 수치',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: targetCount > 2
                                ? () => onTargetCountChanged(targetCount - 1)
                                : null,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: context.bg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: context.surfaceBorder),
                              ),
                              child: Icon(
                                Icons.remove_rounded,
                                size: 18,
                                color: targetCount > 2
                                    ? context.textPrimary
                                    : context.textMuted.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              '$targetCount',
                              style: const TextStyle(
                                color: AppColors.primaryLight,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: targetCount < 100
                                ? () => onTargetCountChanged(targetCount + 1)
                                : null,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: context.bg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: context.surfaceBorder),
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                size: 18,
                                color: targetCount < 100
                                    ? context.textPrimary
                                    : context.textMuted.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 단위 선택 칩
                  Row(
                    children: [
                      Text(
                        '단위',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: suggestedUnits.map((u) {
                              final isSelected = unitController.text == u;
                              return GestureDetector(
                                onTap: () => onUnitSelected(u),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : context.bg,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : context.surfaceBorder,
                                    ),
                                  ),
                                  child: Text(
                                    u,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : context.textSecondary,
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
