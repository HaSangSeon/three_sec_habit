import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

/// 초프리미엄 휠 & 세그먼트 기반 시간 선택 다이얼로그
/// - 직관적인 [오전/오후] 캡슐 세그먼트 토글
/// - 부드러운 햅틱 반응의 [시] [분] 롤링 휠 피커 (ListWheelScrollView)
/// - 자주 쓰는 추천 시간 퀵 칩 및 원터치 완료
class TimePickerSelectDialog extends StatefulWidget {
  final TimeOfDay initialTime;
  final String title;

  const TimePickerSelectDialog({
    super.key,
    required this.initialTime,
    this.title = '알림 시간 설정',
  });

  /// 다이얼로그 띄우기 헬퍼 함수
  static Future<TimeOfDay?> show({
    required BuildContext context,
    required TimeOfDay initialTime,
    String title = '알림 시간 설정',
  }) {
    return showDialog<TimeOfDay>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      barrierDismissible: true,
      builder: (ctx) => TimePickerSelectDialog(
        initialTime: initialTime,
        title: title,
      ),
    );
  }

  @override
  State<TimePickerSelectDialog> createState() => _TimePickerSelectDialogState();
}

class _TimePickerSelectDialogState extends State<TimePickerSelectDialog> {
  late bool _isPm;
  late int _hour12;
  late int _minute;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  static const double _itemExtent = 42.0;

  @override
  void initState() {
    super.initState();
    final hour24 = widget.initialTime.hour;
    _minute = widget.initialTime.minute;

    if (hour24 >= 12) {
      _isPm = true;
      _hour12 = (hour24 == 12) ? 12 : (hour24 - 12);
    } else {
      _isPm = false;
      _hour12 = (hour24 == 0) ? 12 : hour24;
    }

    _hourController = FixedExtentScrollController(initialItem: _hour12 - 1);
    _minuteController = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  /// 24시간제 TimeOfDay로 변환
  TimeOfDay get _currentTimeOfDay {
    int hour24;
    if (!_isPm) {
      hour24 = (_hour12 == 12) ? 0 : _hour12;
    } else {
      hour24 = (_hour12 == 12) ? 12 : (_hour12 + 12);
    }
    return TimeOfDay(hour: hour24, minute: _minute);
  }

  /// 24시간제 'HH:mm' 문자열
  String get _formatted24h {
    final t = _currentTimeOfDay;
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// 퀵 시간 프리셋 적용
  void _setPreset(int hour24, int minute) {
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}

    final isPm = hour24 >= 12;
    final hour12 = hour24 >= 12
        ? ((hour24 == 12) ? 12 : hour24 - 12)
        : ((hour24 == 0) ? 12 : hour24);

    setState(() {
      _isPm = isPm;
      _hour12 = hour12;
      _minute = minute;
    });

    if (_hourController.hasClients) {
      _hourController.animateToItem(
        hour12 - 1,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
    if (_minuteController.hasClients) {
      _minuteController.animateToItem(
        minute,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Dialog(
      backgroundColor: dialogBg,
      elevation: 16,
      shadowColor: Colors.black.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: borderColor, width: 1.0),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. 헤더 (아이콘 + 타이틀 + 닫기 버튼)
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
                      color: AppColors.primary.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.alarm_rounded,
                    color: AppColors.primaryLight,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '실천 알림을 받을 시간을 설정하세요',
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
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), size: 20),
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

          // 2. 내용 영역
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 2-1. 오전 / 오후 캡슐형 세그먼트 스위치
                Container(
                  height: 42,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildAmPmTab(
                        label: '오전 (AM)',
                        icon: Icons.wb_sunny_rounded,
                        isSelected: !_isPm,
                        isDark: isDark,
                        onTap: () {
                          if (_isPm) {
                            try {
                              HapticFeedback.selectionClick();
                            } catch (_) {}
                            setState(() => _isPm = false);
                          }
                        },
                      ),
                      _buildAmPmTab(
                        label: '오후 (PM)',
                        icon: Icons.nightlight_round,
                        isSelected: _isPm,
                        isDark: isDark,
                        onTap: () {
                          if (!_isPm) {
                            try {
                              HapticFeedback.selectionClick();
                            } catch (_) {}
                            setState(() => _isPm = true);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2-2. 럭셔리 휠 타임 피커 (시 & 분)
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 중앙 하이라이트 바
                      Container(
                        height: _itemExtent,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: isDark ? 0.45 : 0.35),
                            width: 1.2,
                          ),
                        ),
                      ),

                      // 휠 스크롤 뷰 (시간 & 분)
                      Row(
                        children: [
                          // 시간 휠 (1 ~ 12)
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              controller: _hourController,
                              itemExtent: _itemExtent,
                              physics: const FixedExtentScrollPhysics(),
                              perspective: 0.003,
                              onSelectedItemChanged: (index) {
                                try {
                                  HapticFeedback.selectionClick();
                                } catch (_) {}
                                setState(() {
                                  _hour12 = index + 1;
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 12,
                                builder: (context, index) {
                                  final hour = index + 1;
                                  final isSelected = _hour12 == hour;
                                  return Center(
                                    child: Text(
                                      '${hour.toString().padLeft(2, '0')}시',
                                      style: TextStyle(
                                        fontSize: isSelected ? 21 : 16,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                        color: isSelected
                                            ? (isDark ? Colors.white : AppColors.primaryDark)
                                            : context.textMuted.withValues(alpha: 0.6),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // 중앙 구분 콜론
                          Text(
                            ':',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryLight,
                            ),
                          ),

                          // 분 휠 (00 ~ 59)
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              controller: _minuteController,
                              itemExtent: _itemExtent,
                              physics: const FixedExtentScrollPhysics(),
                              perspective: 0.003,
                              onSelectedItemChanged: (index) {
                                try {
                                  HapticFeedback.selectionClick();
                                } catch (_) {}
                                setState(() {
                                  _minute = index;
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 60,
                                builder: (context, index) {
                                  final isSelected = _minute == index;
                                  return Center(
                                    child: Text(
                                      '${index.toString().padLeft(2, '0')}분',
                                      style: TextStyle(
                                        fontSize: isSelected ? 21 : 16,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                        color: isSelected
                                            ? (isDark ? Colors.white : AppColors.primaryDark)
                                            : context.textMuted.withValues(alpha: 0.6),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 상단 & 하단 부드러운 그라데이션 페이드
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 24,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                                  (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)).withValues(alpha: 0.0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 24,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)).withValues(alpha: 0.0),
                                  (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2-3. 빠른 선택 프리셋 칩
                Row(
                  children: [
                    Icon(Icons.bolt_rounded, size: 14, color: AppColors.primaryLight),
                    const SizedBox(width: 4),
                    Text(
                      '빠른 프리셋 선택 (24시간 기준: $_formatted24h)',
                      style: TextStyle(
                        color: context.textMuted,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildQuickChip(
                      label: '기상 07:00',
                      hour24: 7,
                      minute: 0,
                      isDark: isDark,
                    ),
                    _buildQuickChip(
                      label: '출근 08:30',
                      hour24: 8,
                      minute: 30,
                      isDark: isDark,
                    ),
                    _buildQuickChip(
                      label: '점심 12:30',
                      hour24: 12,
                      minute: 30,
                      isDark: isDark,
                    ),
                    _buildQuickChip(
                      label: '퇴근 18:30',
                      hour24: 18,
                      minute: 30,
                      isDark: isDark,
                    ),
                    _buildQuickChip(
                      label: '저녁 21:00',
                      hour24: 21,
                      minute: 0,
                      isDark: isDark,
                    ),
                    _buildQuickChip(
                      label: '취침 23:00',
                      hour24: 23,
                      minute: 0,
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. 하단 액션 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(color: borderColor),
                        backgroundColor: isDark
                            ? const Color(0xFF334155).withValues(alpha: 0.3)
                            : const Color(0xFFF1F5F9),
                      ),
                      child: Text(
                        '취소',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 6,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          try {
                            HapticFeedback.mediumImpact();
                          } catch (_) {}
                          Navigator.pop(context, _currentTimeOfDay);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_rounded, color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text(
                              '시간 설정 완료',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
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

  /// 오전 / 오후 세그먼트 탭
  Widget _buildAmPmTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? AppColors.primaryLight
                    : context.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? context.textPrimary
                      : context.textMuted,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 빠른 선택 칩 버튼
  Widget _buildQuickChip({
    required String label,
    required int hour24,
    required int minute,
    required bool isDark,
  }) {
    final isSelected = _currentTimeOfDay.hour == hour24 && _currentTimeOfDay.minute == minute;

    return InkWell(
      onTap: () => _setPreset(hour24, minute),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.20)
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.4 : 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (isDark ? const Color(0xFFDDD6FE) : AppColors.primary)
                : context.textSecondary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
