import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/habit_dao.dart';
import '../../../core/utils/date_util.dart';

/// 오늘의 습관 탭 전용 프리미엄 날짜 선택 다이얼로그
class HabitCalendarPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final HabitDao? habitDao;

  const HabitCalendarPickerDialog({
    super.key,
    required this.initialDate,
    this.habitDao,
  });

  static Future<DateTime?> show(BuildContext context, {required DateTime initialDate}) {
    return showDialog<DateTime>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => HabitCalendarPickerDialog(initialDate: initialDate),
    );
  }

  @override
  State<HabitCalendarPickerDialog> createState() => _HabitCalendarPickerDialogState();
}

class _HabitCalendarPickerDialogState extends State<HabitCalendarPickerDialog> {
  late DateTime _selectedDate;
  late int _displayYear;
  late int _displayMonth;

  Map<String, int> _monthlyCompletions = {};

  HabitDao get _dao => widget.habitDao ?? HabitDao();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
    _displayYear = _selectedDate.year;
    _displayMonth = _selectedDate.month;
    _loadMonthlyData();
  }

  Future<void> _loadMonthlyData() async {
    try {
      final data = await _dao.getMonthlyHeatmapLogs(_displayYear, _displayMonth);
      if (mounted) {
        setState(() {
          _monthlyCompletions = data;
        });
      }
    } catch (_) {}
  }

  void _previousMonth() {
    setState(() {
      if (_displayMonth == 1) {
        _displayMonth = 12;
        _displayYear--;
      } else {
        _displayMonth--;
      }
    });
    _loadMonthlyData();
  }

  void _nextMonth() {
    final now = DateTime.now();
    // 현재 달보다 미래로는 이동 제한
    if (_displayYear > now.year || (_displayYear == now.year && _displayMonth >= now.month)) {
      return;
    }
    setState(() {
      if (_displayMonth == 12) {
        _displayMonth = 1;
        _displayYear++;
      } else {
        _displayMonth++;
      }
    });
    _loadMonthlyData();
  }

  void _selectQuickDate(DateTime date) {
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
      if (_displayYear != date.year || _displayMonth != date.month) {
        _displayYear = date.year;
        _displayMonth = date.month;
        _loadMonthlyData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));

    final firstDayOfMonth = DateTime(_displayYear, _displayMonth, 1);
    final daysInMonth = DateUtils.getDaysInMonth(_displayYear, _displayMonth);
    final startingWeekday = firstDayOfMonth.weekday; // 1=Mon, 7=Sun

    final isNextMonthDisabled =
        _displayYear > now.year || (_displayYear == now.year && _displayMonth >= now.month);

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      elevation: 16,
      shadowColor: Colors.black.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. 헤더 영역 (아이콘, 타이틀, 닫기 버튼)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF182234) : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '날짜 선택',
                        style: TextStyle(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '과거 실천 기록을 조회하거나 체크하세요',
                        style: TextStyle(
                          color: context.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  splashRadius: 18,
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
          ),

          // 2. 빠른 날짜 선택 칩 (오늘, 어제, 그저께)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickChip(
                    label: '오늘',
                    date: today,
                    isSelected: _isSameDay(_selectedDate, today),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickChip(
                    label: '어제',
                    date: yesterday,
                    isSelected: _isSameDay(_selectedDate, yesterday),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickChip(
                    label: '2일 전',
                    date: twoDaysAgo,
                    isSelected: _isSameDay(_selectedDate, twoDaysAgo),
                  ),
                ],
              ),
            ),
          ),

          // 3. 월 이동 내비게이션 바 (< 2026년 9월 >)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  color: context.textPrimary,
                  onPressed: _previousMonth,
                  splashRadius: 20,
                ),
                Text(
                  '$_displayYear년 $_displayMonth월',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  color: isNextMonthDisabled
                      ? context.textMuted.withValues(alpha: 0.3)
                      : context.textPrimary,
                  onPressed: isNextMonthDisabled ? null : _nextMonth,
                  splashRadius: 20,
                ),
              ],
            ),
          ),

          // 4. 요일 라벨
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeekdayLabel('월', context.textMuted),
                _buildWeekdayLabel('화', context.textMuted),
                _buildWeekdayLabel('수', context.textMuted),
                _buildWeekdayLabel('목', context.textMuted),
                _buildWeekdayLabel('금', context.textMuted),
                _buildWeekdayLabel('토', const Color(0xFF3B82F6)),
                _buildWeekdayLabel('일', const Color(0xFFEF4444)),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // 5. 달력 그리드
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 42,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (ctx, index) {
                final dayOffset = index - (startingWeekday - 1);
                if (dayOffset < 0 || dayOffset >= daysInMonth) {
                  return const SizedBox.shrink();
                }

                final day = dayOffset + 1;
                final cellDate = DateTime(_displayYear, _displayMonth, day);
                final dateStr = DateUtil.formatDate(cellDate);
                final isFuture = cellDate.isAfter(today);
                final isSelected = _isSameDay(_selectedDate, cellDate);
                final isTodayCell = _isSameDay(today, cellDate);
                final completedCount = _monthlyCompletions[dateStr] ?? 0;

                return GestureDetector(
                  onTap: isFuture
                      ? null
                      : () {
                          try {
                            HapticFeedback.selectionClick();
                          } catch (_) {}
                          setState(() => _selectedDate = cellDate);
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected
                          ? null
                          : (isTodayCell
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isTodayCell
                                ? AppColors.primary
                                : Colors.transparent),
                        width: isTodayCell ? 1.4 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isFuture
                                    ? context.textMuted.withValues(alpha: 0.3)
                                    : (isTodayCell
                                        ? AppColors.primaryLight
                                        : context.textPrimary)),
                            fontSize: 13,
                            fontWeight: isSelected || isTodayCell
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                        // 해당 날짜에 완료한 습관이 있을 경우 은은한 완료 표시
                        if (completedCount > 0 && !isSelected)
                          Positioned(
                            bottom: 3,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // 6. 하단 버튼 (취소 / 이 날짜로 이동)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isDark
                            ? const Color(0xFF334155).withValues(alpha: 0.4)
                            : const Color(0xFFF1F5F9),
                        side: BorderSide(
                          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        '취소',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 6,
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(_selectedDate),
                        borderRadius: BorderRadius.circular(14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isSameDay(_selectedDate, today)
                                  ? '오늘로 이동'
                                  : '${_selectedDate.month}/${_selectedDate.day} 이동',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip({
    required String label,
    required DateTime date,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _selectQuickDate(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (context.isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : context.surfaceBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : context.textSecondary,
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildWeekdayLabel(String text, Color color) {
    return SizedBox(
      width: 32,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
