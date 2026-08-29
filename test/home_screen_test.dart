import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:three_sec_habit/models/habit.dart';
import 'package:three_sec_habit/models/habit_with_today_status.dart';
import 'package:three_sec_habit/presentation/home/widgets/empty_habit_view.dart';
import 'package:three_sec_habit/presentation/home/widgets/habit_card_item.dart';
import 'package:three_sec_habit/presentation/home/widgets/today_header.dart';

void main() {
  group('홈 화면 위젯 컴포넌트 단위 테스트', () {
    testWidgets('1. TodayHeader 달성률 및 프로그레스 렌더링 검증', (WidgetTester tester) async {
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

    testWidgets('2. HabitCardItem 체크 토글 손맛 인터랙션 및 애니메이션 검증', (WidgetTester tester) async {
      bool isToggled = false;
      final habit = Habit(
        id: 1,
        title: '물 2L 마시기',
        iconName: 'water_drop',
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

      expect(find.text('물 2L 마시기'), findsOneWidget);
      expect(find.text('5일 연속'), findsOneWidget);

      // 체크 버튼 탭
      await tester.tap(find.text('물 2L 마시기'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(isToggled, isTrue);
    });

    testWidgets('3. EmptyHabitView 빈 상태 뷰 렌더링 검증', (WidgetTester tester) async {
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
