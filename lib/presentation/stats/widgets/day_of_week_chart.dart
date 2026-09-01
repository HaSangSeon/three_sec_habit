import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// 요일별(월~일) 실천 횟수를 시각화하는 세련된 미니 막대 그래프 위젯
class DayOfWeekChart extends StatelessWidget {
  /// 1(월) ~ 7(일) -> 완료 횟수
  final Map<int, int> weekdayStats;

  const DayOfWeekChart({
    super.key,
    required this.weekdayStats,
  });

  static const _weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    int maxCount = 0;
    int bestDay = 1;
    int totalCount = 0;

    for (int day = 1; day <= 7; day++) {
      final count = weekdayStats[day] ?? 0;
      totalCount += count;
      if (count > maxCount) {
        maxCount = count;
        bestDay = day;
      }
    }

    final bestDayName = _weekdayLabels[bestDay - 1];
    final insightText = totalCount == 0
        ? '아직 기록된 실천 데이터가 없어요'
        : maxCount == 1 && totalCount < 3
            ? '첫 주 실천 기록을 차곡차곡 쌓아보세요! 🌱'
            : '🏆 $bestDayName요일에 가장 부지런히 실천했어요!';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: context.surfaceBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 영역
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.equalizer_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '요일별 실천 패턴',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              if (totalCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '총 $totalCount회',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 인사이트 요약 칩
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.isDarkMode
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.surfaceBorder,
                width: 0.8,
              ),
            ),
            child: Text(
              insightText,
              style: TextStyle(
                color: totalCount > 0 ? context.textPrimary : context.textMuted,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // 7개 요일 막대 그래프
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final dayNum = index + 1; // 1(월) ~ 7(일)
              final count = weekdayStats[dayNum] ?? 0;
              final isBest = maxCount > 0 && count == maxCount;
              final isWeekend = dayNum >= 6;

              // 0일 때도 최소 6px 표시, 최대치는 44px
              final double barHeight = maxCount == 0
                  ? 6.0
                  : (6.0 + (count / maxCount) * 38.0);

              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 횟수 텍스트 (높이 고정하여 텍스트 유무에 따른 흔들림 방지)
                    SizedBox(
                      height: 16,
                      child: Center(
                        child: Text(
                          count > 0 ? '$count' : '',
                          style: TextStyle(
                            color: isBest ? AppColors.primary : context.textMuted,
                            fontSize: 10.5,
                            fontWeight: isBest ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // 막대 바 영역 (높이 48 고정 프레임 내에서 하단 정렬)
                    SizedBox(
                      height: 48,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          width: 16,
                          height: barHeight,
                          decoration: BoxDecoration(
                            gradient: isBest
                                ? const LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.accent,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  )
                                : null,
                            color: isBest
                                ? null
                                : count > 0
                                    ? (context.isDarkMode
                                        ? const Color(0xFF3B82F6).withValues(alpha: 0.45)
                                        : const Color(0xFF93C5FD))
                                    : (context.isDarkMode
                                        ? Colors.white10
                                        : const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isBest
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.35),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 요일 라벨
                    Text(
                      _weekdayLabels[index],
                      style: TextStyle(
                        color: isBest
                            ? AppColors.primary
                            : isWeekend
                                ? (dayNum == 7 ? Colors.red.shade400 : Colors.blue.shade400)
                                : context.textSecondary,
                        fontSize: 12,
                        fontWeight: isBest ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
