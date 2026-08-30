import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_util.dart';
import '../../providers/habit_provider.dart';
import '../../providers/theme_provider.dart';
import '../common/help_guide_dialog.dart';
import '../habit_edit/habit_edit_screen.dart';
import '../settings/settings_screen.dart';
import '../stats/stats_screen.dart';
import 'widgets/ad_banner_slot.dart';
import 'widgets/empty_habit_view.dart';
import 'widgets/habit_card_item.dart';
import 'widgets/today_header.dart';

/// 3초 습관 메인 홈 화면 (오늘의 체크리스트 / 통계 / 설정 탭)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 오늘 습관 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().loadHabits();
    });
  }

  void _onAddHabitPressed() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const HabitEditScreen(),
      ),
    );
    if (result == true && mounted) {
      context.read<HabitProvider>().loadHabits();
    }
  }

  void _onEditHabit(dynamic habit) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => HabitEditScreen(habit: habit),
      ),
    );
    if (result == true && mounted) {
      context.read<HabitProvider>().loadHabits();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: switch (_currentTabIndex) {
        0 => _buildTodayChecklistTab(),
        1 => const StatsScreen(),
        2 => const SettingsScreen(),
        _ => _buildTodayChecklistTab(),
      },
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.bg,
          border: Border(
            top: BorderSide(color: context.surfaceBorder, width: 0.8),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 모든 메뉴(오늘의 습관, 통계, 설정) 공통 가로 100% 하단 배너 광고
            const AdBannerSlot(),
            // 하단 내비게이션 바
            NavigationBar(
              selectedIndex: _currentTabIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentTabIndex = index;
                });
              },
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              indicatorColor: AppColors.primary.withValues(alpha: 0.2),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.check_circle_outline_rounded),
                  selectedIcon:
                      Icon(Icons.check_circle_rounded, color: AppColors.primary),
                  label: '오늘의 습관',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_rounded),
                  selectedIcon:
                      Icon(Icons.bar_chart_rounded, color: AppColors.primary),
                  label: '통계/기록',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon:
                      Icon(Icons.settings_rounded, color: AppColors.primary),
                  label: '설정',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 탭 1: 오늘의 습관 체크리스트
  Widget _buildTodayChecklistTab() {
    final habitProvider = context.watch<HabitProvider>();
    final selectedDate = habitProvider.selectedDate;
    final todayStr = DateUtil.formatForDisplay(selectedDate);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: context.isDarkMode
                  ? const [
                      Color(0xFF2E0D5E),
                      Color(0xFF4C1D95),
                      Color(0xFF3730A3),
                    ]
                  : const [
                      Color(0xFF7C3AED),
                      Color(0xFF6D28D9),
                      Color(0xFF5B21B6),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              bottom: BorderSide(
                color: context.isDarkMode
                    ? AppColors.primaryLight.withValues(alpha: 0.4)
                    : const Color(0xFFC4B5FD),
                width: 1.4,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: context.isDarkMode
                    ? const Color(0xFF581C87).withValues(alpha: 0.35)
                    : const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                blurRadius: 18,
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
                  // 앱 타이틀 — 깔끔한 타이포그래피 스타일
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bolt_rounded,
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
                        '3초 습관',
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
                            ? const Color(0xFF2E1065)
                            : Colors.white,
                        border: Border.all(
                          color: context.isDarkMode
                              ? AppColors.primary.withValues(alpha: 0.35)
                              : const Color(0xFFDDD6FE),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(
                              alpha: context.isDarkMode ? 0.2 : 0.1,
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
                            : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 캘린더 아이콘 (날짜 선택 팝업 연결)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: habitProvider.selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        habitProvider.setSelectedDate(picked);
                      }
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.isDarkMode
                            ? const Color(0xFF2E1065)
                            : Colors.white,
                        border: Border.all(
                          color: context.isDarkMode
                              ? AppColors.primary.withValues(alpha: 0.35)
                              : const Color(0xFFDDD6FE),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(
                              alpha: context.isDarkMode ? 0.2 : 0.1,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        size: 17,
                        color: context.isDarkMode
                            ? AppColors.accent
                            : AppColors.primary,
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
                            ? const Color(0xFF2E1065)
                            : Colors.white,
                        border: Border.all(
                          color: context.isDarkMode
                              ? AppColors.primary.withValues(alpha: 0.35)
                              : const Color(0xFFDDD6FE),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(
                              alpha: context.isDarkMode ? 0.2 : 0.1,
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
                            : AppColors.primary,
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
        child: Column(
          children: [
            // 1. 상단 오늘의 달성 현황 헤더
            TodayHeader(
              dateString: todayStr,
              completedCount: habitProvider.completedCount,
              totalCount: habitProvider.totalCount,
              progressRate: habitProvider.progressRate,
            ),

            // 2. 오늘의 습관 체크리스트 목록
            Expanded(
              child: habitProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : habitProvider.habits.isEmpty
                      ? EmptyHabitView(onAddHabit: _onAddHabitPressed)
                      : RefreshIndicator(
                          color: AppColors.primary,
                          backgroundColor: context.surface,
                          onRefresh: () => habitProvider.loadHabits(),
                          child: ListView(
                            padding: const EdgeInsets.only(bottom: 24),
                            children: [
                              // 1) 오늘 실천할 습관 목록
                              if (habitProvider.todayHabits.isNotEmpty) ...[
                                ...habitProvider.todayHabits.map(
                                  (habitStatus) => HabitCardItem(
                                    habitStatus: habitStatus,
                                    onToggle: () {
                                      if (habitStatus.habit.id != null) {
                                        habitProvider
                                            .toggleHabit(habitStatus.habit.id!);
                                      }
                                    },
                                    onIncrement: () {
                                      if (habitStatus.habit.id != null) {
                                        habitProvider.incrementHabitCount(
                                            habitStatus.habit.id!);
                                      }
                                    },
                                    onDecrement: () {
                                      if (habitStatus.habit.id != null) {
                                        habitProvider.decrementHabitCount(
                                            habitStatus.habit.id!);
                                      }
                                    },
                                    onTapDetail: () {
                                      _onEditHabit(habitStatus.habit);
                                    },
                                  ),
                                ),
                              ] else ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 24),
                                  child: Center(
                                    child: Text(
                                      '오늘 예정된 습관이 모두 쉬는 날입니다! 🏖️',
                                      style: TextStyle(
                                        color: context.textMuted,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],

                              // 2) 오늘 쉬는 날인 습관 목록
                              if (habitProvider.restHabits.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.beach_access_rounded,
                                        size: 16,
                                        color: context.textMuted,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '오늘은 쉬는 습관 (${habitProvider.restHabits.length})',
                                        style: TextStyle(
                                          color: context.textMuted,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ...habitProvider.restHabits.map(
                                  (habitStatus) => HabitCardItem(
                                    habitStatus: habitStatus,
                                    onToggle: () {
                                      if (habitStatus.habit.id != null) {
                                        habitProvider
                                            .toggleHabit(habitStatus.habit.id!);
                                      }
                                    },
                                    onIncrement: () {
                                      if (habitStatus.habit.id != null) {
                                        habitProvider.incrementHabitCount(
                                            habitStatus.habit.id!);
                                      }
                                    },
                                    onDecrement: () {
                                      if (habitStatus.habit.id != null) {
                                        habitProvider.decrementHabitCount(
                                            habitStatus.habit.id!);
                                      }
                                    },
                                    onTapDetail: () {
                                      _onEditHabit(habitStatus.habit);
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddHabitPressed,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add_rounded, size: 30),
      ),
    );
  }
}
