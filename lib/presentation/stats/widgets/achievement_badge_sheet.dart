import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HabitBadge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final Color color;

  const HabitBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.color,
  });
}

/// 성취 마일스톤 뱃지 바텀시트 모달
class AchievementBadgeSheet extends StatelessWidget {
  final int maxCurrentStreak;
  final int bestEverStreak;
  final int totalCompletions;

  const AchievementBadgeSheet({
    super.key,
    required this.maxCurrentStreak,
    required this.bestEverStreak,
    required this.totalCompletions,
  });

  static void show(
    BuildContext context, {
    required int maxCurrentStreak,
    required int bestEverStreak,
    required int totalCompletions,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AchievementBadgeSheet(
        maxCurrentStreak: maxCurrentStreak,
        bestEverStreak: bestEverStreak,
        totalCompletions: totalCompletions,
      ),
    );
  }

  List<HabitBadge> _getBadges() {
    return [
      HabitBadge(
        id: 'first_step',
        title: '첫 걸음',
        description: '첫 습관 실천 1회 완료',
        icon: '🚀',
        isUnlocked: totalCompletions >= 1,
        color: const Color(0xFF3B82F6),
      ),
      HabitBadge(
        id: 'streak_3',
        title: '작심삼일 극복',
        description: '연속 3일 실천 달성',
        icon: '🔥',
        isUnlocked: bestEverStreak >= 3,
        color: AppColors.fireOrange,
      ),
      HabitBadge(
        id: 'streak_7',
        title: '습관의 달인',
        description: '연속 7일 실천 달성',
        icon: '👑',
        isUnlocked: bestEverStreak >= 7,
        color: AppColors.fireAmber,
      ),
      HabitBadge(
        id: 'streak_21',
        title: '21일의 기적',
        description: '연속 21일 뇌과학적 습관 정착',
        icon: '💎',
        isUnlocked: bestEverStreak >= 21,
        color: const Color(0xFF06B6D4),
      ),
      HabitBadge(
        id: 'count_30',
        title: '성실한 농부',
        description: '누적 실천 30회 돌파',
        icon: '🌱',
        isUnlocked: totalCompletions >= 30,
        color: AppColors.success,
      ),
      HabitBadge(
        id: 'count_100',
        title: '백전백승',
        description: '누적 실천 100회 돌파',
        icon: '🏆',
        isUnlocked: totalCompletions >= 100,
        color: const Color(0xFF8B5CF6),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final badges = _getBadges();
    final unlockedCount = badges.where((b) => b.isUnlocked).length;

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: context.surfaceBorder, width: 1.2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 드래그 핸들
              Container(
                width: 40,
                height: 4.5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        '🏅 성취 뱃지 컬렉션',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$unlockedCount / ${badges.length} 달성',
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 뱃지 그리드 (2열 3행)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: badges.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.95,
                ),
                itemBuilder: (context, index) {
                  final b = badges[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: b.isUnlocked
                          ? b.color.withValues(alpha: context.isDarkMode ? 0.14 : 0.08)
                          : (context.isDarkMode ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: b.isUnlocked
                            ? b.color.withValues(alpha: 0.4)
                            : context.surfaceBorder,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // 이모지 / 뱃지 원
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: b.isUnlocked
                                ? b.color.withValues(alpha: 0.2)
                                : Colors.grey.withValues(alpha: 0.15),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            b.isUnlocked ? b.icon : '🔒',
                            style: TextStyle(
                              fontSize: b.isUnlocked ? 20 : 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // 텍스트 정보
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: b.isUnlocked ? context.textPrimary : context.textMuted,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                b.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: b.isUnlocked ? context.textSecondary : context.textMuted,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
