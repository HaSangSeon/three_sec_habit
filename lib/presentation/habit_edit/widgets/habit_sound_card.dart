import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_sec_habit/core/constants/app_colors.dart';
import 'package:three_sec_habit/core/constants/app_sounds.dart';
import 'package:three_sec_habit/core/services/notification_service.dart';

/// 습관 알림 사운드 선택 & 미리듣기 카드 (아이콘 및 색상 카드 바로 아래 배치)
class HabitSoundCard extends StatelessWidget {
  final String selectedSoundKey;
  final bool isAutoSelected;
  final Color accentColor;
  final ValueChanged<String> onSoundSelected;

  const HabitSoundCard({
    super.key,
    required this.selectedSoundKey,
    required this.isAutoSelected,
    required this.accentColor,
    required this.onSoundSelected,
  });

  @override
  Widget build(BuildContext context) {
    final soundInfo = AppSounds.getSound(selectedSoundKey);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.surfaceBorder.withValues(alpha: 0.7),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 좌측 사운드 아이콘 박스
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                soundInfo.emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 사운드 명칭 및 대사
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _showSoundPickerSheet(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          soundInfo.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isAutoSelected
                                ? accentColor.withValues(alpha: 0.14)
                                : context.textMuted.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isAutoSelected ? '자동 맞춤' : '직접 선택',
                            style: TextStyle(
                              color: isAutoSelected ? accentColor : context.textSecondary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      soundInfo.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // 미리듣기 버튼
          Material(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                try {
                  HapticFeedback.lightImpact();
                } catch (_) {}
                NotificationService.playPreviewSound(selectedSoundKey);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Icon(
                  Icons.volume_up_rounded,
                  color: accentColor,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // 변경 버튼
          Material(
            color: context.isDarkMode
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _showSoundPickerSheet(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Text(
                  '변경',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSoundPickerSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = ctx.isDarkMode;
        return Container(
          decoration: BoxDecoration(
            color: ctx.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
                width: 1.2,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            maintainBottomViewPadding: true,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.78,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. 프리미엄 그라데이션 헤더 (핸들 + 뱃지 + 우측 닫기 버튼 + 타이틀)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 10, 16, 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor.withValues(alpha: isDark ? 0.28 : 0.16),
                          accentColor.withValues(alpha: isDark ? 0.08 : 0.05),
                          ctx.surface,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.25)
                                  : Colors.black.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4.5,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: isDark ? 0.24 : 0.14),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.record_voice_over_rounded,
                                    size: 13,
                                    color: accentColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '말하는 스마트 음성 알림',
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                NotificationService.stopPreviewSound();
                                Navigator.of(ctx).pop();
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.10)
                                      : Colors.black.withValues(alpha: 0.06),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: ctx.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '알림 사운드 선택',
                          style: TextStyle(
                            color: ctx.textPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '원하는 소리를 미리 들어보고 선택해 보세요.',
                          style: TextStyle(
                            color: ctx.textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: ctx.surfaceBorder.withValues(alpha: 0.7),
                  ),

                  // 2. 카드형 사운드 리스트
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      itemCount: AppSounds.sounds.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (_, idx) {
                        final item = AppSounds.sounds[idx];
                        final isSelected = item.key == selectedSoundKey;
                        return Material(
                          color: isSelected
                              ? accentColor.withValues(alpha: isDark ? 0.16 : 0.08)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.03)
                                  : Colors.black.withValues(alpha: 0.02)),
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              try {
                                HapticFeedback.selectionClick();
                              } catch (_) {}
                              NotificationService.playPreviewSound(item.key);
                              onSoundSelected(item.key);
                              Navigator.of(ctx).pop();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 11,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? accentColor.withValues(alpha: 0.65)
                                      : ctx.surfaceBorder.withValues(alpha: 0.6),
                                  width: isSelected ? 1.4 : 0.8,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? accentColor.withValues(alpha: 0.20)
                                          : ctx.textMuted.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        item.emoji,
                                        style: const TextStyle(fontSize: 21),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                item.label,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? accentColor
                                                      : ctx.textPrimary,
                                                  fontSize: 15,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w800
                                                      : FontWeight.w700,
                                                  letterSpacing: -0.2,
                                                ),
                                              ),
                                            ),
                                            if (isSelected) ...[
                                              const SizedBox(width: 6),
                                              Icon(
                                                Icons.check_circle_rounded,
                                                color: accentColor,
                                                size: 17,
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          item.description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: ctx.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Material(
                                    color: accentColor.withValues(alpha: 0.14),
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      onTap: () {
                                        try {
                                          HapticFeedback.lightImpact();
                                        } catch (_) {}
                                        NotificationService.playPreviewSound(
                                            item.key);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Icon(
                                          Icons.play_arrow_rounded,
                                          color: accentColor,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
