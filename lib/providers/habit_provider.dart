import 'package:flutter/foundation.dart';
import '../core/database/habit_dao.dart';
import '../core/services/home_widget_service.dart';
import '../core/services/notification_service.dart';
import '../core/utils/date_util.dart';
import '../models/habit.dart';
import '../models/habit_with_today_status.dart';

/// 습관 상태 관리 프로바이더 (3초 컷 반응성을 위한 낙관적 UI 업데이트 적용)
class HabitProvider extends ChangeNotifier {
  final HabitDao _habitDao;

  List<HabitWithTodayStatus> _habits = [];
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  HabitProvider({HabitDao? habitDao}) : _habitDao = habitDao ?? HabitDao();

  // Getters
  List<HabitWithTodayStatus> get habits => _habits; // 전체 습관
  List<HabitWithTodayStatus> get todayHabits =>
      _habits.where((h) => h.isScheduledToday || h.isCompletedToday).toList();
  List<HabitWithTodayStatus> get restHabits =>
      _habits.where((h) => h.isRestDay).toList();
  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;
  int get completedCount => todayHabits.where((h) => h.isCompletedToday).length;
  int get totalCount => todayHabits.length;
  double get progressRate =>
      totalCount > 0 ? (completedCount / totalCount) : 0.0;
  bool get isAllCompleted => totalCount > 0 && completedCount == totalCount;

  /// 초기 습관 목록 로드 (앱 실행 또는 날짜 변경 시)
  Future<void> loadHabits({DateTime? date}) async {
    _selectedDate = date ?? _selectedDate;
    if (_habits.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _habits = await _habitDao.getHabitsWithStatusForDate(_selectedDate);
      // 홈 위젯 동기화
      HomeWidgetService.updateWidgetData(_habits);
      // 스마트 알림 일괄 최신화
      NotificationService.rescheduleAllHabits(_habits);
    } catch (e) {
      debugPrint('Error loading habits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 습관 체크 토글 (단순 체크형 및 카운트형 지원)
  Future<void> toggleHabit(int habitId) async {
    final index = _habits.indexWhere((h) => h.habit.id == habitId);
    if (index == -1) return;

    final target = _habits[index];
    final dateStr = DateUtil.formatDate(_selectedDate);

    if (target.habit.habitType == HabitType.count) {
      // 카운트형 습관: 이미 목표 달성 상태면 1회 감소(완료 해제), 아니면 +1 증가
      if (target.isCompletedToday) {
        await decrementHabitCount(habitId, step: 1);
      } else {
        await incrementHabitCount(habitId, step: 1);
      }
      return;
    }

    // 단순 체크형 습관
    final nextState = !target.isCompletedToday;
    final newTodayCount = nextState ? 1 : 0;
    final newStreak = nextState
        ? target.currentStreak + 1
        : (target.currentStreak > 0 ? target.currentStreak - 1 : 0);
    final newBest =
        newStreak > target.bestStreak ? newStreak : target.bestStreak;

    // 1. [낙관적 업데이트] 즉시 메모리 상태 변경
    _habits[index] = target.copyWith(
      isCompletedToday: nextState,
      todayCount: newTodayCount,
      currentStreak: newStreak,
      bestStreak: newBest,
    );
    notifyListeners();

    // 2. 백그라운드에서 SQLite 영구 저장 및 위젯 동기화
    try {
      await _habitDao.toggleCheck(
        habitId: habitId,
        date: dateStr,
        isCompleted: nextState,
        targetCount: 1,
      );
      await NotificationService.scheduleHabitReminder(
        target.habit,
        isCompletedToday: nextState,
      );
      HomeWidgetService.updateWidgetData(_habits);
    } catch (e) {
      debugPrint('DB Error during toggle: $e');
      _habits[index] = target;
      notifyListeners();
    }
  }

  /// 카운트형 습관 횟수 증가 (+1 등)
  Future<void> incrementHabitCount(int habitId, {int step = 1}) async {
    final index = _habits.indexWhere((h) => h.habit.id == habitId);
    if (index == -1) return;

    final target = _habits[index];
    final dateStr = DateUtil.formatDate(_selectedDate);
    final newCount = target.todayCount + step;
    final targetCount = target.habit.targetCount;
    final isNowCompleted = newCount >= targetCount;
    final wasCompleted = target.isCompletedToday;

    int newStreak = target.currentStreak;
    if (!wasCompleted && isNowCompleted) {
      newStreak += 1;
    }
    final newBest =
        newStreak > target.bestStreak ? newStreak : target.bestStreak;

    // 낙관적 업데이트
    _habits[index] = target.copyWith(
      todayCount: newCount,
      isCompletedToday: isNowCompleted,
      currentStreak: newStreak,
      bestStreak: newBest,
    );
    notifyListeners();

    try {
      await _habitDao.setHabitCount(
        habitId: habitId,
        date: dateStr,
        count: newCount,
        targetCount: targetCount,
      );
      await NotificationService.scheduleHabitReminder(
        target.habit,
        isCompletedToday: isNowCompleted,
      );
      HomeWidgetService.updateWidgetData(_habits);
    } catch (e) {
      debugPrint('DB Error during increment: $e');
      _habits[index] = target;
      notifyListeners();
    }
  }

  /// 카운트형 습관 횟수 감소 (-1 등)
  Future<void> decrementHabitCount(int habitId, {int step = 1}) async {
    final index = _habits.indexWhere((h) => h.habit.id == habitId);
    if (index == -1) return;

    final target = _habits[index];
    if (target.todayCount <= 0) return;

    final dateStr = DateUtil.formatDate(_selectedDate);
    final newCount = (target.todayCount - step).clamp(0, 9999);
    final targetCount = target.habit.targetCount;
    final isNowCompleted = newCount >= targetCount;
    final wasCompleted = target.isCompletedToday;

    int newStreak = target.currentStreak;
    if (wasCompleted && !isNowCompleted) {
      newStreak = (newStreak > 0) ? newStreak - 1 : 0;
    }

    _habits[index] = target.copyWith(
      todayCount: newCount,
      isCompletedToday: isNowCompleted,
      currentStreak: newStreak,
    );
    notifyListeners();

    try {
      await _habitDao.setHabitCount(
        habitId: habitId,
        date: dateStr,
        count: newCount,
        targetCount: targetCount,
      );
      await NotificationService.scheduleHabitReminder(
        target.habit,
        isCompletedToday: isNowCompleted,
      );
      HomeWidgetService.updateWidgetData(_habits);
    } catch (e) {
      debugPrint('DB Error during decrement: $e');
      _habits[index] = target;
      notifyListeners();
    }
  }

  /// 카운트형 습관 횟수 임의 설정
  Future<void> setHabitCount(int habitId, int count) async {
    final index = _habits.indexWhere((h) => h.habit.id == habitId);
    if (index == -1) return;

    final target = _habits[index];
    final dateStr = DateUtil.formatDate(_selectedDate);
    final safeCount = count.clamp(0, 9999);
    final targetCount = target.habit.targetCount;
    final isNowCompleted = safeCount >= targetCount;
    final wasCompleted = target.isCompletedToday;

    int newStreak = target.currentStreak;
    if (!wasCompleted && isNowCompleted) {
      newStreak += 1;
    } else if (wasCompleted && !isNowCompleted) {
      newStreak = (newStreak > 0) ? newStreak - 1 : 0;
    }
    final newBest =
        newStreak > target.bestStreak ? newStreak : target.bestStreak;

    _habits[index] = target.copyWith(
      todayCount: safeCount,
      isCompletedToday: isNowCompleted,
      currentStreak: newStreak,
      bestStreak: newBest,
    );
    notifyListeners();

    try {
      await _habitDao.setHabitCount(
        habitId: habitId,
        date: dateStr,
        count: safeCount,
        targetCount: targetCount,
      );
      await NotificationService.scheduleHabitReminder(
        target.habit,
        isCompletedToday: isNowCompleted,
      );
      HomeWidgetService.updateWidgetData(_habits);
    } catch (e) {
      debugPrint('DB Error during setHabitCount: $e');
      _habits[index] = target;
      notifyListeners();
    }
  }

  /// 습관 추가
  Future<int> addHabit(Habit habit) async {
    final insertedId = await _habitDao.insertHabit(habit);
    final createdHabit = habit.copyWith(id: insertedId);
    await NotificationService.scheduleHabitReminder(createdHabit);
    await loadHabits();
    return insertedId;
  }

  /// 습관 수정
  Future<void> updateHabit(Habit habit) async {
    await _habitDao.updateHabit(habit);
    await NotificationService.scheduleHabitReminder(habit);
    await loadHabits();
  }

  /// 습관 삭제
  Future<void> deleteHabit(int habitId) async {
    await NotificationService.cancelHabitReminder(habitId);
    await _habitDao.deleteHabit(habitId);
    await loadHabits();
  }

  /// 선택 날짜 변경
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    loadHabits(date: date);
  }
}
