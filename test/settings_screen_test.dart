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

    await tester.pump();

    expect(find.text('설정'), findsOneWidget);
    expect(find.text('다크 모드'), findsOneWidget);
    expect(find.text('전체 알림 허용'), findsOneWidget);
    expect(find.text('데이터 백업 (내보내기)'), findsOneWidget);
    expect(find.text('1.0.0 (3초 컷)'), findsOneWidget);
  });
}
