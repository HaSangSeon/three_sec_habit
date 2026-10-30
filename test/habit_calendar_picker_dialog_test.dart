import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:three_sec_habit/presentation/home/widgets/habit_calendar_picker_dialog.dart';

void main() {
  testWidgets('HabitCalendarPickerDialog 렌더링 및 날짜 선택 인터랙션 검증', (tester) async {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final initialDate = today;

    DateTime? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                selected = await HabitCalendarPickerDialog.show(
                  context,
                  initialDate: initialDate,
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );

    // 1. 다이얼로그 열기
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // 2. 다이얼로그 요소 검증
    expect(find.text('날짜 선택'), findsOneWidget);
    expect(find.text('오늘'), findsOneWidget);
    expect(find.text('어제'), findsOneWidget);
    expect(find.text('2일 전'), findsOneWidget);
    expect(find.text('취소'), findsOneWidget);
    expect(find.text('오늘로 이동'), findsOneWidget);

    // 3. '어제' 칩 탭
    await tester.tap(find.text('어제'));
    await tester.pumpAndSettle();

    // 이동 버튼 라벨이 어제 날짜로 변경되었는지 확인
    final expectedYesterdayText = '${yesterday.month}/${yesterday.day} 이동';
    expect(find.text(expectedYesterdayText), findsOneWidget);

    // 4. 이동 버튼 탭하여 결과 반환 확인
    await tester.tap(find.text(expectedYesterdayText));
    await tester.pumpAndSettle();

    expect(selected, isNotNull);
    expect(selected!.year, yesterday.year);
    expect(selected!.month, yesterday.month);
    expect(selected!.day, yesterday.day);
  });
}
