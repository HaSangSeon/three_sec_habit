import 'package:flutter_test/flutter_test.dart';
import 'package:three_sec_habit/core/utils/streak_calculator.dart';
import 'package:three_sec_habit/models/habit.dart';

void main() {
  group('StreakCalculator 테스트', () {
    test('1. 매일(daily) 습관 - 오늘과 어제 연속 달성 시 스트릭 계산', () {
      final habit = Habit(
        id: 1,
        title: '매일 물 마시기',
        repeatType: RepeatType.daily,
        createdAt: '2026-08-01T00:00:00.000',
      );

      final completedDates = {
        '2026-08-27',
        '2026-08-28',
        '2026-08-29',
      };

      final refDate = DateTime(2026, 8, 29);
      final result = StreakCalculator.calculate(
        habit: habit,
        completedDates: completedDates,
        referenceDate: refDate,
      );

      expect(result.currentStreak, 3);
      expect(result.bestStreak, 3);
      expect(result.totalCount, 3);
    });

    test('2. 매일(daily) 습관 - 오늘 아직 안 했지만 어제까지 달성한 경우 스트릭 유지', () {
      final habit = Habit(
        id: 1,
        title: '매일 독서',
        repeatType: RepeatType.daily,
        createdAt: '2026-08-01T00:00:00.000',
      );

      final completedDates = {
        '2026-08-27',
        '2026-08-28',
      };

      final refDate = DateTime(2026, 8, 29); // 오늘(29일) 미체크
      final result = StreakCalculator.calculate(
        habit: habit,
        completedDates: completedDates,
        referenceDate: refDate,
      );

      expect(result.currentStreak, 2);
      expect(result.bestStreak, 2);
    });

    test('3. 매일(daily) 습관 - 어제 놓친 경우 현재 스트릭 0 리셋', () {
      final habit = Habit(
        id: 1,
        title: '매일 운동',
        repeatType: RepeatType.daily,
        createdAt: '2026-08-01T00:00:00.000',
      );

      final completedDates = {
        '2026-08-20',
        '2026-08-21',
        '2026-08-22',
        // 23~28일 놓침
      };

      final refDate = DateTime(2026, 8, 29);
      final result = StreakCalculator.calculate(
        habit: habit,
        completedDates: completedDates,
        referenceDate: refDate,
      );

      expect(result.currentStreak, 0);
      expect(result.bestStreak, 3); // 과거 최고 기록은 3 유지
    });

    test('4. 특정 요일(weeklyDays: 월,수,금) 습관 스트릭 유지 검증', () {
      // 2026-08-24(월), 2026-08-26(수), 2026-08-28(금)
      final habit = Habit(
        id: 2,
        title: '헬스장 가기',
        repeatType: RepeatType.weeklyDays,
        repeatDays: [1, 3, 5], // 월, 수, 금
        createdAt: '2026-08-01T00:00:00.000',
      );

      final completedDates = {
        '2026-08-24', // 월
        '2026-08-26', // 수
        '2026-08-28', // 금
      };

      // 2026-08-29는 토요일 (비예정일) -> 금요일까지 완료했으므로 스트릭 3 유지
      final refDate = DateTime(2026, 8, 29);
      final result = StreakCalculator.calculate(
        habit: habit,
        completedDates: completedDates,
        referenceDate: refDate,
      );

      expect(result.currentStreak, 3);
      expect(result.bestStreak, 3);
    });

    test('5. 주 N회(weeklyCount: 주 2회) 습관 스트릭 검증', () {
      final habit = Habit(
        id: 3,
        title: '주 2회 러닝',
        repeatType: RepeatType.weeklyCount,
        repeatCount: 2,
        createdAt: '2026-08-01T00:00:00.000',
      );

      // 지난주 2회, 이번주 2회 완료
      final completedDates = {
        '2026-08-18', // 지난주 화
        '2026-08-20', // 지난주 목
        '2026-08-25', // 이번주 화
        '2026-08-27', // 이번주 목
      };

      final refDate = DateTime(2026, 8, 29); // 이번주 토
      final result = StreakCalculator.calculate(
        habit: habit,
        completedDates: completedDates,
        referenceDate: refDate,
      );

      expect(result.currentStreak, 2); // 2주 연속 달성
      expect(result.totalCount, 4);
    });
  });
}
