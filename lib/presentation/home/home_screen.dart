import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_util.dart';
import '../../providers/habit_provider.dart';
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
        child: NavigationBar(
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
      ),
    );
  }

  /// 탭 1: 오늘의 습관 체크리스트
  Widget _buildTodayChecklistTab() {
    final habitProvider = context.watch<HabitProvider>();
    final todayStr = DateUtil.formatForDisplay(DateTime.now());

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        title: Row(
          children: [
            const Icon(
              Icons.bolt_rounded,
              color: AppColors.primary,
              size: 26,
            ),
            const SizedBox(width: 6),
            Text(
              '3초 습관',
              style: TextStyle(
                color: context.textPrimary,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today_rounded, size: 20, color: context.textPrimary),
            tooltip: '오늘로 이동',
            onPressed: () {
              habitProvider.setSelectedDate(DateTime.now());
            },
          ),
          const SizedBox(width: 8),
        ],
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
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: habitProvider.habits.length,
                            itemBuilder: (context, index) {
                              final habitStatus = habitProvider.habits[index];
                              return HabitCardItem(
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
                              );
                            },
                          ),
                        ),
            ),

            // 3. 하단 AdMob 배너 광고 영역
            const AdBannerSlot(),
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
