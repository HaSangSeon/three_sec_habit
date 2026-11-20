import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HabitBadge {
  final String id;
  final String title;
  final String description;
  final String progressText;
  final String icon;
  final bool isUnlocked;
  final Color color;

  const HabitBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.progressText,
    required this.icon,
    required this.isUnlocked,
    required this.color,
  });
}

/// 성취 마일스톤 뱃지 바텀시트 모달 (프리미엄 그라데이션 헤더 & 달성률 뷰)
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
      useSafeArea: true,
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
        progressText: totalCompletions >= 1 ? '달성 완료' : '0 / 1회',
        icon: '🚀',
        isUnlocked: totalCompletions >= 1,
        color: const Color(0xFF3B82F6),
      ),
      HabitBadge(
        id: 'streak_3',
        title: '작심삼일 극복',
        description: '연속 3일 실천 달성',
        progressText:
            bestEverStreak >= 3 ? '달성 완료' : '${bestEverStreak.clamp(0, 3)} / 3일',
        icon: '🔥',
        isUnlocked: bestEverStreak >= 3,
        color: AppColors.fireOrange,
      ),
      HabitBadge(
        id: 'streak_7',
        title: '습관의 달인',
        description: '연속 7일 실천 달성',
        progressText:
            bestEverStreak >= 7 ? '달성 완료' : '${bestEverStreak.clamp(0, 7)} / 7일',
        icon: '👑',
        isUnlocked: bestEverStreak >= 7,
        color: AppColors.fireAmber,
      ),
      HabitBadge(
        id: 'streak_21',
        title: '21일의 기적',
        description: '연속 21일 습관 정착',
        progressText: bestEverStreak >= 21
            ? '달성 완료'
            : '${bestEverStreak.clamp(0, 21)} / 21일',
        icon: '💎',
        isUnlocked: bestEverStreak >= 21,
        color: const Color(0xFF06B6D4),
      ),
      HabitBadge(
        id: 'count_30',
        title: '성실한 농부',
        description: '누적 실천 30회 돌파',
        progressText: totalCompletions >= 30
            ? '달성 완료'
            : '${totalCompletions.clamp(0, 30)} / 30회',
        icon: '🌱',
        isUnlocked: totalCompletions >= 30,
        color: AppColors.success,
      ),
      HabitBadge(
        id: 'count_100',
        title: '백전백승',
        description: '누적 실천 100회 돌파',
        progressText: totalCompletions >= 100
            ? '달성 완료'
            : '${totalCompletions.clamp(0, 100)} / 100회',
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
    final progressRatio = unlockedCount / badges.length;
    final isDark = context.isDarkMode;
    const goldAccent = AppColors.fireAmber;

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: goldAccent.withValues(alpha: isDark ? 0.38 : 0.28),
            width: 1.2,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        maintainBottomViewPadding: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. 프리미엄 골드/앰버 그라데이션 헤더
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 10, 16, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      goldAccent.withValues(alpha: isDark ? 0.24 : 0.16),
                      AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
                      context.surface,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
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
                            color: goldAccent.withValues(
                                alpha: isDark ? 0.22 : 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: goldAccent.withValues(alpha: 0.45),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.workspace_premium_rounded,
                                size: 14,
                                color: goldAccent,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '명예의 전당 · $unlockedCount / ${badges.length} 달성',
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFFFCD34D)
                                      : const Color(0xFFD97706),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
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
                              color: context.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '성취 뱃지 컬렉션',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '역대 최고 연속 $bestEverStreak일 · 총 $totalCompletions회 실천 중이에요!',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 12.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progressRatio,
                        minHeight: 7,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.fireAmber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: context.surfaceBorder.withValues(alpha: 0.65),
              ),

              // 2. 뱃지 그리드 (스크롤 지원 & 여유 있는 비율)
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: badges.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.58,
                    ),
                    itemBuilder: (context, index) {
                      final b = badges[index];
                      return Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          gradient: b.isUnlocked
                              ? LinearGradient(
                                  colors: [
                                    b.color.withValues(
                                        alpha: isDark ? 0.22 : 0.12),
                                    b.color.withValues(
                                        alpha: isDark ? 0.08 : 0.03),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: b.isUnlocked
                              ? null
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.03)
                                  : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: b.isUnlocked
                                ? b.color.withValues(alpha: 0.55)
                                : context.surfaceBorder.withValues(alpha: 0.7),
                            width: b.isUnlocked ? 1.3 : 0.9,
                          ),
                          boxShadow: b.isUnlocked
                              ? [
                                  BoxShadow(
                                    color: b.color.withValues(alpha: 0.14),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: b.isUnlocked
                                        ? b.color.withValues(alpha: 0.20)
                                        : Colors.grey.withValues(alpha: 0.14),
                                    boxShadow: b.isUnlocked
                                        ? [
                                            BoxShadow(
                                              color: b.color
                                                  .withValues(alpha: 0.25),
                                              blurRadius: 6,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    b.isUnlocked ? b.icon : '🔒',
                                    style: TextStyle(
                                      fontSize: b.isUnlocked ? 19 : 15,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6.5,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: b.isUnlocked
                                        ? b.color.withValues(alpha: 0.18)
                                        : context.textMuted
                                            .withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Text(
                                    b.progressText,
                                    style: TextStyle(
                                      color: b.isUnlocked
                                          ? b.color
                                          : context.textMuted,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: b.isUnlocked
                                        ? context.textPrimary
                                        : context.textMuted,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 1.5),
                                Text(
                                  b.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: b.isUnlocked
                                        ? context.textSecondary
                                        : context.textMuted
                                            .withValues(alpha: 0.8),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
