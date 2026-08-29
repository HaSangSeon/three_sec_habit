import 'package:flutter/foundation.dart';
import '../core/database/habit_dao.dart';
import '../core/utils/date_util.dart';
import '../models/habit.dart';
import '../models/habit_with_today_status.dart';

import '../core/services/home_widget_service.dart';

/// 습관 상태 관리 프로바이더 (3초 컷 반응성을 위한 낙관적 UI 업데이트 적용)
class HabitProvider extends ChangeNotifier {
  final HabitDao _habitDao;

  List<HabitWithTodayStatus> _habits = [];
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  HabitProvider({HabitDao? habitDao})
      : _habitDao = habitDao ?? HabitDao();

  // Getters
  List<HabitWithTodayStatus> get habits => _habits;
  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;
  int get completedCount => _habits.where((h) => h.isCompletedToday).length;
  int get totalCount => _habits.length;
  double get progressRate => totalCount > 0 ? (completedCount / totalCount) : 0.0;
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
    } catch (e) {
      debugPrint('Error loading habits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 습관 체크 토글 (0ms 즉각 반응 낙관적 UI 업데이트)
  Future<void> toggleHabit(int habitId) async {
    final index = _habits.indexWhere((h) => h.habit.id == habitId);
    if (index == -1) return;

    final target = _habits[index];
    final nextState = !target.isCompletedToday;
    final dateStr = DateUtil.formatDate(_selectedDate);

    // 1. [낙관적 업데이트] 즉시 메모리 상태 변경 후 UI 리빌드 (손맛 극대화)
    final newStreak = nextState
        ? target.currentStreak + 1
        : (target.currentStreak > 0 ? target.currentStreak - 1 : 0);
    final newBest = newStreak > target.bestStreak ? newStreak : target.bestStreak;

    _habits[index] = target.copyWith(
      isCompletedToday: nextState,
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
      );
      HomeWidgetService.updateWidgetData(_habits);
    } catch (e) {
      debugPrint('DB Error during toggle: $e');
      // 오류 발생 시 롤백
      _habits[index] = target;
      notifyListeners();
    }
  }

  /// 습관 추가
  Future<int> addHabit(Habit habit) async {
    final insertedId = await _habitDao.insertHabit(habit);
    await loadHabits();
    return insertedId;
  }

  /// 습관 수정
  Future<void> updateHabit(Habit habit) async {
    await _habitDao.updateHabit(habit);
    await loadHabits();
  }

  /// 습관 삭제
  Future<void> deleteHabit(int habitId) async {
    await _habitDao.deleteHabit(habitId);
    await loadHabits();
  }

  /// 선택 날짜 변경
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    loadHabits(date: date);
  }
}
