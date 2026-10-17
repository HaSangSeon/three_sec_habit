import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_sec_habit/core/constants/app_colors.dart';
import 'package:three_sec_habit/core/constants/app_icons.dart';

/// 습관 이름 및 대표 아이콘 미리보기 카드 (어르신 친화적 대형 폰트 및 1-터치 지우기 버튼)
class HabitTitleCard extends StatefulWidget {
  final TextEditingController titleController;
  final String selectedIconKey;
  final Color currentColor;

  const HabitTitleCard({
    super.key,
    required this.titleController,
    required this.selectedIconKey,
    required this.currentColor,
  });

  @override
  State<HabitTitleCard> createState() => _HabitTitleCardState();
}

class _HabitTitleCardState extends State<HabitTitleCard> {
  @override
  void initState() {
    super.initState();
    widget.titleController.addListener(_onTextChange);
  }

  @override
  void dispose() {
    widget.titleController.removeListener(_onTextChange);
    super.dispose();
  }

  void _onTextChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.titleController.text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasText
              ? widget.currentColor.withValues(alpha: 0.45)
              : context.surfaceBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.currentColor.withValues(
              alpha: context.isDarkMode ? 0.12 : 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 현재 선택된 아이콘 미리보기
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.currentColor.withValues(
                    alpha: context.isDarkMode ? 0.22 : 0.15,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.currentColor.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  AppIcons.getIcon(widget.selectedIconKey),
                  color: widget.currentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // 습관 이름 입력 필드
              Expanded(
                child: TextFormField(
                  controller: widget.titleController,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                  decoration: InputDecoration(
                    hintText: '예: 아침 혈압약 복용, 동네 산책',
                    hintStyle: TextStyle(
                      color: context.textMuted.withValues(alpha: 0.7),
                      fontSize: 15,
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

              // 어르신을 위한 1-터치 내용 지우기 버튼
              if (hasText)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      try {
                        HapticFeedback.selectionClick();
                      } catch (_) {}
                      widget.titleController.clear();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: context.isDarkMode
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: context.textMuted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 2, top: 4, bottom: 4),
            child: Text(
              '매일 실천하기 쉬운 짧고 뚜렷한 이름을 적어보세요.',
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
