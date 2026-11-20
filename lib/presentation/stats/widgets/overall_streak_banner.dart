import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'achievement_badge_sheet.dart';

/// 상단 스트릭 및 총 달성 현황 대형 배너
class OverallStreakBanner extends StatelessWidget {
  final int maxCurrentStreak;
  final int bestEverStreak;
  final int totalCompletions;

  const OverallStreakBanner({
    super.key,
    required this.maxCurrentStreak,
    required this.bestEverStreak,
    required this.totalCompletions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: context.isDarkMode
              ? const [Color(0xFF3B1578), Color(0xFF23194E), Color(0xFF171336)]
              : const [Color(0xFF7C3AED), Color(0xFF5B21B6), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.45),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: context.isDarkMode ? 0.20 : 0.28),
            blurRadius: 22,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          children: [
            // 은은한 상단 빛(Orb) 글로우
            Positioned(
              left: -28,
              top: -36,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // 우측 상단 은은한 트로피 워터마크
            Positioned(
              right: -14,
              top: -12,
              child: Icon(
                Icons.emoji_events_rounded,
                size: 108,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
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
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.fireOrange.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.fireOrange.withValues(alpha: 0.45),
                                  width: 0.9,
                                ),
                              ),
                              child: const Icon(
                                Icons.local_fire_department_rounded,
                                color: AppColors.fireOrange,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Flexible(
                              child: Text(
                                '나의 습관 연속 기록',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 뱃지 보기 버튼
                      GestureDetector(
                        onTap: () => AchievementBadgeSheet.show(
                          context,
                          maxCurrentStreak: maxCurrentStreak,
                          bestEverStreak: bestEverStreak,
                          totalCompletions: totalCompletions,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.fireAmber.withValues(alpha: 0.28),
                                Colors.white.withValues(alpha: 0.14),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.32),
                              width: 0.9,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🏅', style: TextStyle(fontSize: 12)),
                              SizedBox(width: 4),
                              Text(
                                '뱃지 보기',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 1),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 14,
                                color: Colors.white70,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 3개 지표 글래스 패널
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                        width: 0.9,
                      ),
                    ),
                    child: Row(
                      children: [
                        // 현재 최고 연속
                        Expanded(
                          child: _buildStatMetric(
                            label: '현재 연속',
                            value: '$maxCurrentStreak일',
                            color: AppColors.fireOrange,
                            icon: Icons.bolt_rounded,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 38,
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                        // 역대 최장 기록
                        Expanded(
                          child: _buildStatMetric(
                            label: '최고 기록',
                            value: '$bestEverStreak일',
                            color: AppColors.fireAmber,
                            icon: Icons.emoji_events_rounded,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 38,
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                        // 총 달성 횟수
                        Expanded(
                          child: _buildStatMetric(
                            label: '누적 완료',
                            value: '$totalCompletions회',
                            color: AppColors.successLight,
                            icon: Icons.check_circle_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 하단 친절한 요약 설명 캡션
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tips_and_updates_rounded,
                          size: 13.5,
                          color: AppColors.fireAmber.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            totalCompletions == 0
                                ? '오늘의 습관을 완료하고 첫 연속 기록을 시작해보세요!'
                                : '현재 최장 $maxCurrentStreak일째 달리는 중! 총 $totalCompletions회의 실천이 모였어요 ✨',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatMetric({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }
}
