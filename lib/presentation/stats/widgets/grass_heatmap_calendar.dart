import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_util.dart';

/// 깃허브 잔디밭 스타일의 월간 캘린더 히트맵 위젯
class GrassHeatmapCalendar extends StatelessWidget {
  final int year;
  final int month;
  final Map<String, int> heatmapData; // 'YYYY-MM-DD' -> count
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const GrassHeatmapCalendar({
    super.key,
    required this.year,
    required this.month,
    required this.heatmapData,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  Color _getCellColor(int count, BuildContext context) {
    if (count == 0) return context.bg;
    if (count == 1) return context.isDarkMode ? const Color(0xFF065F46) : const Color(0xFFA7F3D0); // 옅은 그린
    if (count == 2) return context.isDarkMode ? const Color(0xFF059669) : const Color(0xFF34D399); // 중간 에메랄드
    if (count >= 3) return const Color(0xFF10B981); // 밝은 에메랄드 (완료 다수)
    return context.bg;
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    // 1(월) ~ 7(일)
    final startingWeekday = firstDayOfMonth.weekday; // 1=Mon, 7=Sun

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.surfaceBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 월 선택 헤더 (< 2026년 8월 >)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.grid_view_rounded,
                    color: AppColors.success,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateUtil.formatMonth(firstDayOfMonth),
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left_rounded, color: context.textSecondary),
                    visualDensity: VisualDensity.compact,
                    onPressed: onPreviousMonth,
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right_rounded, color: context.textSecondary),
                    visualDensity: VisualDensity.compact,
                    onPressed: onNextMonth,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. 요일 라벨 (월 화 수 목 금 토 일)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['월', '화', '수', '목', '금', '토', '일'].map((day) {
              return SizedBox(
                width: 34,
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      color: context.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // 3. 잔디밭 타일 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42, // 최대 6주 * 7일
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final dayOffset = index - (startingWeekday - 1);
              if (dayOffset < 0 || dayOffset >= daysInMonth) {
                return const SizedBox.shrink();
              }

              final day = dayOffset + 1;
              final dateStr =
                  '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
              final count = heatmapData[dateStr] ?? 0;
              final isToday = DateUtil.today() == dateStr;

              return Tooltip(
                message: '$dateStr : $count개 완료',
                child: Container(
                  decoration: BoxDecoration(
                    color: _getCellColor(count, context),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isToday
                          ? AppColors.primaryLight
                          : count > 0
                              ? Colors.transparent
                              : context.surfaceBorder.withValues(alpha: 0.6),
                      width: isToday ? 1.5 : 0.8,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: count > 0
                            ? (context.isDarkMode ? Colors.white : (count >= 3 ? Colors.white : AppColors.lightTextPrimary))
                            : context.textMuted,
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.w900 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // 4. 하단 레전드(색상 범례)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Less',
                style: TextStyle(color: context.textMuted, fontSize: 10),
              ),
              const SizedBox(width: 6),
              _buildLegendCell(context.bg, context),
              const SizedBox(width: 4),
              _buildLegendCell(context.isDarkMode ? const Color(0xFF065F46) : const Color(0xFFA7F3D0), context),
              const SizedBox(width: 4),
              _buildLegendCell(context.isDarkMode ? const Color(0xFF059669) : const Color(0xFF34D399), context),
              const SizedBox(width: 4),
              _buildLegendCell(const Color(0xFF10B981), context),
              const SizedBox(width: 6),
              Text(
                'More',
                style: TextStyle(color: context.textMuted, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendCell(Color color, BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: context.surfaceBorder, width: 0.5),
      ),
    );
  }
}
