import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/utils/date_util.dart';
import '../../models/habit.dart';
import '../../providers/habit_provider.dart';

/// 습관 추가 및 편집 화면
class HabitEditScreen extends StatefulWidget {
  final Habit? habit; // null이면 신규 추가, 있으면 수정 모드

  const HabitEditScreen({super.key, this.habit});

  @override
  State<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends State<HabitEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;

  late String _selectedIconKey;
  late int _selectedColorValue;
  late RepeatType _repeatType;
  late List<int> _repeatDays;
  late int _repeatCount;
  late bool _reminderEnabled;
  TimeOfDay? _reminderTime;

  bool get _isEditing => widget.habit != null;

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _titleController = TextEditingController(text: h?.title ?? '');
    _selectedIconKey = h?.iconName ?? 'water_drop';
    _selectedColorValue = h?.colorValue ?? 0xFF8B5CF6;
    _repeatType = h?.repeatType ?? RepeatType.daily;
    _repeatDays = h?.repeatDays != null ? List<int>.from(h!.repeatDays) : [1, 2, 3, 4, 5, 6, 7];
    _repeatCount = h?.repeatCount ?? 3;
    _reminderEnabled = h?.reminderEnabled ?? false;

    if (h?.reminderTime != null && h!.reminderTime!.contains(':')) {
      final parts = h.reminderTime!.split(':');
      _reminderTime = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 8,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    } else {
      _reminderTime = const TimeOfDay(hour: 8, minute: 0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectReminderTime() async {
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

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final reminderTimeStr = _reminderTime != null
        ? DateUtil.formatTime(_reminderTime!.hour, _reminderTime!.minute)
        : null;

    final habitProvider = context.read<HabitProvider>();

    if (_isEditing) {
      final updated = widget.habit!.copyWith(
        title: title,
        iconName: _selectedIconKey,
        colorValue: _selectedColorValue,
        repeatType: _repeatType,
        repeatDays: _repeatDays,
        repeatCount: _repeatCount,
        reminderEnabled: _reminderEnabled,
        reminderTime: reminderTimeStr,
      );
      await habitProvider.updateHabit(updated);
    } else {
      final newHabit = Habit(
        title: title,
        iconName: _selectedIconKey,
        colorValue: _selectedColorValue,
        repeatType: _repeatType,
        repeatDays: _repeatDays,
        repeatCount: _repeatCount,
        reminderEnabled: _reminderEnabled,
        reminderTime: reminderTimeStr,
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
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
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
              // 1. 습관 이름 입력
              Text(
                '습관 이름',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: context.textPrimary, fontSize: 16),
                decoration: InputDecoration(
                  hintText: '예: 아침 물 2잔, 10분 독서, 러닝',
                  hintStyle: TextStyle(color: context.textMuted),
                  filled: true,
                  fillColor: context.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: context.surfaceBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: context.surfaceBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return '습관 이름을 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 2. 아이콘 선택
              Text(
                '아이콘 선택',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
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
                      onTap: () {
                        setState(() {
                          _selectedIconKey = item.key;
                        });
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(_selectedColorValue).withValues(alpha: 0.3)
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
              const SizedBox(height: 24),

              // 3. 대표 색상 선택
              Text(
                '포인트 색상',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 14,
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
                        setState(() {
                          _selectedColorValue = c.toARGB32();
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? (context.isDarkMode ? Colors.white : Colors.black87)
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // 4. 반복 주기 설정
              Text(
                '반복 주기',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.surfaceBorder),
                ),
                child: Column(
                  children: [
                    // 주기 탭 (매일 / 특정 요일 / 주 N회)
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
                                    ? Border.all(color: AppColors.primary, width: 1.2)
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

                    // 특정 요일 선택 칩 (weeklyDays 일 때)
                    if (_repeatType == RepeatType.weeklyDays) ...[
                      Divider(color: context.surfaceBorder, height: 1),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (i) {
                            final day = i + 1; // 1(월) ~ 7(일)
                            final isSelected = _repeatDays.contains(day);
                            const dayLabels = ['', '월', '화', '수', '목', '금', '토', '일'];
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

                    // 주 N회 카운트 선택기 (weeklyCount 일 때)
                    if (_repeatType == RepeatType.weeklyCount) ...[
                      Divider(color: context.surfaceBorder, height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
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
                                  icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
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
              const SizedBox(height: 24),

              // 5. 알림 시간 설정
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.surfaceBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 22),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '알림 설정',
                              style: TextStyle(
                                color: context.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_reminderEnabled && _reminderTime != null)
                              Text(
                                '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')} 알림',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (_reminderEnabled)
                          TextButton(
                            onPressed: _selectReminderTime,
                            child: const Text('시간 변경', style: TextStyle(color: AppColors.primary)),
                          ),
                        Switch(
                          value: _reminderEnabled,
                          activeThumbColor: Colors.white,
                          activeTrackColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() {
                              _reminderEnabled = val;
                              if (val && _reminderTime == null) {
                                _reminderTime = const TimeOfDay(hour: 8, minute: 0);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // 6. 하단 저장 버튼
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saveHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isEditing ? '습관 수정하기' : '습관 만들기',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
