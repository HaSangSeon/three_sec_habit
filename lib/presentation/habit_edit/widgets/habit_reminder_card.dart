import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_sec_habit/core/constants/app_colors.dart';
import 'package:three_sec_habit/core/services/notification_service.dart';
import 'package:three_sec_habit/models/habit.dart';

/// 직관적이고 고급스러운 프리미엄 알림 설정 카드
/// - [특정 시각 알림] vs [규칙적 간격 알림]을 최상단 탭으로 완전 분리하여 혼란 0% 달성
/// - 특정 시각 모드: 대형 디지털 시계 목록 및 직관적인 시간 추가/수정
/// - 시간 간격 모드: 활동 시간대(시작~종료), 간격 선택, 실시간 예정 알림(총 N회) 타임라인 미리보기
/// - 알림 테스트 발송 기능 탑재
class HabitReminderCard extends StatelessWidget {
  final bool reminderEnabled;
  final ReminderType reminderType;
  final List<TimeOfDay> reminderTimes;
  final int reminderIntervalMinutes;
  final TimeOfDay? reminderStartTime;
  final TimeOfDay? reminderEndTime;
  final List<int> suggestedIntervals;
  final HabitType habitType;
  final int targetCount;
  final String habitTitle;
  final String reminderSubtitle;
  final ValueChanged<bool> onReminderEnabledChanged;
  final ValueChanged<ReminderType> onReminderTypeChanged;
  final ValueChanged<int> onEditFixedTime;
  final ValueChanged<int> onRemoveFixedTime;
  final VoidCallback onAddFixedTime;
  final ValueChanged<int> onIntervalMinutesChanged;
  final bool isNightExcluded;
  final ValueChanged<bool> onNightExcludedChanged;
  final VoidCallback? onSelectStartTime;
  final VoidCallback? onSelectEndTime;

  const HabitReminderCard({
    super.key,
    required this.reminderEnabled,
    required this.reminderType,
    required this.reminderTimes,
    required this.reminderIntervalMinutes,
    required this.reminderStartTime,
    required this.reminderEndTime,
    required this.suggestedIntervals,
    required this.habitType,
    required this.targetCount,
    required this.habitTitle,
    required this.reminderSubtitle,
    required this.onReminderEnabledChanged,
    required this.onReminderTypeChanged,
    required this.onEditFixedTime,
    required this.onRemoveFixedTime,
    required this.onAddFixedTime,
    required this.onIntervalMinutesChanged,
    required this.isNightExcluded,
    required this.onNightExcludedChanged,
    this.onSelectStartTime,
    this.onSelectEndTime,
  });

  // ==========================================
  // 간격 알림 시 실시간 스케줄 슬롯 목록 계산
  // ==========================================
  List<({String period, String time, bool isDawn})> _calculateIntervalPreviewSlots() {
    final start = reminderStartTime ?? const TimeOfDay(hour: 9, minute: 0);
    final end = reminderEndTime ?? const TimeOfDay(hour: 21, minute: 0);

    final startMin = start.hour * 60 + start.minute;
    int endMin = end.hour * 60 + end.minute;
    if (endMin <= startMin) {
      endMin += 24 * 60;
    }

    final interval = reminderIntervalMinutes.clamp(15, 720);
    final List<({String period, String time, bool isDawn})> slots = [];
    int cur = startMin;

    while (cur <= endMin && slots.length < 48) {
      final rawHour = cur ~/ 60;
      final h = rawHour % 24;
      final m = cur % 60;
      final isPm = h >= 12;
      final displayH = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      final mStr = m.toString().padLeft(2, '0');
      final period = isPm ? '오후' : '오전';
      final isDawn = (h >= 22 || h < 9);
      slots.add((period: period, time: '$displayH:$mStr', isDawn: isDawn));
      cur += interval;
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final bool isFixedMode = reminderType == ReminderType.fixed;

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: reminderEnabled
              ? AppColors.primary.withValues(
                  alpha: context.isDarkMode ? 0.45 : 0.3,
                )
              : context.surfaceBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: reminderEnabled
                ? AppColors.primary.withValues(
                    alpha: context.isDarkMode ? 0.15 : 0.05,
                  )
                : Colors.black.withValues(
                    alpha: context.isDarkMode ? 0.12 : 0.03,
                  ),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 헤더: 실천 알림 마스터 스위치
          _buildHeader(context),

          if (reminderEnabled) ...[
            Divider(color: context.surfaceBorder, height: 1),

            // 2. 알림 방식 선택 탭 (특정 시각 알림 vs 규칙적 간격 알림)
            _buildModeSelector(context),

            const SizedBox(height: 4),

            // 3. 모드별 컨텐츠 (완전 분리)
            if (isFixedMode)
              _buildFixedTimeMode(context)
            else
              _buildIntervalTimeMode(context),

            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // 1. 헤더 (알림 ON/OFF 스위치)
  // ==========================================
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: reminderEnabled
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: reminderEnabled
                  ? null
                  : (context.isDarkMode
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04)),
              borderRadius: BorderRadius.circular(14),
              boxShadow: reminderEnabled
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              size: 22,
              color: reminderEnabled ? Colors.white : context.textMuted,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '실천 알림',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: reminderEnabled
                            ? const Color(0xFF10B981).withValues(alpha: 0.16)
                            : context.textMuted.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        reminderEnabled ? '켜짐' : '꺼짐',
                        style: TextStyle(
                          color: reminderEnabled
                              ? const Color(0xFF10B981)
                              : context.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  reminderSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: reminderEnabled
                        ? AppColors.primaryLight
                        : context.textMuted,
                    fontSize: 12,
                    fontWeight: reminderEnabled
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.05,
            child: Switch(
              value: reminderEnabled,
              activeTrackColor: AppColors.primary,
              activeThumbColor: Colors.white,
              onChanged: (val) async {
                if (val) {
                  final isGranted = await NotificationService
                      .checkSystemNotificationPermission();
                  if (!isGranted && context.mounted) {
                    final requested = await NotificationService
                        .requestSystemNotificationPermission();
                    if (!requested && context.mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.notifications_off_rounded,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                    '기기 설정에서 알림 권한을 켜주셔야 알림이 정상적으로 울립니다.'),
                              ),
                            ],
                          ),
                          backgroundColor: AppColors.fireOrange,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  }
                }
                onReminderEnabledChanged(val);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. 알림 방식 선택 세그먼트 탭
  // ==========================================
  Widget _buildModeSelector(BuildContext context) {
    final isFixed = reminderType == ReminderType.fixed;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: context.isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.surfaceBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 탭 1: 특정 시각 알림
            Expanded(
              child: _buildModeTabButton(
                context,
                title: '특정 시각 알림',
                desc: '아침, 저녁, 식후 등',
                icon: Icons.alarm_rounded,
                isSelected: isFixed,
                onTap: () {
                  if (!isFixed) {
                    onReminderTypeChanged(ReminderType.fixed);
                  }
                },
              ),
            ),
            const SizedBox(width: 4),
            // 탭 2: 규칙적 간격 알림
            Expanded(
              child: _buildModeTabButton(
                context,
                title: '규칙적 간격 알림',
                desc: '1~3시간마다 반복',
                icon: Icons.update_rounded,
                isSelected: !isFixed,
                onTap: () {
                  if (isFixed) {
                    onReminderTypeChanged(ReminderType.interval);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTabButton(
    BuildContext context, {
    required String title,
    required String desc,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          try {
            HapticFeedback.selectionClick();
          } catch (_) {}
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.32),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 15,
                    color: isSelected ? Colors.white : context.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w700,
                        color: isSelected ? Colors.white : context.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.88)
                      : context.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 3-A. [모드 1] 특정 시각 알림 모드 컨텐츠
  // ==========================================
  Widget _buildFixedTimeMode(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // 등록된 시간 카드 목록
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '설정된 알림 시간 (${reminderTimes.length}개)',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              ...reminderTimes.asMap().entries.map((entry) {
                final index = entry.key;
                final time = entry.value;
                final isPm = time.hour >= 12;
                final displayHour = time.hour == 0
                    ? 12
                    : (time.hour > 12 ? time.hour - 12 : time.hour);
                final hourStr = displayHour.toString().padLeft(2, '0');
                final minuteStr = time.minute.toString().padLeft(2, '0');
                final periodStr = isPm ? '오후' : '오전';

                final orderTag = '${index + 1}차 알림';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        try {
                          HapticFeedback.lightImpact();
                        } catch (_) {}
                        onEditFixedTime(index);
                      },
                      child: Ink(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: context.isDarkMode
                              ? Colors.white.withValues(alpha: 0.05)
                              : AppColors.primary.withValues(alpha: 0.035),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withValues(
                                alpha: context.isDarkMode ? 0.3 : 0.18),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 순서 배지 및 디지털 시계 (작은 화면 대응 FittedBox)
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // 1. 순서 태그 배지 (아침 식후 / 1차 알림 등)
                                    Container(
                                      height: 28,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 9),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                            alpha: context.isDarkMode
                                                ? 0.22
                                                : 0.12),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.primary.withValues(
                                              alpha: context.isDarkMode
                                                  ? 0.4
                                                  : 0.25),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Text(
                                        orderTag,
                                        style: const TextStyle(
                                          color: AppColors.primaryLight,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11.5,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),

                                    // 2. 오전/오후 구분 배지 (크기 및 가독성 대폭 강화)
                                    Container(
                                      height: 28,
                                      constraints: const BoxConstraints(
                                          minWidth: 44),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: (isPm
                                                ? AppColors.fireOrange
                                                : const Color(0xFF0284C7))
                                            .withValues(
                                                alpha: context.isDarkMode
                                                    ? 0.24
                                                    : 0.14),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        border: Border.all(
                                          color: (isPm
                                                  ? AppColors.fireOrange
                                                  : const Color(0xFF0284C7))
                                              .withValues(
                                                  alpha: context.isDarkMode
                                                      ? 0.45
                                                      : 0.3),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Text(
                                        periodStr,
                                        style: TextStyle(
                                          color: isPm
                                              ? AppColors.fireOrange
                                              : (context.isDarkMode
                                                  ? const Color(0xFF38BDF8)
                                                  : const Color(0xFF0284C7)),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12.5,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    // 3. 디지털 시계 (시간:분)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          hourStr,
                                          style: TextStyle(
                                            color: context.textPrimary,
                                            fontSize: 25,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -0.5,
                                            fontFeatures: const [
                                              FontFeature.tabularFigures()
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 2.5),
                                          child: Text(
                                            ':',
                                            style: TextStyle(
                                              color: AppColors.primaryLight
                                                  .withValues(alpha: 0.75),
                                              fontSize: 21,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          minuteStr,
                                          style: TextStyle(
                                            color: context.textPrimary,
                                            fontSize: 25,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -0.5,
                                            fontFeatures: const [
                                              FontFeature.tabularFigures()
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // 4. 변경 및 삭제 액션 버튼 영역
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // 변경 버튼
                                Container(
                                  height: 32,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primaryLight
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.25),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1.5),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 13.5,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '변경',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (reminderTimes.length > 1) ...[
                                  const SizedBox(width: 6),
                                  // 삭제(X) 버튼
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      onTap: () =>
                                          onRemoveFixedTime(index),
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: context.isDarkMode
                                              ? Colors.white.withValues(
                                                  alpha: 0.08)
                                              : Colors.black.withValues(
                                                  alpha: 0.04),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: context.surfaceBorder,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 16,
                                          color: context.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              if (reminderTimes.length < 6)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: onAddFixedTime,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline_rounded,
                                size: 18,
                                color: AppColors.primaryLight,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '+ 알림 시간 추가하기 (최대 6개)',
                                style: TextStyle(
                                  color: AppColors.primaryLight,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 3-B. [모드 2] 규칙적 시간 간격 알림 모드 컨텐츠
  // ==========================================
  Widget _buildIntervalTimeMode(BuildContext context) {
    final previewSlots = _calculateIntervalPreviewSlots();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 알림 간격 선택 (30분마다 / 1시간마다 / 2시간마다 / 3시간마다)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '알림 간격',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '주기마다 알림이 울립니다',
                style: TextStyle(
                  color: context.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: suggestedIntervals.map((mins) {
              final isSelected = reminderIntervalMinutes == mins;
              final label = mins < 60 ? '$mins분마다' : '${mins ~/ 60}시간마다';

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    try {
                      HapticFeedback.selectionClick();
                    } catch (_) {}
                    onIntervalMinutesChanged(mins);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryLight
                              ],
                            )
                          : null,
                      color: isSelected
                          ? null
                          : (context.isDarkMode
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.black.withValues(alpha: 0.03)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : context.surfaceBorder,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : context.textPrimary,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          // 2. 새벽 수면 시간 제외 토글 카드
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                try {
                  HapticFeedback.selectionClick();
                } catch (_) {}
                onNightExcludedChanged(!isNightExcluded);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.025),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isNightExcluded
                        ? AppColors.primary.withValues(alpha: 0.35)
                        : context.surfaceBorder,
                    width: 1.0,
                  ),
                ),
                child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isNightExcluded
                            ? const Color(0xFFF59E0B)
                            : context.textMuted)
                        .withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    Icons.nightlight_round,
                    size: 18,
                    color: isNightExcluded
                        ? const Color(0xFFF59E0B)
                        : context.textMuted,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '새벽 시간 제외',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isNightExcluded
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : context.textMuted.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isNightExcluded ? '수면 보호' : '24시간 알림',
                              style: TextStyle(
                                color: isNightExcluded
                                    ? AppColors.primaryLight
                                    : context.textMuted,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isNightExcluded
                            ? '밤 9시 ~ 아침 9시(수면 시간) 알림 제외'
                            : '새벽을 포함하여 24시간 알림 발송',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.textMuted,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: isNightExcluded,
                    onChanged: (val) {
                      try {
                        HapticFeedback.selectionClick();
                      } catch (_) {}
                      onNightExcludedChanged(val);
                    },
                    activeTrackColor: AppColors.primary,
                    activeThumbColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

          const SizedBox(height: 14),

          // 3. 예정된 알림 일정 미리보기 (4열 균일 그리드로 완벽 정렬)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: context.isDarkMode
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.surfaceBorder,
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: AppColors.primaryLight,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '오늘 예정된 알림',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '총 ${previewSlots.length}회',
                              style: const TextStyle(
                                color: AppColors.primaryLight,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isNightExcluded
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: isNightExcluded
                              ? AppColors.primary.withValues(alpha: 0.25)
                              : const Color(0xFFF59E0B).withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isNightExcluded
                                ? Icons.shield_outlined
                                : Icons.all_inclusive_rounded,
                            size: 11,
                            color: isNightExcluded
                                ? AppColors.primaryLight
                                : const Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isNightExcluded ? '새벽 제외' : '24시간 연속',
                            style: TextStyle(
                              color: isNightExcluded
                                  ? AppColors.primaryLight
                                  : const Color(0xFFF59E0B),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const int columns = 4;
                    const double spacing = 6.0;
                    final double itemWidth =
                        ((constraints.maxWidth - (spacing * (columns - 1))) /
                            columns).floorToDouble();

                    return AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: previewSlots.map((slot) {
                          final isDawn = slot.isDawn && !isNightExcluded;
                          return SizedBox(
                            width: itemWidth,
                            child: Container(
                              height: 33,
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: isDawn
                                    ? const Color(0xFFF59E0B).withValues(
                                        alpha: context.isDarkMode ? 0.18 : 0.10)
                                    : AppColors.primary.withValues(
                                        alpha:
                                            context.isDarkMode ? 0.14 : 0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDawn
                                      ? const Color(0xFFF59E0B).withValues(
                                          alpha:
                                              context.isDarkMode ? 0.45 : 0.35)
                                      : AppColors.primary.withValues(
                                          alpha:
                                              context.isDarkMode ? 0.30 : 0.20),
                                  width: 0.9,
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isDawn) ...[
                                      const Icon(
                                        Icons.nightlight_round,
                                        size: 10,
                                        color: Color(0xFFF59E0B),
                                      ),
                                      const SizedBox(width: 2.5),
                                    ],
                                    Text(
                                      slot.period,
                                      style: TextStyle(
                                        color: isDawn
                                            ? const Color(0xFFF59E0B)
                                            : (context.isDarkMode
                                                ? AppColors.primaryLight
                                                : const Color(0xFF6B7280)),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      slot.time,
                                      style: TextStyle(
                                        color: isDawn
                                            ? (context.isDarkMode
                                                ? const Color(0xFFFCD34D)
                                                : const Color(0xFFD97706))
                                            : (context.isDarkMode
                                                ? Colors.white
                                                : const Color(0xFF1F2937)),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures()
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
