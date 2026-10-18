import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:three_sec_habit/presentation/habit_edit/habit_edit_screen.dart';
import 'package:three_sec_habit/presentation/home/home_screen.dart';
import 'package:three_sec_habit/presentation/settings/settings_screen.dart';
import 'package:three_sec_habit/providers/habit_provider.dart';
import 'package:three_sec_habit/providers/theme_provider.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('안드로이드 하단 내비게이션 바(소프트키/제스처/하드웨어키) 인셋 및 가려짐 방지 검증', () {
    final navScenarios = [
      (
        type: '1. 하드웨어 키보드/구형 보급형 (하단 소프트키 0dp)',
        size: const Size(360, 640),
        bottomInset: 0.0,
      ),
      (
        type: '2. 3버튼 소프트키 내비게이션 바 (하단 소프트키 48dp)',
        size: const Size(393, 852),
        bottomInset: 48.0,
      ),
      (
        type: '3. 최신 제스처 내비게이션 바 (하단 필 인셋 24dp)',
        size: const Size(412, 915),
        bottomInset: 24.0,
      ),
      (
        type: '4. 초소형 보급형 화면 + 3버튼 소프트키 (320x568 + 48dp)',
        size: const Size(320, 568),
        bottomInset: 48.0,
      ),
    ];

    for (final scenario in navScenarios) {
      testWidgets('HomeScreen 탭바 및 플로팅버튼 가려짐 없음 검증: ${scenario.type}', (tester) async {
        tester.view.physicalSize = scenario.size;
        tester.view.devicePixelRatio = 1.0;
        tester.view.padding = FakeViewPadding(
          top: 24,
          bottom: scenario.bottomInset,
          left: 0,
          right: 0,
        );
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPadding);

        final themeProvider = ThemeProvider();
        final habitProvider = HabitProvider();

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: themeProvider),
              ChangeNotifierProvider.value(value: habitProvider),
            ],
            child: const MaterialApp(home: HomeScreen()),
          ),
        );
        await tester.pump();

        // 1. 하단 3개 탭 텍스트가 정상 렌더링되고 가려지지 않는지 확인
        final tab1 = find.text('오늘의 습관');
        final tab2 = find.text('통계/기록');
        final tab3 = find.text('설정');

        expect(tab1, findsOneWidget);
        expect(tab2, findsOneWidget);
        expect(tab3, findsOneWidget);

        // 2. 탭 버튼의 화면 상 실제 Y좌표가 소프트키 영역(scenario.size.height - bottomInset)보다 위에 위치하는지 확인
        final tab1Bottom = tester.getBottomRight(tab1).dy;
        final safeScreenBottom = scenario.size.height - scenario.bottomInset;
        expect(tab1Bottom <= safeScreenBottom, true,
            reason: '하단 탭 텍스트($tab1Bottom)는 시스템 소프트키 시작 위치($safeScreenBottom)보다 항상 위에 있어야 합니다.');

        // 3. 플로팅 액션 버튼(+)도 탭바 위에 정상 배치되어 있는지 확인
        final fab = find.byType(FloatingActionButton);
        expect(fab, findsOneWidget);
        final fabBottom = tester.getBottomRight(fab).dy;
        expect(fabBottom <= safeScreenBottom, true,
            reason: '플로팅 버튼($fabBottom)이 시스템 소프트키에 가려지지 않아야 합니다.');
      });

      testWidgets('HabitEditScreen 저장 버튼 가려짐 없음 및 스크롤 완료 검증: ${scenario.type}', (tester) async {
        tester.view.physicalSize = scenario.size;
        tester.view.devicePixelRatio = 1.0;
        tester.view.padding = FakeViewPadding(
          top: 24,
          bottom: scenario.bottomInset,
          left: 0,
          right: 0,
        );
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPadding);

        final themeProvider = ThemeProvider();
        final habitProvider = HabitProvider();

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: themeProvider),
              ChangeNotifierProvider.value(value: habitProvider),
            ],
            child: const MaterialApp(home: HabitEditScreen()),
          ),
        );
        await tester.pump();

        // 최하단 저장 버튼까지 스크롤 (TextField 간섭 없는 안전한 좌표에서 드래그)
        for (int i = 0; i < 20 && find.text('✨ 3초 습관 시작하기').evaluate().isEmpty; i++) {
          await tester.dragFrom(
            Offset(scenario.size.width - 10, scenario.size.height * 0.7),
            const Offset(0, -300),
          );
          await tester.pumpAndSettle();
        }

        final saveBtn = find.text('✨ 3초 습관 시작하기');
        expect(saveBtn, findsOneWidget);

        // 저장 버튼의 하단 위치가 소프트키 영역에 가려지지 않는지 확인
        final saveBtnRect = tester.getRect(saveBtn);
        final safeScreenBottom = scenario.size.height - scenario.bottomInset;
        expect(saveBtnRect.bottom <= safeScreenBottom, true,
            reason: '저장 버튼(${saveBtnRect.bottom})이 하단 소프트키($safeScreenBottom) 및 하단 바에 가려지지 않아야 합니다.');
      });
    }

    testWidgets('키보드 노출 시(viewInsets.bottom: 320) 레이아웃 오버플로우 방어 검증', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 48, left: 0, right: 0);
      // 키보드 가상 노출
      tester.view.viewInsets = const FakeViewPadding(top: 0, bottom: 320, left: 0, right: 0);

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewInsets);

      final themeProvider = ThemeProvider();
      final habitProvider = HabitProvider();

      FlutterErrorDetails? errorCaught;
      final prev = FlutterError.onError;
      FlutterError.onError = (d) => errorCaught = d;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeProvider),
            ChangeNotifierProvider.value(value: habitProvider),
          ],
          child: const MaterialApp(home: HabitEditScreen()),
        ),
      );
      await tester.pump();

      FlutterError.onError = prev;
      expect(errorCaught, isNull, reason: '키보드 노출 시 오버플로우 에러가 발생하지 않아야 합니다.');
    });

    testWidgets('SettingsScreen 3버튼 소프트키(48dp) 환경에서 최하단 앱 정보 가려짐 없음 검증', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 48, left: 0, right: 0);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);

      final themeProvider = ThemeProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeProvider),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pump();

      // 최하단 앱 정보 섹션까지 스크롤
      final versionText = find.text('3초 습관');
      final listView = find.byType(ListView);
      for (int i = 0; i < 15 && versionText.evaluate().isEmpty; i++) {
        await tester.drag(listView, const Offset(0, -300));
        await tester.pumpAndSettle();
      }

      expect(versionText, findsOneWidget);
    });
  });
}
