import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../models/habit.dart';
import '../../../models/habit_with_today_status.dart';

/// 습관 카드 아이템 ("3초 컷" 손맛 인터랙션 + 스케일 바운스 애니메이션 + 카운트형 지원)
class HabitCardItem extends StatefulWidget {
  final HabitWithTodayStatus habitStatus;
  final VoidCallback onToggle;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onTapDetail;

  const HabitCardItem({
    super.key,
    required this.habitStatus,
    required this.onToggle,
    this.onIncrement,
    this.onDecrement,
    this.onTapDetail,
  });

  @override
  State<HabitCardItem> createState() => _HabitCardItemState();
}

class _HabitCardItemState extends State<HabitCardItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    // 손맛을 위한 쫀득한 바운스 커브
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.86)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.86, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
    ]).animate(_bounceController);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}

    _bounceController.forward(from: 0.0);

    if (widget.habitStatus.habit.habitType == HabitType.count) {
      if (widget.onIncrement != null) {
        widget.onIncrement!();
      } else {
        widget.onToggle();
      }
    } else {
      widget.onToggle();
    }
  }

  void _handleDecrement(TapDownDetails _) {
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
    if (widget.onDecrement != null) {
      widget.onDecrement!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habitStatus.habit;
    final isCountType = habit.habitType == HabitType.count;
    final isDone = widget.habitStatus.isCompletedToday;
    final streak = widget.habitStatus.currentStreak;
    final habitColor = Color(habit.colorValue);
    final todayCount = widget.habitStatus.todayCount;
    final targetCount = habit.targetCount;
    final progress = widget.habitStatus.todayProgress;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDone
              ? AppColors.success.withValues(alpha: 0.35)
              : context.surfaceBorder,
          width: isDone ? 1.4 : 1.0,
        ),
        boxShadow: [
          if (isDone)
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            )
          else if (!context.isDarkMode)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _handleTap,
          onLongPress: widget.onTapDetail,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              children: [
                Row(
                  children: [
                    // 1. 습관 아이콘 컨테이너
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: habitColor.withValues(
                            alpha: isDone ? 0.15 : 0.25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        AppIcons.getIcon(habit.iconName),
                        color: habitColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // 2. 습관 이름 및 메타 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.title,
                            style: TextStyle(
                              color: isDone
                                  ? context.textSecondary
                                  : context.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              decoration: (isDone && !isCountType)
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: context.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              // 반복 주기 태그
                              Text(
                                habit.repeatSummary,
                                style: TextStyle(
                                  color: context.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // 간격 알림 뱃지 (간격 알림 설정 시 표시)
                              if (habit.reminderEnabled &&
                                  habit.reminderType == ReminderType.interval)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${(habit.reminderIntervalMinutes ?? 60) ~/ 60}시간마다',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              // 쉬는 날 뱃지
                              if (widget.habitStatus.isRestDay)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: context.isDarkMode
                                        ? Colors.white10
                                        : Colors.black.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '쉬는 날 🏖️',
                                    style: TextStyle(
                                      color: context.textMuted,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              // 스트릭 뱃지
                              if (streak > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.fireOrange
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.local_fire_department_rounded,
                                        size: 12,
                                        color: AppColors.fireOrange,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '$streak일 연속',
                                        style: const TextStyle(
                                          color: AppColors.fireOrange,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 3. 카운트형 감소 버튼 (오늘 카운트가 1 이상일 때)
                    if (isCountType && todayCount > 0 && !isDone) ...[
                      GestureDetector(
                        onTapDown: _handleDecrement,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.bg,
                            border: Border.all(color: context.surfaceBorder),
                          ),
                          child: Icon(
                            Icons.remove,
                            size: 18,
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                    ],

                    // 4. 우측 대형 체크 / 카운트 버튼
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: GestureDetector(
                        onTap: _handleTap,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone
                                ? AppColors.success
                                : (context.isDarkMode
                                    ? AppColors.darkBackground
                                    : AppColors.lightBackground),
                            border: Border.all(
                              color: isDone
                                  ? AppColors.success
                                  : isCountType
                                      ? habitColor.withValues(alpha: 0.5)
                                      : context.surfaceBorder,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: isDone
                                  ? const Icon(
                                      Icons.check_rounded,
                                      key: ValueKey('checked'),
                                      color: Colors.white,
                                      size: 28,
                                    )
                                  : isCountType
                                      ? Column(
                                          key: ValueKey('count_$todayCount'),
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '$todayCount',
                                              style: TextStyle(
                                                color: habitColor,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            Text(
                                              '+1',
                                              style: TextStyle(
                                                color: context.textMuted,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox.shrink(
                                          key: ValueKey('unchecked'),
                                        ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // 카운트형 습관 진행 바
                if (isCountType) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor:
                                habitColor.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDone ? AppColors.success : habitColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$todayCount / $targetCount ${habit.unit}',
                        style: TextStyle(
                          color: isDone ? AppColors.success : habitColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
