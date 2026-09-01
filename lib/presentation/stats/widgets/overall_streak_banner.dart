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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: context.isDarkMode
              ? const [Color(0xFF2E1065), Color(0xFF1E1B4B)]
              : const [Color(0xFF6D28D9), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: context.isDarkMode ? 0.15 : 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.fireOrange,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '나의 습관 연속 기록',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              // 뱃지 보기 버튼
              GestureDetector(
                onTap: () => AchievementBadgeSheet.show(
                  context,
                  maxCurrentStreak: maxCurrentStreak,
                  bestEverStreak: bestEverStreak,
                  totalCompletions: totalCompletions,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                      width: 0.8,
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
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 현재 최고 연속
              _buildStatMetric(
                label: '현재 연속',
                value: '$maxCurrentStreak일',
                color: AppColors.fireOrange,
                icon: Icons.bolt_rounded,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.18),
              ),
              // 역대 최장 기록
              _buildStatMetric(
                label: '최고 기록',
                value: '$bestEverStreak일',
                color: AppColors.fireAmber,
                icon: Icons.emoji_events_rounded,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.18),
              ),
              // 총 달성 횟수
              _buildStatMetric(
                label: '누적 완료',
                value: '$totalCompletions회',
                color: AppColors.successLight,
                icon: Icons.check_circle_rounded,
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 하단 친절한 요약 설명 캡션
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tips_and_updates_rounded,
                  size: 13,
                  color: Colors.white.withValues(alpha: 0.75),
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
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
        Row(
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
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
