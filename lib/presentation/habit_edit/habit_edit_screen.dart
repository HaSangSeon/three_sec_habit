import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/utils/date_util.dart';
import '../../models/habit.dart';
import '../../providers/habit_provider.dart';

/// 습관 추가 및 편집 화면 (단순 체크형 & 목표 횟수형, 고정 알림 & 반복 간격 알림 지원)
class HabitEditScreen extends StatefulWidget {
  final Habit? habit; // null이면 신규 추가, 있으면 수정 모드

  const HabitEditScreen({super.key, this.habit});

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

  static const List<String> _suggestedUnits = ['잔', '회', '번', '세트', '분', 'km'];
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
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
        _reminderEnabled = true;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderStartTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() => _reminderStartTime = picked);
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderEndTime ?? const TimeOfDay(hour: 21, minute: 0),
    );
    if (picked != null) {
      setState(() => _reminderEndTime = picked);
    }
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.surface,
        title: Text(
          '습관 삭제',
          style: TextStyle(color: ctx.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '이 습관과 관련된 모든 기록이 삭제됩니다.\n정말 삭제하시겠습니까?',
          style: TextStyle(color: ctx.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('취소', style: TextStyle(color: ctx.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('삭제', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
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
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        title: Text(
          _isEditing ? '습관 편집' : '새 습관 만들기',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFEF4444)),
              tooltip: '습관 삭제',
              onPressed: _deleteHabit,
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // 1. 습관 형태 선택 (단순 체크형 vs 목표 횟수형)
              _buildSectionTitle('습관 기록 방식'),
              Container(
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.surfaceBorder),
                ),
                child: Row(
                  children: HabitType.values.map((type) {
                    final isSelected = _habitType == type;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _habitType = type;
                            if (type == HabitType.count && _targetCount <= 1) {
                              _targetCount = 8;
                              _unit = '잔';
                              _unitController.text = '잔';
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.18)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                            border: isSelected
                                ? Border.all(
                                    color: AppColors.primary, width: 1.5)
                                : null,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  type == HabitType.check
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.water_drop_outlined,
                                  size: 18,
                                  color: isSelected
                                      ? AppColors.primary
                                      : context.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  type == HabitType.check
                                      ? '단순 체크형 (1회)'
                                      : '목표 횟수형 (하루 N회)',
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primary
                                        : context.textSecondary,
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // 2. 습관 이름 입력
              _buildSectionTitle('습관 이름'),
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: context.textPrimary, fontSize: 16),
                decoration: InputDecoration(
                  hintText: _habitType == HabitType.count
                      ? '예: 물 마시기, 스쿼트, 계단 오르기'
                      : '예: 아침 10분 독서, 영양제 복용, 러닝',
                  hintStyle: TextStyle(color: context.textMuted),
                  filled: true,
                  fillColor: context.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: context.surfaceBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: context.surfaceBorder),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    borderSide:
                        BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return '습관 이름을 입력해주세요.';
                  }
                  return null;
                },
              ),

              // 3. 목표 횟수 및 단위 설정 (카운트형일 때만 표시)
              if (_habitType == HabitType.count) ...[
                const SizedBox(height: 20),
                _buildSectionTitle('하루 목표 횟수 및 단위'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.surfaceBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '하루 목표',
                            style: TextStyle(
                              color: context.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: AppColors.primary),
                                onPressed: _targetCount > 2
                                    ? () => setState(() => _targetCount--)
                                    : null,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$_targetCount',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline,
                                    color: AppColors.primary),
                                onPressed: _targetCount < 100
                                    ? () => setState(() => _targetCount++)
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: context.surfaceBorder, height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            '단위 선택',
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
                                  final isSelected =
                                      _unitController.text == u;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _unit = u;
                                        _unitController.text = u;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
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
              const SizedBox(height: 20),

              // 4. 아이콘 선택
              _buildSectionTitle('아이콘 선택'),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.surfaceBorder),
                ),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: AppIcons.icons.map((item) {
                    final isSelected = _selectedIconKey == item.key;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIconKey = item.key),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(_selectedColorValue)
                                  .withValues(alpha: 0.3)
                              : context.bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Color(_selectedColorValue)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          item.icon,
                          color: isSelected
                              ? Color(_selectedColorValue)
                              : context.textSecondary,
                          size: 22,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // 5. 포인트 색상 선택
              _buildSectionTitle('포인트 색상'),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: AppColors.habitColorPalette.map((c) {
                    final isSelected = _selectedColorValue == c.toARGB32();
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedColorValue = c.toARGB32()),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? (context.isDarkMode
                                    ? Colors.white
                                    : Colors.black87)
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // 6. 반복 주기 설정
              _buildSectionTitle('반복 주기'),
              Container(
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.surfaceBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      children: RepeatType.values.map((type) {
                        final isSelected = _repeatType == type;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _repeatType = type),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(15),
                                border: isSelected
                                    ? Border.all(
                                        color: AppColors.primary, width: 1.2)
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  type.label,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primary
                                        : context.textSecondary,
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (_repeatType == RepeatType.weeklyDays) ...[
                      Divider(color: context.surfaceBorder, height: 1),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (i) {
                            final day = i + 1;
                            final isSelected = _repeatDays.contains(day);
                            const dayLabels = [
                              '',
                              '월',
                              '화',
                              '수',
                              '목',
                              '금',
                              '토',
                              '일'
                            ];
                            return GestureDetector(
                              onTap: () {
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
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : context.bg,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : context.surfaceBorder,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    dayLabels[day],
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : context.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
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
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline,
                                      color: AppColors.primary),
                                  onPressed: _repeatCount > 1
                                      ? () => setState(() => _repeatCount--)
                                      : null,
                                ),
                                Text(
                                  '주 $_repeatCount회',
                                  style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline,
                                      color: AppColors.primary),
                                  onPressed: _repeatCount < 7
                                      ? () => setState(() => _repeatCount++)
                                      : null,
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
              const SizedBox(height: 20),

              // 7. 알림 설정 (지정 시각 vs 반복 간격 지원)
              _buildSectionTitle('알림 설정'),
              Container(
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.surfaceBorder),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.notifications_active_outlined,
                                  color: AppColors.primary, size: 22),
                              const SizedBox(width: 12),
                              Text(
                                '알림 받기',
                                style: TextStyle(
                                  color: context.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _reminderEnabled,
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() {
                                _reminderEnabled = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_reminderEnabled) ...[
                      Divider(color: context.surfaceBorder, height: 1),
                      // 알림 방식 선택 (지정 시간 vs 반복 간격)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: ReminderType.values.map((type) {
                            final isSelected = _reminderType == type;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _reminderType = type),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                            .withValues(alpha: 0.15)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: isSelected
                                        ? Border.all(
                                            color: AppColors.primary,
                                            width: 1.2)
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      type.label,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.primary
                                            : context.textSecondary,
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
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
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _reminderTime != null
                                    ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
                                    : '시간을 선택하세요',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _selectFixedTime,
                                icon: const Icon(Icons.access_time_rounded,
                                    size: 18, color: AppColors.primary),
                                label: const Text('시간 변경',
                                    style: TextStyle(color: AppColors.primary)),
                              ),
                            ],
                          ),
                        ),
                      ],
                      // 반복 간격 알림 UI
                      if (_reminderType == ReminderType.interval) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: context.bg,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: context.surfaceBorder),
                                          ),
                                          child: Text(
                                            _reminderStartTime != null
                                                ? '${_reminderStartTime!.hour.toString().padLeft(2, '0')}:${_reminderStartTime!.minute.toString().padLeft(2, '0')}'
                                                : '09:00',
                                            style: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6),
                                        child: Text('~',
                                            style: TextStyle(
                                                color: context.textSecondary)),
                                      ),
                                      InkWell(
                                        onTap: _selectEndTime,
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: context.bg,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: context.surfaceBorder),
                                          ),
                                          child: Text(
                                            _reminderEndTime != null
                                                ? '${_reminderEndTime!.hour.toString().padLeft(2, '0')}:${_reminderEndTime!.minute.toString().padLeft(2, '0')}'
                                                : '21:00',
                                            style: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
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
                                children: _suggestedIntervals.map((mins) {
                                  final isSelected =
                                      _reminderIntervalMinutes == mins;
                                  final label = mins < 60
                                      ? '$mins분마다'
                                      : '${mins ~/ 60}시간마다';
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(
                                          () => _reminderIntervalMinutes = mins),
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(right: 6),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary
                                              : context.bg,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primary
                                                : context.surfaceBorder,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            label,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : context.textSecondary,
                                              fontSize: 11,
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
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
              const SizedBox(height: 36),

              // 8. 하단 저장 버튼
              ElevatedButton(
                onPressed: _saveHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  _isEditing ? '변경사항 저장하기' : '습관 시작하기',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: context.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
