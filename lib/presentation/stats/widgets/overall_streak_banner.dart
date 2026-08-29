import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

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
