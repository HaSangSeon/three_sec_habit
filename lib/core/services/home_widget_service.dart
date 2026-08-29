import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../constants/app_constants.dart';
import '../database/habit_dao.dart';
import '../utils/date_util.dart';
import '../../models/habit.dart';
import '../../models/habit_with_today_status.dart';

/// 안드로이드 홈 화면 위젯 백그라운드 콜백 핸들러 (앱이 꺼져있을 때 위젯 체크 시 실행)
@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  if (uri == null) return;
  if (uri.scheme == 'habit3sec' && uri.host == 'toggle') {
    final habitIdStr = uri.queryParameters['id'];
    if (habitIdStr != null) {
      final habitId = int.tryParse(habitIdStr);
      if (habitId != null) {
        final dao = HabitDao();
        final todayStr = DateUtil.today();
        final completedIds = await dao.getCompletedHabitIdsForDate(todayStr);
        final isCurrentlyCompleted = completedIds.contains(habitId);

        // 토글 실행
        await dao.toggleCheck(
          habitId: habitId,
          date: todayStr,
          isCompleted: !isCurrentlyCompleted,
        );

        // 위젯 최신 데이터 재동기화
        final habits = await dao.getHabitsWithStatusForDate(DateTime.now());
        await HomeWidgetService.updateWidgetData(habits);
      }
    }
  }
}

/// 안드로이드 홈 화면 위젯 데이터 연동 서비스
class HomeWidgetService {
  HomeWidgetService._();

  static bool _isInitialized = false;

  /// 위젯 초기화 및 백그라운드 콜백 등록
  static Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId(AppConstants.appGroupId);
      await HomeWidget.registerInteractivityCallback(backgroundCallback);
      _isInitialized = true;
    } catch (e) {
      debugPrint('HomeWidget initialize error: $e');
    }
  }

  /// 오늘의 습관 목록을 2x2 및 4x2 네이티브 위젯 SharedPreferences에 동기화
  static Future<void> updateWidgetData(List<HabitWithTodayStatus> habits) async {
    if (!_isInitialized) return;
    try {
      final todayStr = DateUtil.formatForDisplay(DateTime.now());
      final total = habits.length;
      final completed = habits.where((h) => h.isCompletedToday).length;
      final percent = total > 0 ? ((completed / total) * 100).toInt() : 0;

      // 1. 공통 요약 데이터
      await HomeWidget.saveWidgetData<String>('widget_progress_text', '$completed / $total');
      await HomeWidget.saveWidgetData<String>('widget_percent_text', '$percent% 완료');
      await HomeWidget.saveWidgetData<String>('widget_date_str', todayStr);
      await HomeWidget.saveWidgetData<String>(
          'widget_4x2_summary', '$completed / $total 완료 ($percent%)');

      // 2. 2x2 위젯용 상단 습관 (아직 미완료된 첫 번째 습관 우선, 없으면 첫 번째)
      final topHabit = habits.firstWhere(
        (h) => !h.isCompletedToday,
        orElse: () => habits.isNotEmpty
            ? habits.first
            : HabitWithTodayStatus(
                habit: Habit(title: '습관 만들기', id: -1),
                isCompletedToday: false,
              ),
      );

      await HomeWidget.saveWidgetData<String>(
          'widget_top_habit_title', topHabit.habit.title);
      await HomeWidget.saveWidgetData<int>(
          'widget_top_habit_id', topHabit.habit.id ?? -1);
      await HomeWidget.saveWidgetData<bool>(
          'widget_top_habit_done', topHabit.isCompletedToday);

      // 3. 4x2 위젯용 최대 3개 습관 슬롯
      for (int i = 0; i < 3; i++) {
        if (i < habits.length) {
          final h = habits[i];
          await HomeWidget.saveWidgetData<int>('widget_habit_id_$i', h.habit.id ?? -1);
          await HomeWidget.saveWidgetData<String>('widget_habit_title_$i', h.habit.title);
          await HomeWidget.saveWidgetData<bool>('widget_habit_done_$i', h.isCompletedToday);
        } else {
          await HomeWidget.saveWidgetData<int>('widget_habit_id_$i', -1);
          await HomeWidget.saveWidgetData<String>('widget_habit_title_$i', '');
          await HomeWidget.saveWidgetData<bool>('widget_habit_done_$i', false);
        }
      }

      // 4. 네이티브 위젯 화면 갱신 트리거
      await HomeWidget.updateWidget(
        name: AppConstants.appWidgetProvider2x2,
        androidName: AppConstants.appWidgetProvider2x2,
      );
      await HomeWidget.updateWidget(
        name: AppConstants.appWidgetProvider4x2,
        androidName: AppConstants.appWidgetProvider4x2,
      );
    } catch (e) {
      debugPrint('Error updating widget data: $e');
    }
  }
}
