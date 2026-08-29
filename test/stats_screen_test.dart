import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:three_sec_habit/models/habit.dart';
import 'package:three_sec_habit/models/habit_with_today_status.dart';
import 'package:three_sec_habit/presentation/stats/widgets/grass_heatmap_calendar.dart';
import 'package:three_sec_habit/presentation/stats/widgets/habit_stat_card.dart';
import 'package:three_sec_habit/presentation/stats/widgets/overall_streak_banner.dart';

void main() {
  group('통계 화면 및 위젯 테스트', () {
    testWidgets('1. OverallStreakBanner 스트릭 하이라이트 배너 렌더링', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OverallStreakBanner(
              maxCurrentStreak: 7,
              bestEverStreak: 15,
              totalCompletions: 42,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('나의 습관 연속 기록'), findsOneWidget);
      expect(find.text('7일'), findsOneWidget);
      expect(find.text('15일'), findsOneWidget);
      expect(find.text('42회'), findsOneWidget);
    });

    testWidgets('2. GrassHeatmapCalendar 깃허브 잔디밭 히트맵 렌더링', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: GrassHeatmapCalendar(
                year: 2026,
                month: 8,
                heatmapData: const {
                  '2026-08-01': 1,
                  '2026-08-02': 2,
                  '2026-08-03': 4,
                },
                onPreviousMonth: () {},
                onNextMonth: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('2026년 8월'), findsOneWidget);
    });

    testWidgets('3. HabitStatCard 개별 습관 스트릭 카드 렌더링', (WidgetTester tester) async {
      final habit = Habit(id: 1, title: '독서 30분', iconName: 'menu_book');
      final habitStatus = HabitWithTodayStatus(
        habit: habit,
        isCompletedToday: true,
        currentStreak: 3,
        bestStreak: 10,
        completionRate: 0.75,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitStatCard(habitStatus: habitStatus),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('독서 30분'), findsOneWidget);
      expect(find.text('3일'), findsOneWidget);
      expect(find.text('최고 10일'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
    });
  });
}
