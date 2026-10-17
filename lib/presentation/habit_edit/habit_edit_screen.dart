import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:three_sec_habit/core/constants/app_colors.dart';
import 'package:three_sec_habit/core/constants/app_icons.dart';
import 'package:three_sec_habit/core/utils/date_util.dart';
import 'package:three_sec_habit/models/habit.dart';
import 'package:three_sec_habit/presentation/common/time_picker_select_dialog.dart';
import 'package:three_sec_habit/presentation/habit_edit/widgets/habit_delete_dialog.dart';
import 'package:three_sec_habit/presentation/habit_edit/widgets/habit_icon_color_card.dart';
import 'package:three_sec_habit/presentation/habit_edit/widgets/habit_reminder_card.dart';
import 'package:three_sec_habit/presentation/habit_edit/widgets/habit_repeat_card.dart';
import 'package:three_sec_habit/presentation/habit_edit/widgets/habit_target_count_card.dart';
import 'package:three_sec_habit/presentation/habit_edit/widgets/habit_title_card.dart';
import 'package:three_sec_habit/presentation/habit_edit/widgets/senior_habit_presets_card.dart';
import 'package:three_sec_habit/presentation/habit_edit/widgets/target_count_help_dialog.dart';
import 'package:three_sec_habit/presentation/home/widgets/ad_banner_slot.dart';
import 'package:three_sec_habit/providers/habit_provider.dart';
import 'package:three_sec_habit/providers/theme_provider.dart';

/// 시니어 친화적 초프리미엄 습관 추가 및 편집 화면
/// - 어르신을 위한 1-터치 빠른 추천 습관 (복약, 산책, 스트레칭 등)
/// - 크고 시원시원한 디지털 시계 카드 및 원터치 알림 프리셋
/// - 부드러운 햅틱 반응과 넉넉한 터치 타겟 (44px 이상)
class HabitEditScreen extends StatefulWidget {
  final Habit? habit; // null이면 신규 추가, 있으면 수정 모드
  final int initialTabIndex; // 하단 탭 인덱스 동기화 (기본 2: 습관 등록)

  const HabitEditScreen({
    super.key,
    this.habit,
    this.initialTabIndex = 2,
  });

  @override
  State<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends State<HabitEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _unitController;
  late String _unit;

  late HabitType _habitType;
  late int _targetCount;

  late String _selectedIconKey;
  late int _selectedColorValue;
  late RepeatType _repeatType;
  late List<int> _repeatDays;
  late int _repeatCount;

  late bool _reminderEnabled;
  late ReminderType _reminderType;
  late List<TimeOfDay> _reminderTimes;
  late int _reminderIntervalMinutes;
  TimeOfDay? _reminderStartTime;
  TimeOfDay? _reminderEndTime;

  late int _currentTabIndex;

  bool get _isEditing => widget.habit != null;

  static const List<String> _suggestedUnits = [
    '잔',
    '회',
    '번',
    '세트',
    '분',
    '쪽',
    'km'
  ];
  static const List<int> _suggestedIntervals = [30, 60, 120, 180];

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _titleController = TextEditingController(text: h?.title ?? '');
    _unit = h?.unit ?? '회';
    _unitController = TextEditingController(text: _unit);

    _habitType = h?.habitType ?? HabitType.check;
    _targetCount =
        h?.targetCount ?? (h?.habitType == HabitType.count ? 8 : 1);

    _selectedIconKey = h?.iconName ?? 'water_drop';
    _selectedColorValue = h?.colorValue ?? 0xFF8B5CF6;
    _repeatType = h?.repeatType ?? RepeatType.daily;
    _repeatDays = h?.repeatDays != null
        ? List<int>.from(h!.repeatDays)
        : [1, 2, 3, 4, 5, 6, 7];
    _repeatCount = h?.repeatCount ?? 3;

    _reminderEnabled = h?.reminderEnabled ?? true;
    _reminderType = h?.reminderType ?? ReminderType.fixed;
    _reminderIntervalMinutes = h?.reminderIntervalMinutes ?? 60;

    if (h != null && h.reminderTimes.isNotEmpty) {
      _reminderTimes = h.reminderTimes.map((tStr) {
        final parts = tStr.split(':');
        return TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 8,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }).toList();
    } else if (h?.reminderTime != null && h!.reminderTime!.contains(':')) {
      final parts = h.reminderTime!.split(':');
      _reminderTimes = [
        TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 8,
          minute: int.tryParse(parts[1]) ?? 0,
        ),
      ];
    } else {
      _reminderTimes = [const TimeOfDay(hour: 8, minute: 30)];
    }
    _sortReminderTimes();

    if (h?.reminderStartTime != null && h!.reminderStartTime!.contains(':')) {
      final parts = h.reminderStartTime!.split(':');
      _reminderStartTime = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 9,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    } else {
      _reminderStartTime = const TimeOfDay(hour: 9, minute: 0);
    }

    if (h?.reminderEndTime != null && h!.reminderEndTime!.contains(':')) {
      final parts = h.reminderEndTime!.split(':');
      _reminderEndTime = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 21,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    } else {
      _reminderEndTime = const TimeOfDay(hour: 21, minute: 0);
    }

    _currentTabIndex = widget.initialTabIndex;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _sortReminderTimes() {
    _reminderTimes.sort((a, b) {
      final minA = a.hour * 60 + a.minute;
      final minB = b.hour * 60 + b.minute;
      return minA.compareTo(minB);
    });
  }

  String _getReminderSubtitle() {
    if (!_reminderEnabled) return '알림 미사용 (필요할 때 켜세요)';

    final periodStr = switch (_repeatType) {
      RepeatType.daily => '매일',
      RepeatType.weeklyDays =>
        _repeatDays.length == 7 ? '매일 (월~일)' : '선택한 요일마다',
      RepeatType.weeklyCount => '주 $_repeatCount회 달성 전까지',
    };

    if (_reminderType == ReminderType.fixed) {
      if (_reminderTimes.isNotEmpty) {
        if (_reminderTimes.length == 1) {
          final t = _reminderTimes.first;
          final isPm = t.hour >= 12;
          final h = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
          final mStr = t.minute > 0 ? '${t.minute}분' : '정각';
          return '$periodStr ${isPm ? "오후" : "오전"} $h시 $mStr 알림';
        } else {
          return '$periodStr 하루 ${_reminderTimes.length}회 지정 시각 알림';
        }
      }
      return '$periodStr 지정 시간 알림';
    } else {
      final intervalStr = _reminderIntervalMinutes < 60
          ? '$_reminderIntervalMinutes분'
          : '${_reminderIntervalMinutes ~/ 60}시간';
      if (_isNightExcluded) {
        return '매일 $intervalStr 간격 (새벽 제외)';
      } else {
        return '매일 $intervalStr 간격 (24시간 연속)';
      }
    }
  }

  /// 새벽(야간 수면) 시간 제외 여부
  bool get _isNightExcluded => !(_reminderStartTime?.hour == 0 &&
      (_reminderEndTime?.hour == 23 ||
          _reminderEndTime?.hour == 24 ||
          _reminderEndTime?.hour == 0));

  /// 새벽 시간 제외 스위치 토글 핸들러
  void _onNightExcludedChanged(bool excluded) {
    setState(() {
      if (excluded) {
        _reminderStartTime = const TimeOfDay(hour: 9, minute: 0);
        _reminderEndTime = const TimeOfDay(hour: 21, minute: 0);
      } else {
        _reminderStartTime = const TimeOfDay(hour: 0, minute: 0);
        _reminderEndTime = const TimeOfDay(hour: 23, minute: 59);
      }
    });
  }

  /// 어르신 추천 프리셋 1-터치 적용
  void _applySeniorPreset(SeniorHabitPreset preset) {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

    setState(() {
      _titleController.text = preset.title;
      _selectedIconKey = preset.iconKey;
      _selectedColorValue = preset.colorValue;
      _reminderEnabled = true;
      _reminderType = preset.reminderType;
      if (preset.reminderType == ReminderType.fixed) {
        _reminderTimes = List<TimeOfDay>.from(preset.reminderTimes);
        _sortReminderTimes();
      } else {
        _reminderIntervalMinutes = preset.reminderIntervalMinutes;
        _reminderStartTime =
            preset.reminderStartTime ?? const TimeOfDay(hour: 9, minute: 0);
        _reminderEndTime =
            preset.reminderEndTime ?? const TimeOfDay(hour: 21, minute: 0);
      }
      _habitType = preset.habitType;
      _targetCount = preset.targetCount;
      _unit = preset.unit;
      _unitController.text = preset.unit;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '✨ "${preset.title}" 설정이 적용되었습니다.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _editFixedTime(int index) async {
    final picked = await TimePickerSelectDialog.show(
      context: context,
      initialTime: _reminderTimes[index],
      title: '${index + 1}차 알림 시간 변경',
    );
    if (picked != null) {
      setState(() {
        _reminderTimes[index] = picked;
        _sortReminderTimes();
      });
    }
  }

  Future<void> _addFixedTime() async {
    if (_reminderTimes.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('알림 시간은 최대 6개까지 추가 가능합니다.')),
      );
      return;
    }
    final lastTime = _reminderTimes.isNotEmpty
        ? _reminderTimes.last
        : const TimeOfDay(hour: 8, minute: 30);
    final initialNext = TimeOfDay(
      hour: (lastTime.hour + 4) % 24,
      minute: lastTime.minute,
    );

    final picked = await TimePickerSelectDialog.show(
      context: context,
      initialTime: initialNext,
      title: '${_reminderTimes.length + 1}차 알림 시간 추가',
    );
    if (picked != null) {
      final exists = _reminderTimes.any(
        (t) => t.hour == picked.hour && t.minute == picked.minute,
      );
      if (exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이미 등록된 알림 시간입니다.')),
          );
        }
        return;
      }
      setState(() {
        _reminderTimes.add(picked);
        _sortReminderTimes();
      });
    }
  }

  void _removeFixedTime(int index) {
    if (_reminderTimes.length <= 1) return;
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
    setState(() {
      _reminderTimes.removeAt(index);
    });
  }

  Future<void> _selectStartTime() async {
    final picked = await TimePickerSelectDialog.show(
      context: context,
      initialTime: _reminderStartTime ?? const TimeOfDay(hour: 9, minute: 0),
      title: '알림 시작 시간 설정',
    );
    if (picked != null) {
      setState(() => _reminderStartTime = picked);
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await TimePickerSelectDialog.show(
      context: context,
      initialTime: _reminderEndTime ?? const TimeOfDay(hour: 21, minute: 0),
      title: '알림 종료 시간 설정',
    );
    if (picked != null) {
      setState(() => _reminderEndTime = picked);
    }
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

    final title = _titleController.text.trim();

    // 간격 알림 선택 시 시작 시간 < 종료 시간 유효성 검증
    if (_reminderEnabled && _reminderType == ReminderType.interval) {
      final startMin = (_reminderStartTime?.hour ?? 9) * 60 +
          (_reminderStartTime?.minute ?? 0);
      final endMin =
          (_reminderEndTime?.hour ?? 21) * 60 + (_reminderEndTime?.minute ?? 0);
      if (endMin <= startMin) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline_rounded,
                    color: Colors.white, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('알림 종료 시간은 시작 시간보다 늦어야 합니다.')),
              ],
            ),
            backgroundColor: AppColors.fireOrange,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }
    }

    final unitText = _unitController.text.trim().isNotEmpty
        ? _unitController.text.trim()
        : '회';

    final reminderTimeStr = _reminderTimes.isNotEmpty
        ? _reminderTimes
            .map((t) => DateUtil.formatTime(t.hour, t.minute))
            .join(',')
        : null;
    final reminderStartStr = _reminderStartTime != null
        ? DateUtil.formatTime(
            _reminderStartTime!.hour, _reminderStartTime!.minute)
        : null;
    final reminderEndStr = _reminderEndTime != null
        ? DateUtil.formatTime(_reminderEndTime!.hour, _reminderEndTime!.minute)
        : null;

    final habitProvider = context.read<HabitProvider>();

    if (_isEditing) {
      final updated = widget.habit!.copyWith(
        title: title,
        iconName: _selectedIconKey,
        colorValue: _selectedColorValue,
        habitType: _habitType,
        targetCount: _habitType == HabitType.count ? _targetCount : 1,
        unit: unitText,
        repeatType: _repeatType,
        repeatDays: _repeatDays,
        repeatCount: _repeatCount,
        reminderType: _reminderType,
        reminderEnabled: _reminderEnabled,
        reminderTime: reminderTimeStr,
        reminderIntervalMinutes: _reminderIntervalMinutes,
        reminderStartTime: reminderStartStr,
        reminderEndTime: reminderEndStr,
      );
      await habitProvider.updateHabit(updated);
    } else {
      final newHabit = Habit(
        title: title,
        iconName: _selectedIconKey,
        colorValue: _selectedColorValue,
        habitType: _habitType,
        targetCount: _habitType == HabitType.count ? _targetCount : 1,
        unit: unitText,
        repeatType: _repeatType,
        repeatDays: _repeatDays,
        repeatCount: _repeatCount,
        reminderType: _reminderType,
        reminderEnabled: _reminderEnabled,
        reminderTime: reminderTimeStr,
        reminderIntervalMinutes: _reminderIntervalMinutes,
        reminderStartTime: reminderStartStr,
        reminderEndTime: reminderEndStr,
      );
      await habitProvider.addHabit(newHabit);
    }

    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _deleteHabit() async {
    if (!_isEditing) return;

    final habitTitle = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : (widget.habit?.title ?? '이 습관');
    final habitIcon =
        AppIcons.getIcon(widget.habit?.iconName ?? _selectedIconKey);
    final habitColor =
        Color(widget.habit?.colorValue ?? _selectedColorValue);

    final confirmed = await HabitDeleteDialog.show(
      context,
      habitTitle: habitTitle,
      habitIcon: habitIcon,
      habitColor: habitColor,
    );

    if (confirmed == true && mounted) {
      await context.read<HabitProvider>().deleteHabit(widget.habit!.id!);
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
    }
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primaryLight),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        border: Border(
          top: BorderSide(
            color: context.surfaceBorder.withValues(alpha: 0.7),
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: context.isDarkMode ? 0.25 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdBannerSlot(),
          SafeArea(
            top: false,
            child: SizedBox(
              height: 54,
              child: Row(
                children: [
                  _buildTabItem(
                    index: 0,
                    icon: Icons.check_circle_outline_rounded,
                    activeIcon: Icons.check_circle_rounded,
                    label: '오늘의 습관',
                  ),
                  _buildTabItem(
                    index: 1,
                    icon: Icons.bar_chart_outlined,
                    activeIcon: Icons.bar_chart_rounded,
                    label: '통계/기록',
                  ),
                  _buildTabItem(
                    index: 2,
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings_rounded,
                    label: '설정',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentTabIndex == index;
    final activeColor = AppColors.primaryLight;
    final inactiveColor = context.textMuted.withValues(alpha: 0.65);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            try {
              HapticFeedback.selectionClick();
            } catch (_) {}
            Navigator.of(context).pop(index);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                          .withValues(alpha: context.isDarkMode ? 0.22 : 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? activeColor : inactiveColor,
                  size: 22,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveColor,
                  letterSpacing: -0.2,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = Color(_selectedColorValue);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            // 뒤로가기 버튼 (다른 화면과 조화로운 38x38 규격)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.surfaceBorder, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: context.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 그라데이션 타이틀 배지
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _isEditing ? '습관 편집' : '새 습관',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(width: 8),

            Text(
              _isEditing ? '설정 변경' : '만들기',
              style: TextStyle(
                color: context.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18.5,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 다크/라이트 모드 전환 버튼 (다른 화면과 통일된 38x38 규격)
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return Tooltip(
                      message: themeProvider.isDarkMode ? '라이트 모드 전환' : '다크 모드 전환',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          try {
                            HapticFeedback.selectionClick();
                          } catch (_) {}
                          themeProvider.toggleTheme(!themeProvider.isDarkMode);
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.surface,
                            border: Border.all(
                              color: context.surfaceBorder,
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            themeProvider.isDarkMode
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded,
                            size: 18,
                            color: themeProvider.isDarkMode
                                ? const Color(0xFFFBBF24)
                                : context.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // 삭제 버튼 (수정 모드일 때만 표시, 다른 화면과 통일된 38x38 규격)
                if (_isEditing) ...[
                  const SizedBox(width: 8),
                  Tooltip(
                    message: '습관 삭제',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _deleteHabit,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEF4444).withValues(alpha: context.isDarkMode ? 0.18 : 0.08),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withValues(alpha: context.isDarkMode ? 0.35 : 0.2),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEF4444).withValues(alpha: context.isDarkMode ? 0.2 : 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: context.surfaceBorder,
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            children: [
              // 0. 어르신을 위한 1-터치 빠른 추천 습관 (신규 등록 시 최상단 제공)
              if (!_isEditing)
                SeniorHabitPresetsCard(
                  onSelectPreset: _applySeniorPreset,
                ),

              // 1. 습관 이름 입력 카드
              _buildSectionHeader(
                icon: Icons.edit_note_rounded,
                title: '습관 이름',
                subtitle: '무엇을 실천하시나요?',
              ),
              HabitTitleCard(
                titleController: _titleController,
                selectedIconKey: _selectedIconKey,
                currentColor: currentColor,
              ),
              const SizedBox(height: 22),

              // 2. 아이콘 & 테마 색상 선택 카드 (이름 바로 아래에서 비주얼 정체성 완성)
              _buildSectionHeader(
                icon: Icons.palette_rounded,
                title: '아이콘 및 색상',
                subtitle: '원하는 색상과 아이콘을 골라보세요',
              ),
              HabitIconColorCard(
                selectedIconKey: _selectedIconKey,
                selectedColorValue: _selectedColorValue,
                onIconSelected: (key) {
                  setState(() => _selectedIconKey = key);
                },
                onColorSelected: (val) {
                  setState(() => _selectedColorValue = val);
                },
              ),
              const SizedBox(height: 22),

              // 3. 반복 주기 설정 카드 (어떤 요일/주기에 실천할지 선택)
              _buildSectionHeader(
                icon: Icons.calendar_month_rounded,
                title: '반복 주기',
                subtitle: '언제 실천하시나요?',
              ),
              HabitRepeatCard(
                repeatType: _repeatType,
                repeatDays: _repeatDays,
                repeatCount: _repeatCount,
                onRepeatTypeSelected: (type) {
                  setState(() {
                    if (type == RepeatType.weeklyDays &&
                        _repeatType != RepeatType.weeklyDays &&
                        _repeatDays.length == 7) {
                      _repeatDays = [1, 2, 3, 4, 5];
                    }
                    _repeatType = type;
                  });
                },
                onRepeatDaysChanged: (days) {
                  setState(() => _repeatDays = days);
                },
                onRepeatCountChanged: (count) {
                  setState(() => _repeatCount = count);
                },
              ),
              const SizedBox(height: 22),

              // 4. 하루 목표 횟수 설정 카드 (실천량 지정)
              _buildSectionHeader(
                icon: Icons.flag_rounded,
                title: '목표 횟수 (선택)',
                subtitle: '기본 1일 1회 체크',
              ),
              HabitTargetCountCard(
                habitType: _habitType,
                targetCount: _targetCount,
                unitController: _unitController,
                suggestedUnits: _suggestedUnits,
                onHabitTypeToggled: (enabled) {
                  setState(() {
                    _habitType = enabled ? HabitType.count : HabitType.check;
                    if (enabled && _targetCount <= 1) {
                      _targetCount = 8;
                      _unit = '잔';
                      _unitController.text = '잔';
                    }
                  });
                },
                onTargetCountChanged: (count) {
                  setState(() => _targetCount = count);
                },
                onUnitSelected: (u) {
                  setState(() {
                    _unit = u;
                    _unitController.text = u;
                  });
                },
                onHelpPressed: () => TargetCountHelpDialog.show(context),
              ),
              const SizedBox(height: 22),

              // 5. 알림 설정 카드 (실천 규칙 수립 후 마지막 지원 도구로 배치)
              _buildSectionHeader(
                icon: Icons.notifications_active_rounded,
                title: '알림 설정',
                subtitle: '스마트폰이 잊지 않게 알려드려요',
              ),
              HabitReminderCard(
                reminderEnabled: _reminderEnabled,
                reminderType: _reminderType,
                reminderTimes: _reminderTimes,
                reminderIntervalMinutes: _reminderIntervalMinutes,
                reminderStartTime: _reminderStartTime,
                reminderEndTime: _reminderEndTime,
                suggestedIntervals: _suggestedIntervals,
                habitType: _habitType,
                targetCount: _targetCount,
                habitTitle: _titleController.text,
                reminderSubtitle: _getReminderSubtitle(),
                onReminderEnabledChanged: (val) {
                  setState(() => _reminderEnabled = val);
                },
                onReminderTypeChanged: (type) {
                  setState(() => _reminderType = type);
                },
                onEditFixedTime: _editFixedTime,
                onRemoveFixedTime: _removeFixedTime,
                onAddFixedTime: _addFixedTime,
                onIntervalMinutesChanged: (mins) {
                  setState(() => _reminderIntervalMinutes = mins);
                },
                isNightExcluded: _isNightExcluded,
                onNightExcludedChanged: _onNightExcludedChanged,
                onSelectStartTime: _selectStartTime,
                onSelectEndTime: _selectEndTime,
                onSyncTargetCount: () {
                  setState(() => _targetCount = _reminderTimes.length);
                },
              ),
              const SizedBox(height: 32),

              // 6. 하단 저장 버튼 (초프리미엄 56px 대형 와이드 버튼)
              GestureDetector(
                onTap: _saveHabit,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isEditing
                            ? Icons.check_circle_rounded
                            : Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isEditing ? '변경사항 저장하기' : '✨ 3초 습관 시작하기',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }
}
