import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../models/habit_with_today_status.dart';

/// 습관 카드 아이템 ("3초 컷" 손맛 인터랙션 + 스케일 바운스 애니메이션)
class HabitCardItem extends StatefulWidget {
  final HabitWithTodayStatus habitStatus;
  final VoidCallback onToggle;
  final VoidCallback? onTapDetail;

  const HabitCardItem({
    super.key,
    required this.habitStatus,
    required this.onToggle,
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

    // 손맛을 위한 쫀득한 바운스 커브 (1.0 -> 0.85 -> 1.1 -> 1.0)
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

  void _handleTapCheck() {
    // 1. 가벼운 햅틱 피드백 트리거 (손맛)
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}

    // 2. 바운스 애니메이션 실행
    _bounceController.forward(from: 0.0);

    // 3. 토글 콜백 호출 (0ms 낙관적 업데이트)
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habitStatus.habit;
    final isDone = widget.habitStatus.isCompletedToday;
    final streak = widget.habitStatus.currentStreak;
    final habitColor = Color(habit.colorValue);

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
          onTap: _handleTapCheck, // 카드 어디를 눌러도 3초 컷 빠른 체크 가능
          onLongPress: widget.onTapDetail,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // 1. 습관 아이콘 컨테이너
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: habitColor.withValues(alpha: isDone ? 0.15 : 0.25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    AppIcons.getIcon(habit.iconName),
                    color: habitColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),

                // 2. 습관 이름 및 메타 정보 (반복 주기, 스트릭)
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
                          decoration:
                              isDone ? TextDecoration.lineThrough : null,
                          decorationColor: context.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
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
                          // 스트릭 뱃지 (연속 기록이 있을 때만 표시)
                          if (streak > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.fireOrange.withValues(alpha: 0.15),
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
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. 우측 대형 체크 버튼 (손맛 애니메이션 적용)
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: GestureDetector(
                    onTap: _handleTapCheck,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 44,
                      height: 44,
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
                                  size: 26,
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
          ),
        ),
      ),
    );
  }
}
