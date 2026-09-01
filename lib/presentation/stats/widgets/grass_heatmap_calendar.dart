import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_util.dart';

/// 깃허브 잔디밭 스타일의 월간 캘린더 히트맵 위젯
class GrassHeatmapCalendar extends StatelessWidget {
  final int year;
  final int month;
  final Map<String, int> heatmapData; // 'YYYY-MM-DD' -> count
  final String? selectedDate; // 현재 선택된 날짜 ('YYYY-MM-DD')
  final List<Map<String, dynamic>>? completedHabits; // 선택된 날짜의 완료 습관 목록
  final bool isLoadingHabits;
  final ValueChanged<String>? onDateSelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const GrassHeatmapCalendar({
    super.key,
    required this.year,
    required this.month,
    required this.heatmapData,
    this.selectedDate,
    this.completedHabits,
    this.isLoadingHabits = false,
    this.onDateSelected,
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
              final isSelected = selectedDate == dateStr;

              return GestureDetector(
                onTap: () => onDateSelected?.call(dateStr),
                child: Tooltip(
                  message: '$dateStr : $count개 완료',
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: _getCellColor(count, context),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: isSelected
                            ? (context.isDarkMode ? AppColors.accent : AppColors.primary)
                            : (isToday
                                ? AppColors.primaryLight
                                : (count > 0
                                    ? Colors.transparent
                                    : context.surfaceBorder.withValues(alpha: 0.6))),
                        width: isSelected ? 2.2 : (isToday ? 1.4 : 0.8),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.45),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          color: count > 0
                              ? (context.isDarkMode ? Colors.white : (count >= 3 ? Colors.white : AppColors.lightTextPrimary))
                              : context.textMuted,
                          fontSize: isSelected ? 12 : 11,
                          fontWeight: (isSelected || isToday) ? FontWeight.w900 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // 4. 하단 레전드(색상 범례) & 날짜별 요약
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '날짜 터치 시 완료 내역 확인',
                style: TextStyle(
                  color: context.textMuted.withValues(alpha: 0.7),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Less',
                    style: TextStyle(color: context.textMuted, fontSize: 10),
                  ),
                  const SizedBox(width: 5),
                  _buildLegendCell(context.bg, context),
                  const SizedBox(width: 3),
                  _buildLegendCell(context.isDarkMode ? const Color(0xFF065F46) : const Color(0xFFA7F3D0), context),
                  const SizedBox(width: 3),
                  _buildLegendCell(context.isDarkMode ? const Color(0xFF059669) : const Color(0xFF34D399), context),
                  const SizedBox(width: 3),
                  _buildLegendCell(const Color(0xFF10B981), context),
                  const SizedBox(width: 5),
                  Text(
                    'More',
                    style: TextStyle(color: context.textMuted, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),

          // 5. 달력 영역 내부 하단: 선택 날짜 실천 요약 텍스트 바
          if (selectedDate != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? Colors.black.withValues(alpha: 0.25)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.surfaceBorder.withValues(alpha: 0.7),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: (completedHabits != null && completedHabits!.isNotEmpty)
                          ? AppColors.success.withValues(alpha: 0.15)
                          : context.surfaceBorder.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _formatDateTag(selectedDate!),
                      style: TextStyle(
                        color: (completedHabits != null && completedHabits!.isNotEmpty)
                            ? AppColors.success
                            : context.textSecondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: isLoadingHabits
                        ? Text(
                            '조회 중...',
                            style: TextStyle(
                              color: context.textMuted,
                              fontSize: 12,
                            ),
                          )
                        : (completedHabits == null || completedHabits!.isEmpty)
                            ? Text(
                                '실천한 습관 없음',
                                style: TextStyle(
                                  color: context.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : RichText(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: '완료: ',
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                    ),
                                    TextSpan(
                                      text: completedHabits!
                                          .map((h) => h['title'] as String? ?? '')
                                          .join(' · '),
                                      style: TextStyle(
                                        color: context.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
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

  String _formatDateTag(String dateStr) {
    try {
      final d = DateUtil.parseDate(dateStr);
      final isToday = DateUtil.isToday(dateStr);
      const days = ['', '월', '화', '수', '목', '금', '토', '일'];
      if (isToday) {
        return '오늘 ${d.month}/${d.day}(${days[d.weekday]})';
      }
      return '${d.month}/${d.day}(${days[d.weekday]})';
    } catch (_) {
      return dateStr;
    }
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
