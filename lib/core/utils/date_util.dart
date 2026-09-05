import 'package:intl/intl.dart';

/// 날짜 계산 및 포맷 유틸리티
class DateUtil {
  DateUtil._();

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  /// DateTime -> 'yyyy-MM-dd'
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// 오늘 날짜 문자열 ('yyyy-MM-dd')
  static String today() {
    return formatDate(DateTime.now());
  }

  /// 'yyyy-MM-dd' -> DateTime
  static DateTime parseDate(String dateStr) {
    return _dateFormat.parse(dateStr);
  }

  /// 표시용 날짜 (예: 8월 29일 (토))
  static String formatForDisplay(DateTime date) {
    const days = ['', '월', '화', '수', '목', '금', '토', '일'];
    return '${date.month}월 ${date.day}일 (${days[date.weekday]})';
  }

  /// 월 표시용 (예: 2026년 8월)
  static String formatMonth(DateTime date) {
    return '${date.year}년 ${date.month}월';
  }

  /// 시간 표시용 (TimeOfDay 또는 String -> '07:30')
  static String formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// 주어진 날짜가 오늘인지 확인
  static bool isToday(String dateStr) {
    return dateStr == today();
  }

  /// 두 날짜가 같은 날(연-월-일)인지 확인
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 요일 번호 (1: 월요일 ~ 7: 일요일)
  static int getWeekday(DateTime date) {
    return date.weekday;
  }

  /// 요일 한글 이름 (1 -> '월', 7 -> '일')
  static String getWeekdayKorean(int weekday) {
    const days = ['', '월', '화', '수', '목', '금', '토', '일'];
    if (weekday >= 1 && weekday <= 7) return days[weekday];
    return '';
  }

  /// N일 전 날짜 문자열 구하기
  static String daysAgo(int days) {
    return formatDate(DateTime.now().subtract(Duration(days: days)));
  }

  /// 날짜 범위 생성 (startDate 부터 endDate 까지의 yyyy-MM-dd 목록)
  static List<String> generateDateRange(DateTime start, DateTime end) {
    final list = <String>[];
    DateTime current = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);

    while (!current.isAfter(normalizedEnd)) {
      list.add(formatDate(current));
      current = current.add(const Duration(days: 1));
    }
    return list;
  }
}
