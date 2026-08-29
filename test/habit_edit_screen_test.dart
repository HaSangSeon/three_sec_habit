import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:three_sec_habit/presentation/habit_edit/habit_edit_screen.dart';
import 'package:three_sec_habit/providers/habit_provider.dart';
import 'package:three_sec_habit/providers/theme_provider.dart';

void main() {
  testWidgets('새 습관 생성 폼 렌더링 및 주요 입력 컴포넌트 검증', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => HabitProvider()),
        ],
        child: const MaterialApp(
          home: HabitEditScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('새 습관 만들기'), findsOneWidget);
    expect(find.text('습관 이름'), findsOneWidget);
    expect(find.text('아이콘 선택'), findsOneWidget);
    expect(find.text('포인트 색상'), findsOneWidget);
    expect(find.text('반복 주기'), findsOneWidget);
    expect(find.text('알림 설정'), findsOneWidget);
  });
}
