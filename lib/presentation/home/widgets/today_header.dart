import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// 상단 헤더: 오늘 날짜 및 오늘 습관 달성률 현황을 컬러풀하고 고급스럽게 표시
class TodayHeader extends StatelessWidget {
  final String dateString;
  final int completedCount;
  final int totalCount;
  final double progressRate;

  const TodayHeader({
    super.key,
    required this.dateString,
    required this.completedCount,
    required this.totalCount,
    required this.progressRate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAllDone = totalCount > 0 && completedCount == totalCount;
    final percent = (progressRate * 100).toInt();

    // 1. 다크/라이트 모드 및 완료 여부에 따른 프리미엄 그라데이션 컬러 설정
    final List<Color> gradientColors = switch ((isDark, isAllDone)) {
      (true, true) => const [
          Color(0xFF065F46), // 딥 에메랄드
          Color(0xFF047857),
          Color(0xFF022C22),
        ],
      (true, false) => const [
          Color(0xFF581C87), // 화려하고 고급스러운 로열 바이올렛
          Color(0xFF3B0764),
          Color(0xFF1E1B4B),
        ],
      (false, true) => const [
          Color(0xFFA7F3D0), // 싱그러운 민트/에메랄드
          Color(0xFFD1FAE5),
          Color(0xFFECFDF5),
        ],
      (false, false) => const [
          Color(0xFFDDD6FE), // 화사하고 세련된 라벤더 바이올렛
          Color(0xFFEDE9FE),
          Color(0xFFF5F3FF),
        ],
    };

    // 2. 테두리 컬러
    final Color borderColor = switch ((isDark, isAllDone)) {
      (true, true) => AppColors.success.withValues(alpha: 0.45),
      (true, false) => AppColors.primaryLight.withValues(alpha: 0.35),
      (false, true) => const Color(0xFF6EE7B7),
      (false, false) => const Color(0xFFC4B5FD),
    };

    // 3. 그림자 글로우 컬러
    final Color shadowColor = switch ((isDark, isAllDone)) {
      (true, true) => AppColors.success.withValues(alpha: 0.20),
      (true, false) => AppColors.primary.withValues(alpha: 0.25),
      (false, true) => AppColors.success.withValues(alpha: 0.12),
      (false, false) => AppColors.primary.withValues(alpha: 0.15),
    };

    // 4. 타이틀 및 텍스트 컬러
    final Color titleColor = isDark
        ? Colors.white
        : (isAllDone ? const Color(0xFF065F46) : const Color(0xFF4C1D95));

    final Color subTitleColor = isDark
        ? (isAllDone ? AppColors.successLight : const Color(0xFFCBD5E1))
        : (isAllDone ? const Color(0xFF047857) : const Color(0xFF6B21A8));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: borderColor, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 배경 우측 상단 워터마크 아이콘 (깊이감과 입체감 부여)
          Positioned(
            right: -12,
            top: -12,
            child: Icon(
              isAllDone
                  ? Icons.check_circle_rounded
                  : (totalCount == 0 ? Icons.add_task_rounded : Icons.bolt_rounded),
              size: 110,
              color: isDark
                  ? (isAllDone
                      ? AppColors.success.withValues(alpha: 0.08)
                      : AppColors.primary.withValues(alpha: 0.08))
                  : (isAllDone
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.10)),
            ),
          ),

          // 카드 본문 콘텐츠
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // [1] 오늘 날짜 & 3초 컷 뱃지
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 날짜 태그
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: isAllDone ? AppColors.success : AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (isAllDone ? AppColors.success : AppColors.primary)
                                      .withValues(alpha: 0.6),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            dateString,
                            style: TextStyle(
                              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3초 컷 상태 뱃지
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isAllDone
                              ? const [Color(0xFF10B981), Color(0xFF059669)]
                              : const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (isAllDone ? AppColors.success : AppColors.primary)
                                .withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAllDone ? Icons.celebration_rounded : Icons.bolt_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isAllDone ? '올클리어!' : '3초 컷 습관',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // [2] 메인 문구 및 진행 수치
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAllDone
                                ? '오늘의 모든 습관 완료! 🎉'
                                : totalCount == 0
                                    ? '새로운 습관을 시작해볼까요?'
                                    : '작은 3초가 습관을 만듭니다',
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            totalCount == 0
                                ? '하단 + 버튼을 눌러 첫 습관을 등록해보세요'
                                : isAllDone
                                    ? '오늘 목표를 100% 멋지게 달성하셨어요!'
                                    : '$completedCount개 완료됨 (${totalCount - completedCount}개 남음)',
                            style: TextStyle(
                              color: subTitleColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 완료 수치 및 퍼센트 칩
                    if (totalCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: borderColor.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$completedCount',
                                    style: TextStyle(
                                      color: isAllDone
                                          ? AppColors.success
                                          : (isDark ? AppColors.accent : AppColors.primaryDark),
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' / $totalCount',
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '$percent%',
                              style: TextStyle(
                                color: isAllDone
                                    ? AppColors.success
                                    : (isDark ? AppColors.primaryLight : AppColors.primary),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),

                // [3] 그라데이션 프로그레스 바
                Stack(
                  children: [
                    // 프로그레스 바 배경 트랙
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.35)
                            : Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    // 채워지는 게이지
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      tween: Tween<double>(begin: 0, end: progressRate),
                      builder: (context, value, _) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final fillWidth = constraints.maxWidth * value;
                            return Container(
                              height: 10,
                              width: fillWidth,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isAllDone
                                      ? const [Color(0xFF34D399), Color(0xFF10B981)]
                                      : const [Color(0xFFA78BFA), Color(0xFF8B5CF6)],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  if (value > 0.05)
                                    BoxShadow(
                                      color: (isAllDone ? AppColors.success : AppColors.primary)
                                          .withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
