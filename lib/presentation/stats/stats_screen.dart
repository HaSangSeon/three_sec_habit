import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/database/habit_dao.dart';
import '../../core/utils/date_util.dart';
import '../../providers/habit_provider.dart';
import '../../providers/theme_provider.dart';
import '../common/help_guide_dialog.dart';
import 'widgets/day_of_week_chart.dart';
import 'widgets/grass_heatmap_calendar.dart';
import 'widgets/habit_stat_card.dart';
import 'widgets/monthly_summary_card.dart';
import 'widgets/overall_streak_banner.dart';

/// 통계 및 월간 깃허브 잔디밭 히트맵 화면
class StatsScreen extends StatefulWidget {
  final HabitDao? habitDao;

  const StatsScreen({super.key, this.habitDao});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with AutomaticKeepAliveClientMixin {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  Map<String, int> _heatmapData = {};

  // 선택된 날짜 및 해당 날짜의 실천 완료 습관 목록
  String _selectedDate = DateUtil.today();
  List<Map<String, dynamic>> _completedHabitsForDate = [];
  bool _isLoadingDateDetails = false;

  // 요일별 실천 통계 (1:월 ~ 7:일)
  Map<int, int> _weekdayStats = {};

  // 월간 요약 리포트 데이터
  Map<String, dynamic> _monthlyOverview = {};

  HabitDao get _dao => widget.habitDao ?? HabitDao();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadAllStats();
    _loadDateDetails(_selectedDate);
  }

  Future<void> _loadAllStats() async {
    await Future.wait([
      _loadHeatmap(),
      _loadWeekdayStats(),
      _loadMonthlyOverview(),
    ]);
  }

  Future<void> _loadHeatmap() async {
    try {
      final data = await _dao.getMonthlyHeatmapLogs(_selectedYear, _selectedMonth);
      if (mounted) {
        setState(() {
          _heatmapData = data;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadWeekdayStats() async {
    try {
      final stats = await _dao.getDayOfWeekStats();
      if (mounted) {
        setState(() {
          _weekdayStats = stats;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadMonthlyOverview() async {
    try {
      final overview = await _dao.getMonthlyOverviewStats(_selectedYear, _selectedMonth);
      if (mounted) {
        setState(() {
          _monthlyOverview = overview;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadDateDetails(String dateStr) async {
    setState(() {
      _selectedDate = dateStr;
      _isLoadingDateDetails = true;
    });
    try {
      final list = await _dao.getCompletedHabitsForDate(dateStr);
      if (mounted) {
        setState(() {
          _completedHabitsForDate = list;
          _isLoadingDateDetails = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingDateDetails = false);
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
    _loadMonthlyOverview();
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
    _loadMonthlyOverview();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
            await _loadAllStats();
            await _loadDateDetails(_selectedDate);
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              // 1. 상단 종합 스트릭 및 완료 배너 (뱃지 보기 버튼 & 설명 팁 포함)
              OverallStreakBanner(
                maxCurrentStreak: maxCurrentStreak,
                bestEverStreak: bestEverStreak,
                totalCompletions: totalCompletions,
              ),

              // 2. 이번 달 실천 요약 리포트 (총 실천수 & 이달의 성실왕)
              MonthlySummaryCard(
                year: _selectedYear,
                month: _selectedMonth,
                totalMonthCompletions: (_monthlyOverview['totalCompletions'] as int?) ?? 0,
                topHabit: _monthlyOverview['topHabit'] as Map<String, dynamic>?,
              ),

              // 3. 깃허브 잔디밭 스타일 월간 히트맵 (달력 영역 내부 하단에 선택 날짜 완료 텍스트 요약 포함)
              GrassHeatmapCalendar(
                year: _selectedYear,
                month: _selectedMonth,
                heatmapData: _heatmapData,
                selectedDate: _selectedDate,
                completedHabits: _completedHabitsForDate,
                isLoadingHabits: _isLoadingDateDetails,
                onDateSelected: _loadDateDetails,
                onPreviousMonth: _previousMonth,
                onNextMonth: _nextMonth,
              ),

              // 4. 요일별 실천 패턴 미니 막대 차트
              DayOfWeekChart(weekdayStats: _weekdayStats),

              const SizedBox(height: 12),

              // 5. 습관별 상세 통계 목록 헤더
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.insights_rounded,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '습관별 달성률',
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    if (habits.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: context.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: context.surfaceBorder,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '총 ${habits.length}개',
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
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
