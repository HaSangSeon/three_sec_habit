import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:three_sec_habit/models/habit.dart';
import 'package:three_sec_habit/models/habit_with_today_status.dart';
import 'package:three_sec_habit/presentation/home/widgets/empty_habit_view.dart';
import 'package:three_sec_habit/presentation/home/widgets/habit_card_item.dart';
import 'package:three_sec_habit/presentation/home/widgets/today_header.dart';

void main() {
  group('홈 화면 위젯 컴포넌트 단위 테스트', () {
    testWidgets('1. TodayHeader 달성률 및 프로그레스 렌더링 검증',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TodayHeader(
              dateString: '8월 29일 (토)',
              completedCount: 3,
              totalCount: 5,
              progressRate: 0.6,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('8월 29일 (토)'), findsOneWidget);
      expect(find.text('3초 컷'), findsOneWidget);
      expect(find.textContaining('3'), findsWidgets);
      expect(find.text('60%'), findsOneWidget);
      expect(find.text('3개 완료됨 (2개 남음)'), findsOneWidget);
    });

    testWidgets('2. HabitCardItem 체크 토글 손맛 인터랙션 및 애니메이션 검증',
        (WidgetTester tester) async {
      bool isToggled = false;
      final habit = Habit(
        id: 1,
        title: '영양제 먹기',
        iconName: 'medication',
      );
      final habitStatus = HabitWithTodayStatus(
        habit: habit,
        isCompletedToday: false,
        currentStreak: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitCardItem(
              habitStatus: habitStatus,
              onToggle: () {
                isToggled = true;
              },
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('영양제 먹기'), findsOneWidget);
      expect(find.text('5일 연속'), findsOneWidget);

      await tester.tap(find.text('영양제 먹기'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(isToggled, isTrue);
    });

    testWidgets('3. HabitCardItem 카운트형 습관(물 8잔) 프로그레스 및 증감 검증',
        (WidgetTester tester) async {
      bool incremented = false;
      bool decremented = false;

      final habit = Habit(
        id: 2,
        title: '물 8잔 마시기',
        iconName: 'water_drop',
        habitType: HabitType.count,
        targetCount: 8,
        unit: '잔',
        reminderEnabled: true,
        reminderType: ReminderType.interval,
        reminderIntervalMinutes: 60,
      );
      final habitStatus = HabitWithTodayStatus(
        habit: habit,
        todayCount: 3,
        isCompletedToday: false,
        currentStreak: 3,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitCardItem(
              habitStatus: habitStatus,
              onToggle: () {},
              onIncrement: () {
                incremented = true;
              },
              onDecrement: () {
                decremented = true;
              },
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('물 8잔 마시기'), findsOneWidget);
      expect(find.text('1시간마다'), findsOneWidget);
      expect(find.text('3 / 8 잔'), findsOneWidget);

      // 탭하여 1잔 증가
      await tester.tap(find.text('물 8잔 마시기'));
      await tester.pump();
      expect(incremented, isTrue);

      // - 버튼 탭하여 1잔 감소
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(decremented, isTrue);
    });

    testWidgets('4. EmptyHabitView 빈 상태 뷰 렌더링 검증',
        (WidgetTester tester) async {
      bool addPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyHabitView(
              onAddHabit: () {
                addPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('체크 한 번, 3초 컷!'), findsOneWidget);
      expect(find.text('첫 습관 추가하기'), findsOneWidget);

      await tester.tap(find.text('첫 습관 추가하기'));
      await tester.pump();

      expect(addPressed, isTrue);
    });
  });
}
