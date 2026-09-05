import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../database/habit_dao.dart';
import '../utils/date_util.dart';
import 'notification_service.dart';
import '../../models/habit.dart';
import '../../models/habit_with_today_status.dart';

/// 안드로이드 홈 화면 위젯 백그라운드 콜백 핸들러 (앱이 꺼져있거나 백그라운드일 때 위젯 체크 시 실행)
@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  if (uri == null) return;
  WidgetsFlutterBinding.ensureInitialized();
  await HomeWidget.setAppGroupId(AppConstants.appGroupId);
  debugPrint('⚡ [HomeWidget] backgroundCallback received URI: $uri');

  if (uri.scheme == 'habit3sec' && uri.host == 'toggle') {
    // path segments (/123) 또는 query parameters (?id=123) 지원
    final habitIdStr = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.first
        : uri.queryParameters['id'];

    if (habitIdStr != null) {
      final habitId = int.tryParse(habitIdStr);
      if (habitId != null) {
        final dao = HabitDao();
        final todayStr = DateUtil.today();
        final habit = await dao.getHabitById(habitId);

        if (habit != null && habit.habitType == HabitType.count) {
          final log = await dao.getHabitLogForDate(habitId, todayStr);
          final currentCount = log?.count ?? 0;
          final nextCount =
              currentCount >= habit.targetCount ? 0 : currentCount + 1;
          await dao.setHabitCount(
            habitId: habitId,
            date: todayStr,
            count: nextCount,
            targetCount: habit.targetCount,
          );
          if (habit.reminderEnabled) {
            await NotificationService.scheduleHabitReminder(
              habit,
              isCompletedToday: nextCount >= habit.targetCount,
            );
          }
        } else if (habit != null) {
          final completedIds = await dao.getCompletedHabitIdsForDate(todayStr);
          final isCurrentlyCompleted = completedIds.contains(habitId);

          await dao.toggleCheck(
            habitId: habitId,
            date: todayStr,
            isCompleted: !isCurrentlyCompleted,
          );
          if (habit.reminderEnabled) {
            await NotificationService.scheduleHabitReminder(
              habit,
              isCompletedToday: !isCurrentlyCompleted,
            );
          }
        }

        // 위젯 최신 데이터 재동기화
        final habits = await dao.getHabitsWithStatusForDate(DateTime.now());
        await HomeWidgetService.updateWidgetData(habits);
        debugPrint('⚡ [HomeWidget] Habit ID $habitId toggled successfully in background.');
      }
    }
  }
}

/// 안드로이드 홈 화면 위젯 데이터 연동 서비스
class HomeWidgetService {
  HomeWidgetService._();

  /// 위젯 초기화 및 백그라운드 콜백 등록
  static Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId(AppConstants.appGroupId);
      await HomeWidget.registerInteractivityCallback(backgroundCallback);
      debugPrint('⚡ [HomeWidget] Initialized successfully');
    } catch (e) {
      debugPrint('HomeWidget initialize error: $e');
    }
  }

  /// 4x2 체크리스트 위젯을 바탕화면에 원클릭으로 핀 추가
  static Future<bool> pinWidget4x2() async {
    try {
      final isSupported = await HomeWidget.isRequestPinWidgetSupported() ?? false;
      if (!isSupported) return false;
      await HomeWidget.requestPinWidget(
        androidName: AppConstants.appWidgetProvider4x2,
        qualifiedAndroidName:
            'com.hasangseon.three_sec_habit.${AppConstants.appWidgetProvider4x2}',
      );
      return true;
    } catch (e) {
      debugPrint('Error pinning 4x2 widget: $e');
      return false;
    }
  }

  /// 2x2 대시보드 위젯을 바탕화면에 원클릭으로 핀 추가
  static Future<bool> pinWidget2x2() async {
    try {
      final isSupported = await HomeWidget.isRequestPinWidgetSupported() ?? false;
      if (!isSupported) return false;
      await HomeWidget.requestPinWidget(
        androidName: AppConstants.appWidgetProvider2x2,
        qualifiedAndroidName:
            'com.hasangseon.three_sec_habit.${AppConstants.appWidgetProvider2x2}',
      );
      return true;
    } catch (e) {
      debugPrint('Error pinning 2x2 widget: $e');
      return false;
    }
  }

  /// 앱 테마(라이트/다크/시스템)를 네이티브 위젯에 실시간 동기화
  static Future<void> updateThemeMode(ThemeMode mode) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await HomeWidget.setAppGroupId(AppConstants.appGroupId);
      final modeStr = switch (mode) {
        ThemeMode.dark => 'dark',
        ThemeMode.light => 'light',
        ThemeMode.system => 'system',
      };
      await HomeWidget.saveWidgetData<String>('widget_theme_mode', modeStr);
      await HomeWidget.updateWidget(
        name: AppConstants.appWidgetProvider2x2,
        androidName: AppConstants.appWidgetProvider2x2,
        qualifiedAndroidName:
            'com.hasangseon.three_sec_habit.${AppConstants.appWidgetProvider2x2}',
      );
      await HomeWidget.updateWidget(
        name: AppConstants.appWidgetProvider4x2,
        androidName: AppConstants.appWidgetProvider4x2,
        qualifiedAndroidName:
            'com.hasangseon.three_sec_habit.${AppConstants.appWidgetProvider4x2}',
      );
    } catch (e) {
      debugPrint('Error updating widget theme mode: $e');
    }
  }

  /// 오늘의 습관 목록을 2x2 및 4x2 네이티브 위젯 SharedPreferences에 동기화
  static Future<void> updateWidgetData(List<HabitWithTodayStatus> habits) async {
    try {
      await HomeWidget.setAppGroupId(AppConstants.appGroupId);
      final scheduledHabits =
          habits.where((h) => h.isScheduledToday).toList();
      final activeList = scheduledHabits.isNotEmpty ? scheduledHabits : habits;

      final todayStr = DateUtil.formatForDisplay(DateTime.now());
      final total = activeList.length;
      final completed = activeList.where((h) => h.isCompletedToday).length;
      final percent = total > 0 ? ((completed / total) * 100).toInt() : 0;

      // 1. 공통 요약 데이터
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('user_theme_mode') ?? 'system';
      await HomeWidget.saveWidgetData<String>('widget_theme_mode', savedTheme);

      await HomeWidget.saveWidgetData<String>(
          'widget_progress_text', '$completed / $total');
      await HomeWidget.saveWidgetData<String>(
          'widget_percent_text', '$percent% 완료');
      await HomeWidget.saveWidgetData<String>('widget_date_str', todayStr);
      await HomeWidget.saveWidgetData<String>(
          'widget_4x2_summary', '$completed / $total 완료 ($percent%)');

      // 2. 2x2 위젯용 상단 습관
      final topHabit = activeList.firstWhere(
        (h) => !h.isCompletedToday,
        orElse: () => activeList.isNotEmpty
            ? activeList.first
            : HabitWithTodayStatus(
                habit: Habit(title: '습관 만들기', id: -1),
                isCompletedToday: false,
              ),
      );

      final topTitle = _formatHabitTitle(topHabit);
      final topBtnText = _formatHabitBtnText(topHabit);

      await HomeWidget.saveWidgetData<String>(
          'widget_top_habit_title', topTitle);
      await HomeWidget.saveWidgetData<String>(
          'widget_top_habit_btn_text', topBtnText);
      await HomeWidget.saveWidgetData<int>(
          'widget_top_habit_id', topHabit.habit.id ?? -1);
      await HomeWidget.saveWidgetData<bool>(
          'widget_top_habit_done', topHabit.isCompletedToday);

      // 3. 4x2 위젯: 전체 습관 JSON 직렬화 (앱 내 원래 순서 100% 그대로 유지)
      final displayList = activeList;

      final habitsJsonList = displayList.map((h) => {
        'id': h.habit.id ?? -1,
        'title': _formatHabitTitle(h),
        'btnText': _formatHabitBtnText(h),
        'isDone': h.isCompletedToday,
      }).toList();

      await HomeWidget.saveWidgetData<String>(
          'widget_habits_json', jsonEncode(habitsJsonList));

      // 4x2 위젯 슬롯 동기화 (최대 4개)
      for (int i = 0; i < 4; i++) {
        if (i < displayList.length) {
          final h = displayList[i];
          await HomeWidget.saveWidgetData<int>(
              'widget_habit_id_$i', h.habit.id ?? -1);
          await HomeWidget.saveWidgetData<String>(
              'widget_habit_title_$i', _formatHabitTitle(h));
          await HomeWidget.saveWidgetData<String>(
              'widget_habit_btn_text_$i', _formatHabitBtnText(h));
          await HomeWidget.saveWidgetData<bool>(
              'widget_habit_done_$i', h.isCompletedToday);
        } else {
          await HomeWidget.saveWidgetData<int>('widget_habit_id_$i', -1);
          await HomeWidget.saveWidgetData<String>('widget_habit_title_$i', '');
          await HomeWidget.saveWidgetData<String>('widget_habit_btn_text_$i', '○');
          await HomeWidget.saveWidgetData<bool>('widget_habit_done_$i', false);
        }
      }

      // 4. 네이티브 위젯 화면 갱신 트리거
      await HomeWidget.updateWidget(
        name: AppConstants.appWidgetProvider2x2,
        androidName: AppConstants.appWidgetProvider2x2,
        qualifiedAndroidName:
            'com.hasangseon.three_sec_habit.${AppConstants.appWidgetProvider2x2}',
      );
      await HomeWidget.updateWidget(
        name: AppConstants.appWidgetProvider4x2,
        androidName: AppConstants.appWidgetProvider4x2,
        qualifiedAndroidName:
            'com.hasangseon.three_sec_habit.${AppConstants.appWidgetProvider4x2}',
      );
    } catch (e) {
      debugPrint('Error updating widget data: $e');
    }
  }

  static String _formatHabitTitle(HabitWithTodayStatus h) {
    if (h.habit.habitType == HabitType.count && h.habit.targetCount > 1) {
      final unitStr = h.habit.unit.isNotEmpty ? h.habit.unit : '회';
      return '${h.habit.title} (${h.todayCount}/${h.habit.targetCount}$unitStr)';
    }
    return h.habit.title;
  }

  static String _formatHabitBtnText(HabitWithTodayStatus h) {
    if (h.isCompletedToday) {
      return '✓';
    } else if (h.habit.habitType == HabitType.count &&
        h.habit.targetCount > 1) {
      return '+1';
    }
    return '○';
  }
}
