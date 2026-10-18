import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_sec_habit/core/constants/app_colors.dart';
import 'package:three_sec_habit/core/constants/app_icons.dart';

/// 아이콘 및 테마 색상 선택 카드
/// - 40여 종의 다양한 아이콘을 컴팩트한 고정 높이 + 상하 페이드 그라데이션으로 위아래 스크롤 지원
/// - 화면 공간을 과도하게 차지하지 않고 부드럽고 고급스러운 조작감 제공
class HabitIconColorCard extends StatefulWidget {
  final String selectedIconKey;
  final int selectedColorValue;
  final ValueChanged<String> onIconSelected;
  final ValueChanged<int> onColorSelected;

  const HabitIconColorCard({
    super.key,
    required this.selectedIconKey,
    required this.selectedColorValue,
    required this.onIconSelected,
    required this.onColorSelected,
  });

  @override
  State<HabitIconColorCard> createState() => _HabitIconColorCardState();
}

class _HabitIconColorCardState extends State<HabitIconColorCard> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // 선택된 아이콘이 3번째 줄 이상에 있을 경우 해당 위치로 자동 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final idx = AppIcons.icons.indexWhere((i) => i.key == widget.selectedIconKey);
      if (idx > 11 && _scrollController.hasClients) {
        final row = idx ~/ 6;
        final targetOffset = (row * 52.0).clamp(0.0, _scrollController.position.maxScrollExtent);
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = Color(widget.selectedColorValue);

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.surfaceBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: context.isDarkMode ? 0.15 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 아이콘 헤더 및 위아래 드래그 안내
          Text(
            '아이콘 선택',
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          // 상하 그라데이션 페이드 효과가 적용된 스크롤 가능 아이콘 그리드
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black,
                  Colors.black,
                  Colors.transparent,
                ],
                stops: [0.0, 0.08, 0.92, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: SizedBox(
              height: 146,
              child: GridView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: AppIcons.icons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final item = AppIcons.icons[index];
                  final isSelected = widget.selectedIconKey == item.key;
                  return GestureDetector(
                    onTap: () {
                      try {
                        HapticFeedback.selectionClick();
                      } catch (_) {}
                      widget.onIconSelected(item.key);
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
                          color: isSelected ? currentColor : context.textSecondary,
                          size: 22,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),
          Divider(color: context.surfaceBorder, height: 1),
          const SizedBox(height: 14),

          // 포인트 색상 헤더 및 가로 드래그 안내
          Text(
            '포인트 색상',
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          // 좌우 깊고 진한 페이드 그라데이션 효과가 적용된 포인트 색상 팔레트
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  Color(0x1A000000),
                  Color(0x8A000000),
                  Colors.black,
                  Colors.black,
                  Color(0x8A000000),
                  Color(0x1A000000),
                  Colors.transparent,
                ],
                stops: [0.0, 0.03, 0.07, 0.12, 0.88, 0.93, 0.97, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              child: Row(
                children: AppColors.habitColorPalette.map((c) {
                  final isSelected = widget.selectedColorValue == c.toARGB32();
                  return GestureDetector(
                    onTap: () {
                      try {
                        HapticFeedback.selectionClick();
                      } catch (_) {}
                      widget.onColorSelected(c.toARGB32());
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
                              ? (context.isDarkMode
                                  ? Colors.white
                                  : Colors.black87)
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
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
