import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:three_sec_habit/presentation/habit_edit/habit_edit_screen.dart';
import 'package:three_sec_habit/providers/habit_provider.dart';
import 'package:three_sec_habit/providers/theme_provider.dart';

void main() {
  testWidgets('새 습관 생성 폼 렌더링 및 주요 입력 컴포넌트 검증', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

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

    await tester.pumpAndSettle();

    expect(find.text('새 습관 만들기'), findsOneWidget);
    expect(find.text('습관 기록 방식'), findsOneWidget);
    expect(find.text('단순 체크형 (1회)'), findsOneWidget);
    expect(find.text('목표 횟수형 (하루 N회)'), findsOneWidget);
    expect(find.text('습관 이름'), findsOneWidget);
    expect(find.text('아이콘 선택'), findsOneWidget);
    expect(find.text('포인트 색상'), findsOneWidget);
    expect(find.text('반복 주기'), findsOneWidget);
    expect(find.text('알림 설정'), findsOneWidget);

    // 목표 횟수형 탭 시 하루 목표 카운터 및 단위 선택기 노출 확인
    await tester.tap(find.text('목표 횟수형 (하루 N회)'));
    await tester.pumpAndSettle();

    expect(find.text('하루 목표 횟수 및 단위'), findsOneWidget);
    expect(find.text('하루 목표'), findsOneWidget);
    expect(find.text('8'), findsOneWidget); // 기본 8잔
    expect(find.text('단위 선택'), findsOneWidget);
  });
}
