import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_sec_habit/core/constants/app_colors.dart';
import 'package:three_sec_habit/models/habit.dart';

/// 반복 주기 설정 카드 (매일, 특정 요일 칩 및 버튼, 주 N회 스텝퍼)
/// - 어르신도 누르기 편한 대형 터치 타겟 (44x44)
/// - 직관적인 한글 라벨과 명확한 피드백
class HabitRepeatCard extends StatelessWidget {
  final RepeatType repeatType;
  final List<int> repeatDays;
  final int repeatCount;
  final ValueChanged<RepeatType> onRepeatTypeSelected;
  final ValueChanged<List<int>> onRepeatDaysChanged;
  final ValueChanged<int> onRepeatCountChanged;

  const HabitRepeatCard({
    super.key,
    required this.repeatType,
    required this.repeatDays,
    required this.repeatCount,
    required this.onRepeatTypeSelected,
    required this.onRepeatDaysChanged,
    required this.onRepeatCountChanged,
  });

  String _getRepeatDaysSummary() {
    if (repeatDays.length == 7) return '매일 (월~일)';
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
      return '주말(토·일)';
    }
    const dayLabels = ['', '월', '화', '수', '목', '금', '토', '일'];
    final sorted = List<int>.from(repeatDays)..sort();
    return sorted.map((d) => dayLabels[d]).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.surfaceBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: context.isDarkMode ? 0.12 : 0.03,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: RepeatType.values.map((type) {
                final isSelected = repeatType == type;
                String displayTitle = type.label;
                IconData displayIcon = Icons.calendar_today_rounded;
                if (type == RepeatType.daily) {
                  displayTitle = '매일 실천';
                  displayIcon = Icons.all_inclusive_rounded;
                } else if (type == RepeatType.weeklyDays) {
                  displayTitle = '요일 선택';
                  displayIcon = Icons.date_range_rounded;
                } else if (type == RepeatType.weeklyCount) {
                  displayTitle = '주 N회';
                  displayIcon = Icons.flag_circle_rounded;
                }

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      try {
                        HapticFeedback.selectionClick();
                      } catch (_) {}
                      onRepeatTypeSelected(type);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(
                                alpha: context.isDarkMode ? 0.22 : 0.14,
                              )
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected
                            ? Border.all(
                                color: AppColors.primary,
                                width: 1.4,
                              )
                            : Border.all(
                                color: Colors.transparent,
                                width: 1.4,
                              ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            displayIcon,
                            size: 18,
                            color: isSelected
                                ? AppColors.primaryLight
                                : context.textMuted,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayTitle,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : context.textSecondary,
                              fontSize: 13.5,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (repeatType == RepeatType.daily) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 15, color: Color(0xFF10B981)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '월요일부터 일요일까지 매일 꾸준히 실천해요.',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (repeatType == RepeatType.weeklyDays) ...[
            Divider(color: context.surfaceBorder, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  const Icon(Icons.event_available_rounded,
                      size: 15, color: AppColors.primaryLight),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '실천 요일 선택 (${_getRepeatDaysSummary()})',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: List.generate(7, (i) {
                  final day = i + 1;
                  final isSelected = repeatDays.contains(day);
                  const dayLabels = ['', '월', '화', '수', '목', '금', '토', '일'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        try {
                          HapticFeedback.selectionClick();
                        } catch (_) {}
                        final updated = List<int>.from(repeatDays);
                        if (isSelected) {
                          if (updated.length > 1) {
                            updated.remove(day);
                            onRepeatDaysChanged(updated);
                          }
                        } else {
                          updated.add(day);
                          onRepeatDaysChanged(updated);
                        }
                      },
                      child: Container(
                        height: 44,
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryDark
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isSelected
                              ? null
                              : (context.isDarkMode
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : Colors.black.withValues(alpha: 0.03)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : context.surfaceBorder,
                            width: isSelected ? 1.4 : 1.0,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            dayLabels[day],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : context.textPrimary,
                              fontSize: 14.5,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
          if (repeatType == RepeatType.weeklyCount) ...[
            Divider(color: context.surfaceBorder, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '일주일에 몇 번 실천할까요?',
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: repeatCount > 1
                                ? () {
                                    try {
                                      HapticFeedback.lightImpact();
                                    } catch (_) {}
                                    onRepeatCountChanged(repeatCount - 1);
                                  }
                                : null,
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: context.isDarkMode
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: context.surfaceBorder),
                              ),
                              child: Icon(
                                Icons.remove_rounded,
                                size: 20,
                                color: repeatCount > 1
                                    ? context.textPrimary
                                    : context.textMuted.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '주 $repeatCount회',
                              style: const TextStyle(
                                color: AppColors.primaryLight,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: repeatCount < 7
                                ? () {
                                    try {
                                      HapticFeedback.lightImpact();
                                    } catch (_) {}
                                    onRepeatCountChanged(repeatCount + 1);
                                  }
                                : null,
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: context.isDarkMode
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: context.surfaceBorder),
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                size: 20,
                                color: repeatCount < 7
                                    ? context.textPrimary
                                    : context.textMuted.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.isDarkMode
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.black.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.surfaceBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 15,
                              color: AppColors.primaryLight,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '주 $repeatCount회 목표 안내',
                              style: TextStyle(
                                color: context.textPrimary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '• 요일을 따로 정하지 않고 이번 주(월~일) 중 실천한 날 자유롭게 체크합니다.\n'
                          '• 목표 횟수($repeatCount회)를 달성할 때까지 오늘의 습관 목록에 표시됩니다.',
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
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
