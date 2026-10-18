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
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
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
    if (_displayYear > now.year || (_displayYear == now.year && _displayMonth >= now.month)) {
      return;
    }
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 390, maxHeight: 640),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. 헤더 영역 (그라데이션, 아이콘, 타이틀 + 실시간 선택 날짜 뱃지, 닫기 버튼)
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 14, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF1E293B),
                          const Color(0xFF172033),
                        ]
                      : [
                          const Color(0xFFF5F3FF),
                          const Color(0xFFF8FAFC),
                          Colors.white,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.20),
                          AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: isDark ? 0.45 : 0.30),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.primary,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '날짜 선택',
                              style: TextStyle(
                                color: context.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 16.5,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: isDark ? 0.20 : 0.10),
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.20),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  DateUtil.isSameDay(_selectedDate, today)
                                      ? '오늘 선택됨'
                                      : '${_selectedDate.month}.${_selectedDate.day} (${DateUtil.getWeekdayKorean(_selectedDate.weekday)})',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '원하는 날짜를 선택하여 실천 기록을 확인하세요',
                          style: TextStyle(
                            color: context.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 17,
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              thickness: 1,
              color: isDark ? const Color(0xFF334155).withValues(alpha: 0.6) : const Color(0xFFE2E8F0),
            ),

            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 2. 빠른 날짜 선택 3단 세그먼트 (오늘, 어제, 2일 전)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildQuickChip(
                              label: '오늘',
                              subLabel: '${today.month}.${today.day}',
                              date: today,
                              isSelected: DateUtil.isSameDay(_selectedDate, today),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildQuickChip(
                              label: '어제',
                              subLabel: '${yesterday.month}.${yesterday.day}',
                              date: yesterday,
                              isSelected: DateUtil.isSameDay(_selectedDate, yesterday),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildQuickChip(
                              label: '2일 전',
                              subLabel: '${twoDaysAgo.month}.${twoDaysAgo.day}',
                              date: twoDaysAgo,
                              isSelected: DateUtil.isSameDay(_selectedDate, twoDaysAgo),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. 월 이동 네비게이션 컨트롤 바 (< 2026년 10월 >)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A).withValues(alpha: 0.45)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155).withValues(alpha: 0.6)
                              : const Color(0xFFE2E8F0),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _previousMonth,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Icon(
                                  Icons.chevron_left_rounded,
                                  size: 20,
                                  color: context.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 12.5,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '$_displayYear년 $_displayMonth월',
                                style: TextStyle(
                                  color: context.textPrimary,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isNextMonthDisabled ? null : _nextMonth,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  size: 20,
                                  color: isNextMonthDisabled
                                      ? context.textMuted.withValues(alpha: 0.25)
                                      : context.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 3),

                    // 4. 요일 라벨 바 (월 ~ 일 정밀 정렬)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
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

                    const SizedBox(height: 4),

                    // 5. 달력 그리드 (7열 배치)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 42,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          crossAxisSpacing: 3,
                          mainAxisSpacing: 3,
                          childAspectRatio: 1.18,
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
                          final isSelected = DateUtil.isSameDay(_selectedDate, cellDate);
                          final isTodayCell = DateUtil.isSameDay(today, cellDate);
                          final completedCount = _monthlyCompletions[dateStr] ?? 0;

                          // 요일별 텍스트 색상 구분 (토요일 파랑, 일요일 빨강)
                          final isSunday = cellDate.weekday == DateTime.sunday;
                          final isSaturday = cellDate.weekday == DateTime.saturday;

                          Color textColor;
                          if (isSelected) {
                            textColor = Colors.white;
                          } else if (isFuture) {
                            textColor = context.textMuted.withValues(alpha: 0.28);
                          } else if (isTodayCell) {
                            textColor = AppColors.primary;
                          } else if (isSunday) {
                            textColor = const Color(0xFFEF4444);
                          } else if (isSaturday) {
                            textColor = const Color(0xFF3B82F6);
                          } else {
                            textColor = context.textPrimary;
                          }

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
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOutCubic,
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
                                        ? AppColors.primary.withValues(alpha: isDark ? 0.16 : 0.09)
                                        : Colors.transparent),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : (isTodayCell
                                          ? AppColors.primary.withValues(alpha: 0.8)
                                          : Colors.transparent),
                                  width: isTodayCell ? 1.3 : 1.0,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.40),
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
                                      color: textColor,
                                      fontSize: 12.5,
                                      fontWeight: isSelected || isTodayCell
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                    ),
                                  ),
                                  // 해당 날짜에 완료한 습관이 있을 경우 은은한 완료 인디케이터
                                  if (completedCount > 0)
                                    Positioned(
                                      bottom: 2.5,
                                      child: Container(
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.white : AppColors.success,
                                          shape: BoxShape.circle,
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.white.withValues(alpha: 0.6),
                                                    blurRadius: 3,
                                                  ),
                                                ]
                                              : null,
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

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            Divider(
              height: 1,
              thickness: 1,
              color: isDark ? const Color(0xFF334155).withValues(alpha: 0.6) : const Color(0xFFE2E8F0),
            ),

            // 6. 하단 액션 버튼 바 (취소 / 이 날짜로 이동)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isDark
                              ? const Color(0xFF334155).withValues(alpha: 0.3)
                              : const Color(0xFFF8FAFC),
                          side: BorderSide(
                            color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                            width: 0.9,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: TextStyle(
                            color: context.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 6,
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(_selectedDate),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: AppColors.primary.withValues(alpha: 0.45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                DateUtil.isSameDay(_selectedDate, today)
                                    ? '오늘로 이동'
                                    : '${_selectedDate.month}/${_selectedDate.day} 이동',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip({
    required String label,
    required String subLabel,
    required DateTime date,
    required bool isSelected,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () => _selectQuickDate(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
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
              : (isDark ? const Color(0xFF0F172A).withValues(alpha: 0.4) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? const Color(0xFF334155).withValues(alpha: 0.7) : const Color(0xFFE2E8F0)),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : context.textPrimary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subLabel,
              style: TextStyle(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.85)
                    : context.textMuted,
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayLabel(String text, Color color) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
