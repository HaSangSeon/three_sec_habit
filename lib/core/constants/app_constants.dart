/// 앱 전역에서 사용하는 데이터베이스 및 시스템 상수
class AppConstants {
  AppConstants._();

  // 앱 이름
  static const String appName = '3초 습관';

  // 데이터베이스 설정
  static const String dbName = 'three_sec_habit.db';
  static const int dbVersion = 1;

  // 테이블명
  static const String tableHabits = 'habits';
  static const String tableHabitLogs = 'habit_logs';

  // 안드로이드 홈 위젯 키
  static const String appWidgetProvider2x2 = 'HabitWidgetProvider2x2';
  static const String appWidgetProvider4x2 = 'HabitWidgetProvider4x2';
  static const String appGroupId = 'group.com.hasangseon.three_sec_habit';
  static const String widgetDataKeyHabits = 'widget_habits_json';
  static const String widgetDataKeyDate = 'widget_date_str';

  // AdMob 테스트 광고 ID (Google 공식 테스트 ID)
  // 안드로이드 배너 테스트 ID
  static const String testBannerAdId = 'ca-app-pub-3940256099942544/6300978111';
  // 안드로이드 전면 광고 테스트 ID
  static const String testInterstitialAdId = 'ca-app-pub-3940256099942544/1033173712';
}
