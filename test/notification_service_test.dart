import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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

  test('요일별 반복 알림(평일 월~금): 5개 요일 모두 스케줄 날짜가 유효하게 계산되는지 검증', () {
    final now = tz.TZDateTime.now(tz.local);
    final repeatDays = [1, 2, 3, 4, 5]; // 월, 화, 수, 목, 금
    const hour = 8;
    const minute = 30;

    final List<tz.TZDateTime> scheduledDates = [];

    for (final day in repeatDays) {
      int daysUntil = (day - now.weekday) % 7;
      if (daysUntil < 0) daysUntil += 7;

      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      ).add(Duration(days: daysUntil));

      if (daysUntil == 0 && scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 7));
      }

      scheduledDates.add(scheduledDate);
    }

    // 5개 요일 각각에 대해 정확히 5개의 알림 날짜 생성
    expect(scheduledDates.length, 5);
    for (int i = 0; i < 5; i++) {
      expect(scheduledDates[i].weekday, repeatDays[i]);
      expect(scheduledDates[i].hour, 8);
      expect(scheduledDates[i].minute, 30);
      expect(scheduledDates[i].isAfter(now) || scheduledDates[i].isAtSameMomentAs(now), true);
    }
  });

  test('반복 간격 알림: 09:00~21:00 사이 슬롯 계산 검증 (30분 간격: 25개 슬롯 100% 누락 없음)', () {
    const startHour = 9;
    const startMinute = 0;
    const endHour = 21;
    const endMinute = 0;
    const intervalMinutes = 30; // 30분 간격

    final startTotalMin = startHour * 60 + startMinute; // 540
    final endTotalMin = endHour * 60 + endMinute; // 1260

    int currentSlotMin = startTotalMin;
    int slotIdx = 0;
    final List<String> slots = [];

    while (currentSlotMin <= endTotalMin && slotIdx < 50) {
      final hour = currentSlotMin ~/ 60;
      final min = currentSlotMin % 60;
      slots.add('${hour.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}');
      slotIdx++;
      currentSlotMin += intervalMinutes;
    }

    // 09:00부터 21:00까지 30분마다 총 25개 슬롯
    expect(slots.length, 25);
    expect(slots.first, '09:00');
    expect(slots.last, '21:00');
    expect(slots.contains('18:30'), true);
    expect(slots.contains('19:00'), true);
    expect(slots.contains('20:30'), true);
  });

  test('반복 간격 알림: 09:00~21:00 사이 슬롯 계산 검증 (60분 간격: 13개 슬롯)', () {
    const startHour = 9;
    const startMinute = 0;
    const endHour = 21;
    const endMinute = 0;
    const intervalMinutes = 60; // 1시간 간격

    final startTotalMin = startHour * 60 + startMinute;
    final endTotalMin = endHour * 60 + endMinute;

    int currentSlotMin = startTotalMin;
    int slotIdx = 0;
    final List<String> slots = [];

    while (currentSlotMin <= endTotalMin && slotIdx < 50) {
      final hour = currentSlotMin ~/ 60;
      final min = currentSlotMin % 60;
      slots.add('${hour.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}');
      slotIdx++;
      currentSlotMin += intervalMinutes;
    }

    expect(slots.length, 13);
    expect(slots.first, '09:00');
    expect(slots.last, '21:00');
  });

  test('반복주기 검증: 오늘이 월요일(1)일 때 화/목(2,4) 습관은 오늘 알림이 0개이고 화/목에만 스케줄링됨', () {
    // 임의의 월요일 시각 시뮬레이션 (2026-09-07은 월요일)
    final monday = tz.TZDateTime(tz.local, 2026, 9, 7, 10, 0); // 월요일 10:00
    expect(monday.weekday, DateTime.monday);

    final repeatDays = [DateTime.tuesday, DateTime.thursday]; // 화(2), 목(4)
    const hour = 8;
    const minute = 0;

    final List<tz.TZDateTime> scheduledDates = [];

    for (final day in repeatDays) {
      int daysUntil = (day - monday.weekday) % 7;
      if (daysUntil < 0) daysUntil += 7;

      var scheduledDate = tz.TZDateTime(
        tz.local,
        monday.year,
        monday.month,
        monday.day,
        hour,
        minute,
      ).add(Duration(days: daysUntil));

      if (daysUntil == 0 && scheduledDate.isBefore(monday)) {
        scheduledDate = scheduledDate.add(const Duration(days: 7));
      }

      scheduledDates.add(scheduledDate);
    }

    // 결과 검증: 오늘(월요일) 날짜는 단 1개도 없어야 함!
    expect(scheduledDates.any((d) => d.day == monday.day), false);
    // 예약된 날짜는 화요일과 목요일이어야 함!
    expect(scheduledDates[0].weekday, DateTime.tuesday);
    expect(scheduledDates[0].day, 8); // 9월 8일 화요일
    expect(scheduledDates[1].weekday, DateTime.thursday);
    expect(scheduledDates[1].day, 10); // 9월 10일 목요일
  });

  test('완료 상태 검증: 오늘이 화요일인데 이미 완료(isCompletedToday=true)했다면 오늘 알림은 취소되고 다음 주 화요일로 7일 연기됨', () {
    // 2026-09-08은 화요일
    final tuesday = tz.TZDateTime(tz.local, 2026, 9, 8, 7, 0); // 화요일 07:00 (알림 시간 08:00 전)
    expect(tuesday.weekday, DateTime.tuesday);

    const isCompletedToday = true; // 오늘 이미 완료!
    const day = DateTime.tuesday;
    const hour = 8;
    const minute = 0;

    int daysUntil = (day - tuesday.weekday) % 7;
    if (daysUntil < 0) daysUntil += 7;

    var scheduledDate = tz.TZDateTime(
      tz.local,
      tuesday.year,
      tuesday.month,
      tuesday.day,
      hour,
      minute,
    ).add(Duration(days: daysUntil));

    // 오늘이 해당 요일(daysUntil == 0)인데 이미 완료(isCompletedToday)했으므로 다음 주로 7일 연기!
    if (daysUntil == 0 && (isCompletedToday || scheduledDate.isBefore(tuesday))) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    // 오늘(9월 8일)이 아니라 다음 주 화요일(9월 15일)이어야 함!
    expect(scheduledDate.day, 15);
    expect(scheduledDate.weekday, DateTime.tuesday);
    expect(scheduledDate.hour, 8);
  });

  test('반복주기 검증(간격 알림): 오늘이 월요일(1)일 때 화/목(2,4) 1시간 간격 알림은 오늘 슬롯이 0개', () {
    final monday = tz.TZDateTime(tz.local, 2026, 9, 7, 10, 0); // 월요일
    final repeatDays = [DateTime.tuesday, DateTime.thursday]; // 화(2), 목(4)

    const startTotalMin = 9 * 60; // 09:00
    const endTotalMin = 21 * 60; // 21:00
    const intervalMinutes = 60;

    final List<tz.TZDateTime> allSlots = [];

    for (final day in repeatDays) {
      int daysUntil = (day - monday.weekday) % 7;
      if (daysUntil < 0) daysUntil += 7;

      int currentSlotMin = startTotalMin;
      int slotIdx = 0;

      while (currentSlotMin <= endTotalMin && slotIdx < 50) {
        final slotHour = currentSlotMin ~/ 60;
        final slotMin = currentSlotMin % 60;

        var scheduledDate = tz.TZDateTime(
          tz.local,
          monday.year,
          monday.month,
          monday.day,
          slotHour,
          slotMin,
        ).add(Duration(days: daysUntil));

        allSlots.add(scheduledDate);
        slotIdx++;
        currentSlotMin += intervalMinutes;
      }
    }

    // 총 2일 x 13슬롯 = 26개 슬롯
    expect(allSlots.length, 26);
    // 오늘(월요일) 날짜는 단 1개도 없어야 함!
    expect(allSlots.any((d) => d.day == monday.day), false);
    // 모든 슬롯은 화요일(13개) 또는 목요일(13개)이어야 함
    expect(allSlots.where((d) => d.weekday == DateTime.tuesday).length, 13);
    expect(allSlots.where((d) => d.weekday == DateTime.thursday).length, 13);
  });

  test('알림 ID 무충돌 및 32비트 정수 한계 내 안전성 검증 (0~500 서브 ID 슬롯)', () {
    const habitId = 12345;
    final generatedIds = <int>{};

    for (int subId = 0; subId < 500; subId++) {
      final id = (habitId * 1000 + subId).abs() % 2147483647;
      expect(id >= 0, true);
      expect(id < 2147483647, true);
      generatedIds.add(id);
    }

    // 500개 ID가 중복 없이 1:1로 고유해야 함
    expect(generatedIds.length, 500);
  });
}

