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
import 'widgets/habit_calendar_picker_dialog.dart';
import 'widgets/habit_card_item.dart';
import 'widgets/today_header.dart';

/// 3초 습관 메인 홈 화면 (오늘의 체크리스트 / 통계 / 설정 탭)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 화면 진입 시 오늘 습관 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().loadHabits();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 바탕화면 위젯 등 외부에서 데이터가 변경되었을 수 있으므로 앱 복귀 시 실시간 동기화
      context.read<HabitProvider>().loadHabits();
    }
  }

  void _onAddHabitPressed() async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (_) => HabitEditScreen(initialTabIndex: _currentTabIndex),
      ),
    );
    if (!mounted) return;
    if (result == true) {
      context.read<HabitProvider>().loadHabits();
    } else if (result is int) {
      setState(() {
        _currentTabIndex = result;
      });
      context.read<HabitProvider>().loadHabits();
    }
  }

  void _onEditHabit(dynamic habit) async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (_) => HabitEditScreen(
          habit: habit,
          initialTabIndex: _currentTabIndex,
        ),
      ),
    );
    if (!mounted) return;
    if (result == true) {
      context.read<HabitProvider>().loadHabits();
    } else if (result is int) {
      setState(() {
        _currentTabIndex = result;
      });
      context.read<HabitProvider>().loadHabits();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          _buildTodayChecklistTab(),
          const StatsScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  /// 슬림 & 프리미엄 하단 탭 내비게이션 바 (높이 54px로 최적화)
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        border: Border(
          top: BorderSide(
            color: context.surfaceBorder.withValues(alpha: 0.7),
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.25 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 공통 가로 100% 하단 배너 광고
          const AdBannerSlot(),
          // 슬림 & 프리미엄 커스텀 탭 내비게이션 바
          SafeArea(
            top: false,
            bottom: true,
            child: SizedBox(
              height: 54,
              child: Row(
                children: [
                  _buildTabItem(
                    index: 0,
                    icon: Icons.check_circle_outline_rounded,
                    activeIcon: Icons.check_circle_rounded,
                    label: '오늘의 습관',
                  ),
                  _buildTabItem(
                    index: 1,
                    icon: Icons.bar_chart_outlined,
                    activeIcon: Icons.bar_chart_rounded,
                    label: '통계/기록',
                  ),
                  _buildTabItem(
                    index: 2,
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings_rounded,
                    label: '설정',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentTabIndex == index;
    final activeColor = context.isDarkMode ? const Color(0xFFA78BFA) : AppColors.primary;
    final activeTextColor = context.isDarkMode ? const Color(0xFFDDD6FE) : AppColors.primaryDark;
    final inactiveColor = context.textMuted;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (_currentTabIndex != index) {
              setState(() => _currentTabIndex = index);
            }
          },
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 상단 캡슐형 아이콘 하이라이트
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: context.isDarkMode ? 0.22 : 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  size: 21,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
              const SizedBox(height: 2),
              // 텍스트 라벨
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? activeTextColor : inactiveColor,
                  letterSpacing: -0.2,
                ),
                child: Text(label),
              ),
            ],
          ),
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
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: context.bg,
            border: Border(
              bottom: BorderSide(
                color: context.surfaceBorder.withValues(alpha: 0.6),
                width: 0.8,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 앱 타이틀 — 모던 프리미엄 브랜드 뱃지 + 타이포그래피
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: context.isDarkMode ? 0.22 : 0.12),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: context.isDarkMode ? 0.4 : 0.2),
                            width: 1.0,
                          ),
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: AppColors.primaryLight,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '3초 습관',
                        style: TextStyle(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          letterSpacing: -0.6,
                          height: 1.1,
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
                        color: context.surface,
                        border: Border.all(
                          color: context.surfaceBorder,
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        context.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        size: 18,
                        color: context.isDarkMode
                            ? const Color(0xFFFBBF24)
                            : context.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 캘린더 아이콘 (날짜 선택 팝업 연결)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      final picked = await HabitCalendarPickerDialog.show(
                        context,
                        initialDate: habitProvider.selectedDate,
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
                        color: context.surface,
                        border: Border.all(
                          color: context.surfaceBorder,
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        size: 17,
                        color: context.textPrimary,
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
                        color: context.surface,
                        border: Border.all(
                          color: context.surfaceBorder,
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.help_outline_rounded,
                        size: 18,
                        color: context.textSecondary,
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
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 100),
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
