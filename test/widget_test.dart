import 'package:flutter_test/flutter_test.dart';
import 'package:three_sec_habit/core/constants/app_icons.dart';
import 'package:three_sec_habit/providers/theme_provider.dart';

void main() {
  group('ThemeProvider 및 AppIcons 유틸리티 테스트', () {
    test('1. ThemeProvider 다크/라이트 테마 전환 검증', () {
      final themeProvider = ThemeProvider();
      expect(themeProvider.isDarkMode, isFalse);

      themeProvider.toggleTheme(true);
      expect(themeProvider.isDarkMode, isTrue);

      themeProvider.toggleTheme(false);
      expect(themeProvider.isDarkMode, isFalse);
    });

    test('2. AppIcons 15개 아이콘 목록 및 기본 아이콘 매핑 검증', () {
      expect(AppIcons.icons.length, 15);
      expect(AppIcons.getIcon('water_drop'), isNotNull);
      expect(AppIcons.getIcon('unknown_icon_name'), isNotNull);
    });
  });
}
