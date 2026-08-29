import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// 상단 헤더: 오늘 날짜 및 오늘 습관 달성률 현황 표시
class TodayHeader extends StatelessWidget {
  final String dateString;
  final int completedCount;
  final int totalCount;
  final double progressRate;

  const TodayHeader({
    super.key,
    required this.dateString,
    required this.completedCount,
    required this.totalCount,
    required this.progressRate,
  });

  @override
  Widget build(BuildContext context) {
    final isAllDone = totalCount > 0 && completedCount == totalCount;
    final percent = (progressRate * 100).toInt();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isAllDone
              ? AppColors.success.withValues(alpha: 0.4)
              : context.surfaceBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isAllDone
                ? AppColors.success.withValues(alpha: 0.08)
                : (context.isDarkMode
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.04)),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 오늘 날짜 및 3초 컷 뱃지
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isAllDone ? AppColors.success : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateString,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 14,
                      color: AppColors.primaryLight,
                    ),
                    SizedBox(width: 2),
                    Text(
                      '3초 컷',
                      style: TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. 메인 문구 및 진행 수치
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAllDone
                          ? '오늘의 모든 습관 완료! 🎉'
                          : totalCount == 0
                              ? '습관을 등록해보세요'
                              : '오늘의 목표를 달성하세요',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalCount == 0
                          ? '하단 + 버튼을 눌러 첫 습관을 만들어보세요'
                          : isAllDone
                              ? '완벽한 하루를 보내고 있어요!'
                              : '$completedCount개 완료됨 (${totalCount - completedCount}개 남음)',
                      style: TextStyle(
                        color: isAllDone
                            ? AppColors.successLight
                            : context.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // 숫자 강조
              if (totalCount > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$completedCount',
                            style: TextStyle(
                              color: isAllDone
                                  ? AppColors.success
                                  : AppColors.primaryLight,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          TextSpan(
                            text: ' / $totalCount',
                            style: TextStyle(
                              color: context.textMuted,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$percent%',
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
          const SizedBox(height: 16),

          // 3. 프로그레스 바
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0, end: progressRate),
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: context.bg,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isAllDone ? AppColors.success : AppColors.primary,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
