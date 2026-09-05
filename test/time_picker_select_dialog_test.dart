import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:three_sec_habit/presentation/common/time_picker_select_dialog.dart';

void main() {
  group('TimePickerSelectDialog 시간 선택 셀렉트박스 다이얼로그 테스트', () {
    testWidgets('1. 오전 시간(08:30) 초기 렌더링 및 24시간 표기 검증', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimePickerSelectDialog(
              initialTime: TimeOfDay(hour: 8, minute: 30),
              title: '지정 알림 시간 설정',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('지정 알림 시간 설정'), findsOneWidget);
      expect(find.text('오전'), findsWidgets);
      expect(find.text('08 : 30'), findsOneWidget);
      expect(find.text('(08:30)'), findsOneWidget);
      expect(find.text('08시'), findsOneWidget);
      expect(find.text('30분'), findsOneWidget);
    });

    testWidgets('2. 오후 시간(21:15) 초기 렌더링 검증', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimePickerSelectDialog(
              initialTime: TimeOfDay(hour: 21, minute: 15),
              title: '알림 종료 시간 설정',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('알림 종료 시간 설정'), findsOneWidget);
      expect(find.text('오후'), findsWidgets);
      expect(find.text('09 : 15'), findsOneWidget);
      expect(find.text('(21:15)'), findsOneWidget);
      expect(find.text('09시'), findsOneWidget);
      expect(find.text('15분'), findsOneWidget);
    });

    testWidgets('3. 퀵 선택 칩(점심 12:30) 터치 시 시간 즉시 반영 검증', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimePickerSelectDialog(
              initialTime: TimeOfDay(hour: 8, minute: 0),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 점심 12:30 칩 클릭
      await tester.tap(find.text('점심 12:30'));
      await tester.pumpAndSettle();

      expect(find.text('12 : 30'), findsOneWidget);
      expect(find.text('(12:30)'), findsOneWidget);
      expect(find.text('오후'), findsWidgets);
    });
  });
}
