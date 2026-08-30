import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/database/habit_dao.dart';
import '../../providers/habit_provider.dart';
import '../../providers/theme_provider.dart';
import '../common/help_guide_dialog.dart';
import 'widgets/grass_heatmap_calendar.dart';
import 'widgets/habit_stat_card.dart';
import 'widgets/overall_streak_banner.dart';

/// 통계 및 월간 깃허브 잔디밭 히트맵 화면
class StatsScreen extends StatefulWidget {
  final HabitDao? habitDao;

  const StatsScreen({super.key, this.habitDao});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  Map<String, int> _heatmapData = {};
  bool _isLoadingHeatmap = false;

  HabitDao get _dao => widget.habitDao ?? HabitDao();

  @override
  void initState() {
    super.initState();
    _loadHeatmap();
  }

  Future<void> _loadHeatmap() async {
    setState(() => _isLoadingHeatmap = true);
    try {
      final data = await _dao.getMonthlyHeatmapLogs(_selectedYear, _selectedMonth);
      if (mounted) {
        setState(() {
          _heatmapData = data;
          _isLoadingHeatmap = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingHeatmap = false);
      }
    }
  }

  void _previousMonth() {
    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
    });
    _loadHeatmap();
  }

  void _nextMonth() {
    setState(() {
      if (_selectedMonth == 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else {
        _selectedMonth++;
      }
    });
    _loadHeatmap();
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final habits = habitProvider.habits;

    int maxCurrentStreak = 0;
    int bestEverStreak = 0;
    int totalCompletions = 0;

    for (final h in habits) {
      if (h.currentStreak > maxCurrentStreak) maxCurrentStreak = h.currentStreak;
      if (h.bestStreak > bestEverStreak) bestEverStreak = h.bestStreak;
      totalCompletions += h.totalCompletedCount;
    }

    return Scaffold(
      backgroundColor: context.bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(66),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: context.isDarkMode
                  ? const [
                      Color(0xFF0F2B5B),
                      Color(0xFF1E3A8A),
                      Color(0xFF1E1B4B),
                    ]
                  : const [
                      Color(0xFF1D4ED8),
                      Color(0xFF2563EB),
                      Color(0xFF4F46E5),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              bottom: BorderSide(
                color: context.isDarkMode
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : const Color(0xFFDDD6FE),
                width: 1.2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: context.isDarkMode
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bar_chart_rounded,
                        color: Colors.white.withValues(alpha: 0.95),
                        size: 20,
                        shadows: [
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '통계 & 기록',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          letterSpacing: -0.5,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // 다크/라이트 모드 토글
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.read<ThemeProvider>().toggleTheme(!context.isDarkMode),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.isDarkMode
                            ? const Color(0xFF1E293B)
                            : Colors.white,
                        border: Border.all(
                          color: context.isDarkMode
                              ? const Color(0xFF3B82F6).withValues(alpha: 0.35)
                              : const Color(0xFFBFDBFE),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(
                              alpha: context.isDarkMode ? 0.25 : 0.12,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        context.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        size: 18,
                        color: context.isDarkMode
                            ? const Color(0xFFFDE047)
                            : const Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 도움말 아이콘
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => HelpGuideDialog.show(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.isDarkMode
                            ? const Color(0xFF1E293B)
                            : Colors.white,
                        border: Border.all(
                          color: context.isDarkMode
                              ? const Color(0xFF3B82F6).withValues(alpha: 0.35)
                              : const Color(0xFFBFDBFE),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(
                              alpha: context.isDarkMode ? 0.25 : 0.12,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.help_outline_rounded,
                        size: 18,
                        color: context.isDarkMode
                            ? Colors.white.withValues(alpha: 0.9)
                            : const Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: context.surface,
          onRefresh: () async {
            await habitProvider.loadHabits();
            await _loadHeatmap();
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 30),
            children: [
              // 1. 상단 종합 스트릭 및 완료 배너
              OverallStreakBanner(
                maxCurrentStreak: maxCurrentStreak,
                bestEverStreak: bestEverStreak,
                totalCompletions: totalCompletions,
              ),

              // 2. 깃허브 잔디밭 스타일 월간 히트맵
              if (_isLoadingHeatmap)
                const SizedBox(
                  height: 220,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                )
              else
                GrassHeatmapCalendar(
                  year: _selectedYear,
                  month: _selectedMonth,
                  heatmapData: _heatmapData,
                  onPreviousMonth: _previousMonth,
                  onNextMonth: _nextMonth,
                ),

              const SizedBox(height: 16),

              // 3. 습관별 상세 통계 목록
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  '습관별 달성률',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              if (habits.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      '등록된 습관이 없습니다.',
                      style: TextStyle(color: context.textMuted),
                    ),
                  ),
                )
              else
                ...habits.map((h) => HabitStatCard(habitStatus: h)),
            ],
          ),
        ),
      ),
    );
  }
}
