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

    // 1. 다크/라이트 모드 및 완료 여부에 따른 프리미엄 딥 그라데이션 컬러 (고급 브랜드 카드 톤)
    final List<Color> gradientColors = switch ((isDark, isAllDone)) {
      (true, true) => const [
          Color(0xFF059669),
          Color(0xFF047857),
          Color(0xFF022C22),
        ],
      (true, false) => const [
          Color(0xFF5B21B6),
          Color(0xFF3B0764),
          Color(0xFF1E1B4B),
        ],
      (false, true) => const [
          Color(0xFF10B981),
          Color(0xFF059669),
          Color(0xFF047857),
        ],
      (false, false) => const [
          Color(0xFF7C3AED),
          Color(0xFF6D28D9),
          Color(0xFF4F46E5),
        ],
    };

    // 2. 테두리 컬러
    final Color borderColor = isAllDone
        ? const Color(0xFF6EE7B7).withValues(alpha: isDark ? 0.45 : 0.55)
        : const Color(0xFFC4B5FD).withValues(alpha: isDark ? 0.38 : 0.50);

    // 3. 그림자 글로우 컬러
    final Color shadowColor = isAllDone
        ? AppColors.success.withValues(alpha: isDark ? 0.24 : 0.30)
        : AppColors.primary.withValues(alpha: isDark ? 0.26 : 0.32);

    // 4. 타이틀 및 텍스트 컬러 (딥 그라데이션 위 선명한 화이트 타이포그래피)
    const Color titleColor = Colors.white;
    final Color subTitleColor = isAllDone
        ? const Color(0xFFD1FAE5)
        : const Color(0xFFE0E7FF);

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          children: [
            // 은은한 상단 빛(Orb) 글로우 데코레이션
            Positioned(
              left: -30,
              top: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      (isAllDone ? AppColors.success : AppColors.primaryLight)
                          .withValues(alpha: isDark ? 0.22 : 0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // 배경 우측 상단 워터마크 아이콘 (깊이감과 입체감 부여)
            Positioned(
              right: -12,
              top: -12,
              child: Icon(
                isAllDone
                    ? Icons.check_circle_rounded
                    : (totalCount == 0 ? Icons.add_task_rounded : Icons.bolt_rounded),
                size: 112,
                color: Colors.white.withValues(alpha: 0.08),
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
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.24),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: isAllDone
                                    ? const Color(0xFFA7F3D0)
                                    : const Color(0xFFFDE047),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (isAllDone
                                            ? const Color(0xFFA7F3D0)
                                            : const Color(0xFFFDE047))
                                        .withValues(alpha: 0.7),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                dateString,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 3초 컷 상태 뱃지
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.34),
                          width: 0.9,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAllDone ? Icons.celebration_rounded : Icons.bolt_rounded,
                            size: 14,
                            color: const Color(0xFFFDE047),
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
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.28),
                            width: 1.0,
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
                                          ? const Color(0xFFA7F3D0)
                                          : const Color(0xFFFDE047),
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' / $totalCount',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.78),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '$percent%',
                              style: const TextStyle(
                                color: Colors.white,
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
                        color: Colors.black.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.14),
                          width: 0.8,
                        ),
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
                                      ? const [Color(0xFFA7F3D0), Color(0xFF34D399)]
                                      : const [Color(0xFFFDE047), Color(0xFF38BDF8)],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  if (value > 0.05)
                                    BoxShadow(
                                      color: (isAllDone
                                              ? const Color(0xFF6EE7B7)
                                              : const Color(0xFFFDE047))
                                          .withValues(alpha: 0.45),
                                      blurRadius: 8,
                                      offset: const Offset(0, 1),
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
      ),
    );
  }
}
