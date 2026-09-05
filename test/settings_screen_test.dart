import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:three_sec_habit/presentation/settings/settings_screen.dart';
import 'package:three_sec_habit/providers/theme_provider.dart';

void main() {
  testWidgets('설정 화면 테마 토글 및 설정 항목 렌더링 테스트', (WidgetTester tester) async {
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: themeProvider,
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pump();

    expect(find.text('설정'), findsOneWidget);
    expect(find.text('테마 모드 선택'), findsOneWidget);
    expect(find.text('라이트'), findsOneWidget);
    expect(find.text('다크'), findsOneWidget);
    expect(find.text('전체 알림 허용'), findsOneWidget);
    expect(find.text('데이터 백업 (내보내기)'), findsOneWidget);
  });

  testWidgets('설정 화면 바탕화면 위젯 미리보기 및 추가 모달 렌더링 및 탭 전환 검증', (WidgetTester tester) async {
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: themeProvider,
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pump();

    // 1. 위젯 미리보기 버튼 찾아서 탭
    final previewTipFinder = find.text('바탕화면 위젯 실시간 미리보기 & 사용 팁');
    expect(previewTipFinder, findsOneWidget);
    await tester.tap(previewTipFinder);
    await tester.pumpAndSettle();

    // 2. 다이얼로그 헤더 및 4x2 실시간 미리보기 내용 검증
    expect(find.text('바탕화면 위젯 미리보기 & 추가'), findsOneWidget);
    expect(find.text('4x2 체크리스트 (추천)'), findsOneWidget);
    expect(find.text('2x2 퀵 대시보드'), findsOneWidget);
    expect(find.text('⚡ 3초 습관 · 오늘 루틴'), findsOneWidget);
    expect(find.text('4x2 위젯 홈에 추가'), findsOneWidget);
    expect(find.text('닫기'), findsOneWidget);

    // 3. 2x2 탭으로 전환
    await tester.tap(find.text('2x2 퀵 대시보드'));
    await tester.pumpAndSettle();

    // 4. 2x2 미리보기 내용 및 하단 버튼 라벨 변경 검증
    expect(find.text('2x2 위젯 홈에 추가'), findsOneWidget);
    expect(find.text('1순위 빠른 체크'), findsOneWidget);

    // 5. 닫기 버튼 탭하여 다이얼로그 닫힘 확인
    await tester.tap(find.text('닫기'));
    await tester.pumpAndSettle();
    expect(find.text('바탕화면 위젯 미리보기 & 추가'), findsNothing);
  });
}
