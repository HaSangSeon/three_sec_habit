import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:three_sec_habit/core/constants/app_colors.dart';
import 'package:three_sec_habit/models/habit.dart';
import 'package:three_sec_habit/models/habit_with_today_status.dart';
import 'package:three_sec_habit/presentation/habit_edit/habit_edit_screen.dart';
import 'package:three_sec_habit/presentation/home/widgets/habit_card_item.dart';
import 'package:three_sec_habit/presentation/home/widgets/today_header.dart';
import 'package:three_sec_habit/presentation/stats/widgets/grass_heatmap_calendar.dart';
import 'package:three_sec_habit/presentation/stats/widgets/habit_stat_card.dart';
import 'package:three_sec_habit/presentation/stats/widgets/overall_streak_banner.dart';
import 'package:three_sec_habit/providers/habit_provider.dart';
import 'package:three_sec_habit/providers/theme_provider.dart';

Future<void> saveScreenshot(WidgetTester tester, GlobalKey key, String filename) async {
  await tester.runAsync(() async {
    final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 2.5);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final buffer = byteData.buffer.asUint8List();
    final file = File('/Users/hasangseon/three_sec_habit/build/$filename');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(buffer);
    print('SUCCESS_SAVED: $filename');
  });
}

Widget buildWrapper(Widget child, GlobalKey key) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => HabitProvider()),
    ],
    child: MaterialApp(
      theme: ThemeProvider.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: SafeArea(
          child: RepaintBoundary(
            key: key,
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  final h1 = Habit(id: 1, title: '기상 직후 물 한 잔', iconName: 'water_drop', colorValue: 0xFF06B6D4);
  final h2 = Habit(id: 2, title: '아침 20분 러닝', iconName: 'directions_run', colorValue: 0xFF8B5CF6);
  final h3 = Habit(
    id: 3,
    title: '물 8잔 마시기',
    iconName: 'water_drop',
    colorValue: 0xFF0EA5E9,
    habitType: HabitType.count,
    targetCount: 8,
    unit: '잔',
    reminderEnabled: true,
    reminderType: ReminderType.interval,
    reminderIntervalMinutes: 60,
  );
  final h4 = Habit(id: 4, title: '비타민 & 영양제 복용', iconName: 'medication', colorValue: 0xFF10B981);
  final h5 = Habit(
    id: 5,
    title: '10분 독서하기',
    iconName: 'menu_book',
    colorValue: 0xFFF59E0B,
    repeatType: RepeatType.weeklyDays,
    repeatDays: [1, 3, 5],
  );

  final status1 = HabitWithTodayStatus(habit: h1, isCompletedToday: true, currentStreak: 7, isScheduledToday: true);
  final status2 = HabitWithTodayStatus(habit: h2, isCompletedToday: true, currentStreak: 5, isScheduledToday: true);
  final status3 = HabitWithTodayStatus(habit: h3, isCompletedToday: false, todayCount: 5, currentStreak: 8, isScheduledToday: true);
  final status4 = HabitWithTodayStatus(habit: h4, isCompletedToday: true, currentStreak: 12, isScheduledToday: true);
  final status5 = HabitWithTodayStatus(habit: h5, isCompletedToday: false, currentStreak: 3, isScheduledToday: false);

  testWidgets('1. Capture Real Home Screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);

    final key = GlobalKey();
    await tester.pumpWidget(
      buildWrapper(
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '3초 습관',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const Icon(Icons.settings_outlined, color: Colors.white70),
                ],
              ),
            ),
            const TodayHeader(
              dateString: '8월 30일 (일)',
              completedCount: 3,
              totalCount: 4,
              progressRate: 0.75,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  HabitCardItem(habitStatus: status1, onToggle: () {}),
                  HabitCardItem(habitStatus: status2, onToggle: () {}),
                  HabitCardItem(habitStatus: status3, onToggle: () {}),
                  HabitCardItem(habitStatus: status4, onToggle: () {}),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.beach_access_rounded, size: 16, color: Colors.white54),
                        SizedBox(width: 6),
                        Text(
                          '오늘은 쉬는 습관 (1)',
                          style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  HabitCardItem(habitStatus: status5, onToggle: () {}),
                ],
              ),
            ),
          ],
        ),
        key,
      ),
    );
    await tester.pump();
    await saveScreenshot(tester, key, 'real_screen_1_home.png');
  });

  testWidgets('2. Capture Real Water Screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);

    final key = GlobalKey();
    await tester.pumpWidget(
      buildWrapper(
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '3초 습관',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const Icon(Icons.settings_outlined, color: Colors.white70),
                ],
              ),
            ),
            const TodayHeader(
              dateString: '8월 30일 (일)',
              completedCount: 3,
              totalCount: 4,
              progressRate: 0.75,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  HabitCardItem(habitStatus: status3, onToggle: () {}),
                  HabitCardItem(habitStatus: status1, onToggle: () {}),
                  HabitCardItem(habitStatus: status2, onToggle: () {}),
                  HabitCardItem(habitStatus: status4, onToggle: () {}),
                ],
              ),
            ),
          ],
        ),
        key,
      ),
    );
    await tester.pump();
    await saveScreenshot(tester, key, 'real_screen_2_water.png');
  });

  testWidgets('3. Capture Real Stats Screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);

    final key = GlobalKey();
    final heatmapData = <String, int>{};
    for (int i = 1; i <= 29; i++) {
      final date = '2026-08-${i.toString().padLeft(2, '0')}';
      heatmapData[date] = (i % 4) + 1;
    }

    await tester.pumpWidget(
      buildWrapper(
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '습관 기록 & 통계',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  const OverallStreakBanner(
                    maxCurrentStreak: 14,
                    bestEverStreak: 28,
                    totalCompletions: 142,
                  ),
                  GrassHeatmapCalendar(
                    year: 2026,
                    month: 8,
                    heatmapData: heatmapData,
                    onPreviousMonth: () {},
                    onNextMonth: () {},
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Text(
                      '습관별 달성률',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  HabitStatCard(habitStatus: status1),
                  HabitStatCard(habitStatus: status2),
                  HabitStatCard(habitStatus: status3),
                ],
              ),
            ),
          ],
        ),
        key,
      ),
    );
    await tester.pump();
    await saveScreenshot(tester, key, 'real_screen_3_stats.png');
  });

  testWidgets('4. Capture Real Edit Screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);

    final key = GlobalKey();
    await tester.pumpWidget(
      buildWrapper(
        HabitEditScreen(habit: h3),
        key,
      ),
    );
    await tester.pump();
    await saveScreenshot(tester, key, 'real_screen_4_edit.png');
  });
}
