import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:three_sec_habit/models/habit.dart';
import 'package:three_sec_habit/presentation/common/time_picker_select_dialog.dart';
import 'package:three_sec_habit/presentation/habit_edit/habit_edit_screen.dart';
import 'package:three_sec_habit/presentation/habit_edit/widgets/habit_reminder_card.dart';
import 'package:three_sec_habit/presentation/home/home_screen.dart';
import 'package:three_sec_habit/presentation/home/widgets/habit_calendar_picker_dialog.dart';
import 'package:three_sec_habit/presentation/settings/settings_screen.dart';
import 'package:three_sec_habit/presentation/settings/widgets/widget_preview_pin_dialog.dart';
import 'package:three_sec_habit/presentation/stats/stats_screen.dart';
import 'package:three_sec_habit/providers/habit_provider.dart';
import 'package:three_sec_habit/providers/theme_provider.dart';

void main() {
  final testDevices = [
    (name: 'Small Android (320x568)', size: const Size(320, 568), textScale: 1.0),
    (name: 'Compact Android (360x640)', size: const Size(360, 640), textScale: 1.0),
    (name: 'Standard Android (393x852)', size: const Size(393, 852), textScale: 1.0),
    (name: 'Large Android (412x915)', size: const Size(412, 915), textScale: 1.0),
    (name: 'Foldable / Tablet (600x960)', size: const Size(600, 960), textScale: 1.0),
    (name: 'Large Tablet (800x1280)', size: const Size(800, 1280), textScale: 1.0),
    (name: 'Landscape Tablet (960x600)', size: const Size(960, 600), textScale: 1.0),
    (name: 'Accessibility Large Font (360x640, 1.3x)', size: const Size(360, 640), textScale: 1.3),
    (name: 'Accessibility Huge Font (393x852, 1.5x)', size: const Size(393, 852), textScale: 1.5),
  ];

  for (final device in testDevices) {
    testWidgets('반응형 레이아웃 검증: ${device.name}', (WidgetTester tester) async {
      tester.view.physicalSize = device.size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final themeProvider = ThemeProvider();
      final habitProvider = HabitProvider();
      final List<String> errors = [];

      Future<void> checkWidget(String name, Widget widget) async {
        FlutterErrorDetails? caught;
        final prev = FlutterError.onError;
        FlutterError.onError = (d) {
          caught = d;
        };
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(
              size: device.size,
              textScaler: TextScaler.linear(device.textScale),
            ),
            child: widget,
          ),
        );
        await tester.pump();
        if (caught != null) {
          final nodes = caught!.informationCollector?.call().map((n) => n.toString()).join('\n') ?? '';
          errors.add('[$name at ${device.name}] ${caught!.exceptionAsString()}\n$nodes');
        }
        FlutterError.onError = prev;
      }

      // 1. HomeScreen
      await checkWidget(
        'HomeScreen',
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeProvider),
            ChangeNotifierProvider.value(value: habitProvider),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // 2. SettingsScreen
      await checkWidget(
        'SettingsScreen',
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeProvider),
            ChangeNotifierProvider.value(value: habitProvider),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );

      // 3. StatsScreen
      await checkWidget(
        'StatsScreen',
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeProvider),
            ChangeNotifierProvider.value(value: habitProvider),
          ],
          child: const MaterialApp(home: StatsScreen()),
        ),
      );

      // 4. HabitEditScreen
      await checkWidget(
        'HabitEditScreen',
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeProvider),
            ChangeNotifierProvider.value(value: habitProvider),
          ],
          child: const MaterialApp(home: HabitEditScreen()),
        ),
      );

      // 5. HabitReminderCard
      await checkWidget(
        'HabitReminderCard',
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HabitReminderCard(
                reminderEnabled: true,
                reminderType: ReminderType.interval,
                reminderTimes: const [TimeOfDay(hour: 9, minute: 0)],
                reminderIntervalMinutes: 60,
                reminderStartTime: const TimeOfDay(hour: 0, minute: 0),
                reminderEndTime: const TimeOfDay(hour: 23, minute: 59),
                suggestedIntervals: const [30, 60, 120, 180],
                habitType: HabitType.check,
                targetCount: 1,
                habitTitle: '물 마시기',
                reminderSubtitle: '매 1시간마다 알림',
                onReminderEnabledChanged: (_) {},
                onReminderTypeChanged: (_) {},
                onEditFixedTime: (_) {},
                onRemoveFixedTime: (_) {},
                onAddFixedTime: () {},
                onIntervalMinutesChanged: (_) {},
                isNightExcluded: false,
                onNightExcludedChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // 6. TimePickerSelectDialog
      await checkWidget(
        'TimePickerSelectDialog',
        MaterialApp(
          home: Scaffold(
            body: TimePickerSelectDialog(
              initialTime: const TimeOfDay(hour: 14, minute: 30),
              title: '알림 시간 설정',
            ),
          ),
        ),
      );

      // 7. HabitCalendarPickerDialog
      await checkWidget(
        'HabitCalendarPickerDialog',
        MaterialApp(
          home: Scaffold(
            body: HabitCalendarPickerDialog(
              initialDate: DateTime.now(),
            ),
          ),
        ),
      );

      // 8. WidgetPreviewPinDialog
      await checkWidget(
        'WidgetPreviewPinDialog',
        MaterialApp(
          home: Scaffold(
            body: WidgetPreviewPinDialog(
              onPinWidget: ({required bool is4x2}) async {},
            ),
          ),
        ),
      );

      if (errors.isNotEmpty) {
        // ignore: avoid_print
        print('=== ERRORS FOUND FOR ${device.name} ===\n${errors.join('\n')}\n====================');
      }
      expect(errors, isEmpty);
    });
  }
}
