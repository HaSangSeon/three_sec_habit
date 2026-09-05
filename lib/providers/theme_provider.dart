import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../core/services/home_widget_service.dart';

/// 앱의 다크모드/라이트모드 테마 관리 프로바이더
class ThemeProvider extends ChangeNotifier {
  static const String _prefThemeKey = 'user_theme_mode';
  ThemeMode _themeMode = ThemeMode.light; // 기본값: 라이트모드

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_prefThemeKey);
      if (savedMode != null) {
        _themeMode = switch (savedMode) {
          'dark' => ThemeMode.dark,
          'light' => ThemeMode.light,
          _ => ThemeMode.system,
        };
        notifyListeners();
        HomeWidgetService.updateThemeMode(_themeMode);
      }
    } catch (_) {}
  }

  void toggleTheme(bool isDark) {
    setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    _saveThemeToPrefs(mode);
    HomeWidgetService.updateThemeMode(mode);
  }

  Future<void> _saveThemeToPrefs(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeStr = switch (mode) {
        ThemeMode.dark => 'dark',
        ThemeMode.light => 'light',
        ThemeMode.system => 'system',
      };
      await prefs.setString(_prefThemeKey, modeStr);
    } catch (_) {}
  }

  /// 다크 테마 데이터
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: Color(0xFFEF4444),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkSurfaceLight, width: 1),
        ),
      ),
    );
  }

  /// 라이트 테마 데이터
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        error: Color(0xFFEF4444),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightSurfaceBorder, width: 1),
        ),
      ),
    );
  }
}
