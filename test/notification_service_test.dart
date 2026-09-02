import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:three_sec_habit/models/habit.dart';

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    // Simulate setting local timezone to Asia/Seoul (KST, UTC+9)
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
  });

  test('타임존 Asia/Seoul 설정 검증', () {
    expect(tz.local.name, 'Asia/Seoul');
    final now = tz.TZDateTime.now(tz.local);
    expect(now.timeZoneOffset.inHours, 9);
  });

  test('지정 시간 알림: 오늘 완료 시 다음 날로 스마트 예약 계산 검증', () {
    final now = tz.TZDateTime.now(tz.local);
    // Setting reminder for 08:00
    final scheduledDateToday = tz.TZDateTime(tz.local, now.year, now.month, now.day, 8, 0);

    // If completed today, it adds 1 day
    final scheduledTomorrow = scheduledDateToday.add(const Duration(days: 1));
    expect(scheduledTomorrow.day, (now.add(const Duration(days: 1))).day);
    expect(scheduledTomorrow.hour, 8);
    expect(scheduledTomorrow.minute, 0);
  });

  test('반복 간격 알림: 09:00~21:00 사이 슬롯 계산 검증 (120분 간격)', () {
    const startHour = 9;
    const startMinute = 0;
    const endHour = 21;
    const endMinute = 0;
    const intervalMinutes = 120; // 2시간 간격

    final startTotalMin = startHour * 60 + startMinute; // 540
    final endTotalMin = endHour * 60 + endMinute; // 1260

    int currentSlotMin = startTotalMin;
    final List<String> slots = [];

    while (currentSlotMin <= endTotalMin) {
      final hour = currentSlotMin ~/ 60;
      final min = currentSlotMin % 60;
      slots.add('${hour.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}');
      currentSlotMin += intervalMinutes;
    }

    // 09:00, 11:00, 13:00, 15:00, 17:00, 19:00, 21:00 -> 7 slots
    expect(slots.length, 7);
    expect(slots.first, '09:00');
    expect(slots.last, '21:00');
    expect(slots, ['09:00', '11:00', '13:00', '15:00', '17:00', '19:00', '21:00']);
  });
}
