import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/date_util.dart';
import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import '../common/time_picker_select_dialog.dart';
import '../home/widgets/ad_banner_slot.dart';

/// 습관 추가 및 편집 화면 (프리미엄 UI, 정밀한 정렬 및 디테일)
class HabitEditScreen extends StatefulWidget {
  final Habit? habit; // null이면 신규 추가, 있으면 수정 모드
  final int initialTabIndex;

  const HabitEditScreen({
    super.key,
    this.habit,
    this.initialTabIndex = 0,
  });

  @override
  State<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends State<HabitEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _unitController;

  late HabitType _habitType;
  late int _targetCount;
  late String _unit;

  late String _selectedIconKey;
  late int _selectedColorValue;
  late RepeatType _repeatType;
  late List<int> _repeatDays;
  late int _repeatCount;

  late bool _reminderEnabled;
  late ReminderType _reminderType;
  TimeOfDay? _reminderTime;
  TimeOfDay? _reminderStartTime;
  TimeOfDay? _reminderEndTime;
  late int _reminderIntervalMinutes;

  bool get _isEditing => widget.habit != null;

  static const List<String> _suggestedUnits = ['잔', '회', '번', '세트', '분', '쪽', 'km'];
  static const List<int> _suggestedIntervals = [30, 60, 120, 180];

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _titleController = TextEditingController(text: h?.title ?? '');
    _unit = h?.unit ?? '회';
    _unitController = TextEditingController(text: _unit);

    _habitType = h?.habitType ?? HabitType.check;
    _targetCount = h?.targetCount ?? (h?.habitType == HabitType.count ? 8 : 1);

    _selectedIconKey = h?.iconName ?? 'water_drop';
    _selectedColorValue = h?.colorValue ?? 0xFF8B5CF6;
    _repeatType = h?.repeatType ?? RepeatType.daily;
    _repeatDays = h?.repeatDays != null
        ? List<int>.from(h!.repeatDays)
        : [1, 2, 3, 4, 5, 6, 7];
    _repeatCount = h?.repeatCount ?? 3;

    _reminderEnabled = h?.reminderEnabled ?? false;
    _reminderType = h?.reminderType ?? ReminderType.fixed;
    _reminderIntervalMinutes = h?.reminderIntervalMinutes ?? 60;

    if (h?.reminderTime != null && h!.reminderTime!.contains(':')) {
      final parts = h.reminderTime!.split(':');
      _reminderTime = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 8,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    } else {
      _reminderTime = const TimeOfDay(hour: 8, minute: 0);
    }

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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _selectFixedTime() async {
    final picked = await TimePickerSelectDialog.show(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 8, minute: 0),
      title: '지정 알림 시간 설정',
    );
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
        _reminderEnabled = true;
      });
    }
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
      final startMin =
          (_reminderStartTime?.hour ?? 9) * 60 + (_reminderStartTime?.minute ?? 0);
      final endMin =
          (_reminderEndTime?.hour ?? 21) * 60 + (_reminderEndTime?.minute ?? 0);
      if (endMin <= startMin) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
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

    final reminderTimeStr = _reminderTime != null
        ? DateUtil.formatTime(_reminderTime!.hour, _reminderTime!.minute)
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
    final habitIcon = AppIcons.getIcon(widget.habit?.iconName ?? _selectedIconKey);
    final habitColor = Color(widget.habit?.colorValue ?? _selectedColorValue);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) {
        final isDark = ctx.isDarkMode;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          elevation: 12,
          shadowColor: Colors.black.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. 헤더 영역 (아이콘, 타이틀, 닫기 버튼)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF182234)
                      : const Color(0xFFF8FAFC),
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
                        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '습관 삭제',
                            style: TextStyle(
                              color: ctx.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '데이터가 영구적으로 삭제됩니다',
                            style: TextStyle(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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
                      onPressed: () => Navigator.of(ctx).pop(false),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      splashRadius: 18,
                    ),
                  ],
                ),
              ),

              // 헤더와 내용 구분선
              Divider(
                height: 1,
                thickness: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE2E8F0),
              ),

              // 2. 내용 영역 (선택된 습관 프리뷰 & 안내 텍스트)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 대상 습관 프리뷰 카드
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: habitColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              habitIcon,
                              color: habitColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              habitTitle,
                              style: TextStyle(
                                color: ctx.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 경고 안내 박스
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.18),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 1),
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFEF4444),
                              size: 17,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '이 습관과 관련된 모든 수행 기록, 통계 및 스트릭 데이터가 삭제되며 되돌릴 수 없습니다.',
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFFDA4AF)
                                    : const Color(0xFFBE123C),
                                fontSize: 12.5,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 3. 버튼 영역 (취소 / 삭제 버튼)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Row(
                  children: [
                    // 취소 버튼
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isDark
                                ? const Color(0xFF334155).withValues(alpha: 0.4)
                                : const Color(0xFFF1F5F9),
                            foregroundColor: ctx.textSecondary,
                            side: BorderSide(
                              color: isDark
                                  ? const Color(0xFF475569)
                                  : const Color(0xFFCBD5E1),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            '취소',
                            style: TextStyle(
                              color: ctx.textSecondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // 삭제하기 버튼
                    Expanded(
                      flex: 6,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFEF4444),
                              Color(0xFFDC2626),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(ctx).pop(true),
                            borderRadius: BorderRadius.circular(14),
                            splashColor: Colors.white.withValues(alpha: 0.2),
                            highlightColor: Colors.white.withValues(alpha: 0.1),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '삭제하기',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14.5,
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
      },
    );

    if (confirmed == true && mounted) {
      await context.read<HabitProvider>().deleteHabit(widget.habit!.id!);
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = Color(_selectedColorValue);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: context.surface,
            border: Border(
              bottom: BorderSide(
                color: context.surfaceBorder,
                width: 1.0,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                    alpha: context.isDarkMode ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // 원형 뒤로가기 버튼
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.isDarkMode
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.04),
                        border: Border.all(
                          color: context.surfaceBorder.withValues(alpha: 0.6),
                          width: 0.8,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 그라데이션 뱃지
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isEditing
                            ? [const Color(0xFF7C3AED), AppColors.primaryLight]
                            : [const Color(0xFF10B981), const Color(0xFF34D399)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isEditing ? Icons.tune_rounded : Icons.add_task_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isEditing ? '습관 편집' : '새 습관',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _isEditing ? '설정 및 알림 변경' : '3초 습관 등록',
                    style: TextStyle(
                      color: context.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(),

                  // 고급스러운 삭제 버튼 (수정 모드일 때만 표시)
                  if (_isEditing)
                    GestureDetector(
                      onTap: _deleteHabit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.28),
                            width: 1.0,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              size: 15,
                              color: Color(0xFFEF4444),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '삭제',
                              style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              // 1. 습관 이름 입력 카드
              _buildSectionHeader(
                icon: Icons.edit_note_rounded,
                title: '습관 이름',
                subtitle: '매일 실천할 간결한 습관을 입력하세요',
              ),
              Container(
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.surfaceBorder, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: context.isDarkMode ? 0.15 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    // 현재 선택된 아이콘 미리보기
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: currentColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        AppIcons.getIcon(_selectedIconKey),
                        color: currentColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _titleController,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: '예: 아침 10분 독서, 영양제 복용, 물 마시기',
                          hintStyle: TextStyle(
                            color: context.textMuted,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return '습관 이름을 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. 하루 목표 횟수 설정 (선택 옵션 카드)
              _buildSectionHeader(
                icon: Icons.flag_rounded,
                title: '목표 횟수 (선택)',
                subtitle: '하루 동안 여러 번 누적하는 습관인 경우 켜주세요',
              ),
              Container(
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _habitType == HabitType.count
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : context.surfaceBorder,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: context.isDarkMode ? 0.15 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _habitType == HabitType.count
                                  ? AppColors.primary.withValues(alpha: 0.15)
                                  : (context.isDarkMode
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.04)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.format_list_numbered_rounded,
                              size: 18,
                              color: _habitType == HabitType.count
                                  ? AppColors.primaryLight
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
                                    Text(
                                      '하루 목표 횟수 설정',
                                      style: TextStyle(
                                        color: context.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Tooltip(
                                      message: '하루에 물 8잔, 푸시업 50회처럼 여러 번 누적해서 실천하는 습관일 때 켜주세요.',
                                      triggerMode: TooltipTriggerMode.tap,
                                      showDuration: const Duration(seconds: 4),
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: context.isDarkMode
                                              ? Colors.white.withValues(alpha: 0.08)
                                              : Colors.black.withValues(alpha: 0.06),
                                        ),
                                        child: Icon(
                                          Icons.help_outline_rounded,
                                          size: 13,
                                          color: context.textMuted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _habitType == HabitType.count
                                      ? '하루 목표 $_targetCount${_unitController.text} 누적 완료'
                                      : '기본 1일 1회 체크 (비활성)',
                                  style: TextStyle(
                                    color: _habitType == HabitType.count
                                        ? AppColors.primaryLight
                                        : context.textMuted,
                                    fontSize: 12,
                                    fontWeight: _habitType == HabitType.count
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _habitType == HabitType.count,
                            activeTrackColor: AppColors.primary,
                            activeThumbColor: Colors.white,
                            onChanged: (enabled) {
                              setState(() {
                                _habitType = enabled ? HabitType.count : HabitType.check;
                                if (enabled && _targetCount <= 1) {
                                  _targetCount = 8;
                                  _unit = '잔';
                                  _unitController.text = '잔';
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    if (_habitType == HabitType.count) ...[
                      Divider(color: context.surfaceBorder, height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // 목표 횟수 스테퍼 컨트롤러
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '하루 목표 수치',
                                  style: TextStyle(
                                    color: context.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: _targetCount > 2
                                          ? () => setState(() => _targetCount--)
                                          : null,
                                      child: Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: context.bg,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: context.surfaceBorder),
                                        ),
                                        child: Icon(
                                          Icons.remove_rounded,
                                          size: 18,
                                          color: _targetCount > 2
                                              ? context.textPrimary
                                              : context.textMuted.withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 10),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: AppColors.primary.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Text(
                                        '$_targetCount',
                                        style: const TextStyle(
                                          color: AppColors.primaryLight,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _targetCount < 100
                                          ? () => setState(() => _targetCount++)
                                          : null,
                                      child: Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: context.bg,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: context.surfaceBorder),
                                        ),
                                        child: Icon(
                                          Icons.add_rounded,
                                          size: 18,
                                          color: _targetCount < 100
                                              ? context.textPrimary
                                              : context.textMuted.withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // 단위 선택 칩
                            Row(
                              children: [
                                Text(
                                  '단위',
                                  style: TextStyle(
                                    color: context.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: _suggestedUnits.map((u) {
                                        final isSelected = _unitController.text == u;
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _unit = u;
                                              _unitController.text = u;
                                            });
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(right: 6),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : context.bg,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : context.surfaceBorder,
                                              ),
                                            ),
                                            child: Text(
                                              u,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : context.textSecondary,
                                                fontSize: 12,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. 아이콘 & 테마 색상 선택 카드
              _buildSectionHeader(
                icon: Icons.palette_rounded,
                title: '아이콘 및 색상',
                subtitle: '습관을 상징하는 아이콘과 포인트 컬러를 고르세요',
              ),
              Container(
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.surfaceBorder, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: context.isDarkMode ? 0.15 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 아이콘 그리드
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: AppIcons.icons.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        final item = AppIcons.icons[index];
                        final isSelected = _selectedIconKey == item.key;
                        return GestureDetector(
                          onTap: () {
                            try {
                              HapticFeedback.selectionClick();
                            } catch (_) {}
                            setState(() => _selectedIconKey = item.key);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? currentColor.withValues(alpha: 0.22)
                                  : (context.isDarkMode
                                      ? Colors.white.withValues(alpha: 0.04)
                                      : Colors.black.withValues(alpha: 0.03)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? currentColor
                                    : context.surfaceBorder.withValues(alpha: 0.6),
                                width: isSelected ? 1.8 : 0.8,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                item.icon,
                                color: isSelected
                                    ? currentColor
                                    : context.textSecondary,
                                size: 22,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Divider(color: context.surfaceBorder, height: 1),
                    const SizedBox(height: 14),

                    // 색상 팔레트 스크롤
                    Text(
                      '포인트 색상',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: AppColors.habitColorPalette.map((c) {
                          final isSelected = _selectedColorValue == c.toARGB32();
                          return GestureDetector(
                            onTap: () {
                              try {
                                HapticFeedback.selectionClick();
                              } catch (_) {}
                              setState(() => _selectedColorValue = c.toARGB32());
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? (context.isDarkMode ? Colors.white : Colors.black87)
                                      : Colors.transparent,
                                  width: isSelected ? 2.5 : 0,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: c.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                ],
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. 반복 주기 설정 카드
              _buildSectionHeader(
                icon: Icons.calendar_month_rounded,
                title: '반복 주기',
                subtitle: '습관을 실천할 요일과 주기를 정하세요',
              ),
              Container(
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.surfaceBorder, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: context.isDarkMode ? 0.15 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: RepeatType.values.map((type) {
                          final isSelected = _repeatType == type;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                try {
                                  HapticFeedback.selectionClick();
                                } catch (_) {}
                                setState(() => _repeatType = type);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.18)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(color: AppColors.primary, width: 1.2)
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    type.label,
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.primaryLight
                                          : context.textSecondary,
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    if (_repeatType == RepeatType.weeklyDays) ...[
                      Divider(color: context.surfaceBorder, height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        child: Row(
                          children: List.generate(7, (i) {
                            final day = i + 1;
                            final isSelected = _repeatDays.contains(day);
                            const dayLabels = ['', '월', '화', '수', '목', '금', '토', '일'];
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  try {
                                    HapticFeedback.selectionClick();
                                  } catch (_) {}
                                  setState(() {
                                    if (isSelected) {
                                      if (_repeatDays.length > 1) {
                                        _repeatDays.remove(day);
                                      }
                                    } else {
                                      _repeatDays.add(day);
                                    }
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? const LinearGradient(
                                            colors: [AppColors.primary, AppColors.primaryDark],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    color: isSelected ? null : context.bg,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : context.surfaceBorder,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      dayLabels[day],
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : context.textSecondary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                    if (_repeatType == RepeatType.weeklyCount) ...[
                      Divider(color: context.surfaceBorder, height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '일주일에 몇 번?',
                                  style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: _repeatCount > 1
                                          ? () => setState(() => _repeatCount--)
                                          : null,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: context.bg,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: context.surfaceBorder),
                                        ),
                                        child: Icon(
                                          Icons.remove_rounded,
                                          size: 18,
                                          color: _repeatCount > 1
                                              ? context.textPrimary
                                              : context.textMuted.withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                      child: Text(
                                        '주 $_repeatCount회',
                                        style: const TextStyle(
                                          color: AppColors.primaryLight,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _repeatCount < 7
                                          ? () => setState(() => _repeatCount++)
                                          : null,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: context.bg,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: context.surfaceBorder),
                                        ),
                                        child: Icon(
                                          Icons.add_rounded,
                                          size: 18,
                                          color: _repeatCount < 7
                                              ? context.textPrimary
                                              : context.textMuted.withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: context.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: context.surfaceBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.info_outline_rounded,
                                        size: 14.5,
                                        color: AppColors.primaryLight,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '주 $_repeatCount회 동작 안내',
                                        style: TextStyle(
                                          color: context.textPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '• 요일을 미리 정하지 않고 이번 주(월~일) 중 실천한 날 자유롭게 체크합니다.\n'
                                    '• 목표 횟수($_repeatCount회)를 다 채울 때까지 일주일 내내 실천 목록에 표시되며 알림이 울립니다.\n'
                                    '• 매주 일요일 자정(24:00)에 주간 카운트가 마감되고 새로운 주가 시작됩니다.',
                                    style: TextStyle(
                                      color: context.textSecondary,
                                      fontSize: 11.5,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. 알림 설정 카드
              _buildSectionHeader(
                icon: Icons.notifications_active_rounded,
                title: '알림 설정',
                subtitle: '원하는 시간 또는 간격으로 리마인더를 받으세요',
              ),
              Container(
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _reminderEnabled
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : context.surfaceBorder,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: context.isDarkMode ? 0.15 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _reminderEnabled
                                  ? AppColors.primary.withValues(alpha: 0.15)
                                  : (context.isDarkMode
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.04)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.alarm_rounded,
                              size: 18,
                              color: _reminderEnabled
                                  ? AppColors.primaryLight
                                  : context.textMuted,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '알림 받기',
                                  style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _reminderEnabled
                                      ? (_reminderType == ReminderType.fixed
                                          ? '매일 지정된 시간에 알림'
                                          : '설정한 시간대마다 반복 알림')
                                      : '알림 미사용',
                                  style: TextStyle(
                                    color: _reminderEnabled
                                        ? AppColors.primaryLight
                                        : context.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _reminderEnabled,
                            activeTrackColor: AppColors.primary,
                            activeThumbColor: Colors.white,
                            onChanged: (val) async {
                              if (val) {
                                final isGranted = await NotificationService
                                    .checkSystemNotificationPermission();
                                if (!isGranted && mounted) {
                                  final requested = await NotificationService
                                      .requestSystemNotificationPermission();
                                  if (!requested && mounted) {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Row(
                                          children: [
                                            Icon(
                                                Icons
                                                    .notifications_off_rounded,
                                                color: Colors.white,
                                                size: 18),
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
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    );
                                  }
                                }
                              }
                              setState(() => _reminderEnabled = val);
                            },
                          ),
                        ],
                      ),
                    ),

                    if (_reminderEnabled) ...[
                      Divider(color: context.surfaceBorder, height: 1),
                      // 테스트 알림 발송 와이드 버튼
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: InkWell(
                          onTap: () async {
                            final success = await NotificationService.showTestNotification(
                              title: '⚡ [${_titleController.text.trim().isEmpty ? '습관 알림' : _titleController.text.trim()}] 실천 시간!',
                              body: '체크 한 번, 3초 컷 ⚡️',
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? '⚡ 테스트 알림이 발송되었습니다! (화면 상단바 확인)'
                                        : '⚠️ 알림 권한이 차단되어 있습니다. 알림 설정을 허용해주세요.',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_active_rounded, size: 16, color: AppColors.primaryLight),
                                SizedBox(width: 8),
                                Text(
                                  '알림 테스트 울리기',
                                  style: TextStyle(
                                    color: AppColors.primaryLight,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Divider(color: context.surfaceBorder, height: 1),

                      // 알림 방식 선택 (지정 시간 vs 반복 간격)
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: ReminderType.values.map((type) {
                            final isSelected = _reminderType == type;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _reminderType = type),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 160),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withValues(alpha: 0.16)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: isSelected
                                        ? Border.all(color: AppColors.primary, width: 1.2)
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      type.label,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.primaryLight
                                            : context.textSecondary,
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // 지정 시간 알림 UI
                      if (_reminderType == ReminderType.fixed) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: context.bg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.surfaceBorder),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _reminderTime != null
                                      ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
                                      : '시간을 선택하세요',
                                  style: const TextStyle(
                                    color: AppColors.primaryLight,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _selectFixedTime,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primaryLight),
                                  label: const Text('시간 변경', style: TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // 반복 간격 알림 UI
                      if (_reminderType == ReminderType.interval) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '알림 시간대',
                                    style: TextStyle(
                                      color: context.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: _selectStartTime,
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: context.bg,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: context.surfaceBorder),
                                          ),
                                          child: Text(
                                            _reminderStartTime != null
                                                ? '${_reminderStartTime!.hour.toString().padLeft(2, '0')}:${_reminderStartTime!.minute.toString().padLeft(2, '0')}'
                                                : '09:00',
                                            style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        child: Text('~', style: TextStyle(color: context.textSecondary)),
                                      ),
                                      InkWell(
                                        onTap: _selectEndTime,
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: context.bg,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: context.surfaceBorder),
                                          ),
                                          child: Text(
                                            _reminderEndTime != null
                                                ? '${_reminderEndTime!.hour.toString().padLeft(2, '0')}:${_reminderEndTime!.minute.toString().padLeft(2, '0')}'
                                                : '21:00',
                                            style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                '반복 간격',
                                style: TextStyle(
                                  color: context.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: _suggestedIntervals.map<Widget>((mins) {
                                  final isSelected = _reminderIntervalMinutes == mins;
                                  final label = mins < 60 ? '$mins분마다' : '${mins ~/ 60}시간마다';
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _reminderIntervalMinutes = mins),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 3),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppColors.primary : context.bg,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isSelected ? AppColors.primary : context.surfaceBorder,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            label,
                                            style: TextStyle(
                                              color: isSelected ? Colors.white : context.textSecondary,
                                              fontSize: 11,
                                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 6. 하단 저장 버튼 (프리미엄 와이드 버튼)
              GestureDetector(
                onTap: _saveHabit,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isEditing ? Icons.check_circle_rounded : Icons.bolt_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isEditing ? '변경사항 저장하기' : '3초 습관 시작하기',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.bg,
          border: Border(
            top: BorderSide(color: context.surfaceBorder, width: 0.8),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 모든 메뉴 공통 가로 100% 하단 배너 광고
            const AdBannerSlot(),
            // 하단 내비게이션 바
            NavigationBar(
              selectedIndex: widget.initialTabIndex,
              onDestinationSelected: (index) {
                Navigator.of(context).pop(index);
              },
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              indicatorColor: AppColors.primary.withValues(alpha: 0.2),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.check_circle_outline_rounded),
                  selectedIcon:
                      Icon(Icons.check_circle_rounded, color: AppColors.primary),
                  label: '오늘의 습관',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_rounded),
                  selectedIcon:
                      Icon(Icons.bar_chart_rounded, color: AppColors.primary),
                  label: '통계/기록',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon:
                      Icon(Icons.settings_rounded, color: AppColors.primary),
                  label: '설정',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryLight),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              subtitle,
              style: TextStyle(
                color: context.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
