import 'package:flutter/material.dart';

/// 3초 습관 앱의 메인 디자인 컬러 시스템
/// - 미니멀하고 눈이 편안한 딥 다크 테마 기본값
/// - 세련된 바이올렛/퍼플 포인트 컬러
/// - 경쾌한 에메랄드 성공 체크 컬러
class AppColors {
  AppColors._();

  // 포인트 컬러 (바이올렛 계열)
  static const Color primary = Color(0xFF8B5CF6);        // 메인 바이올렛
  static const Color primaryLight = Color(0xFFA78BFA);   // 밝은 바이올렛
  static const Color primaryDark = Color(0xFF6D28D9);    // 딥 바이올렛
  static const Color accent = Color(0xFFC084FC);

  // 체크/성공 컬러
  static const Color success = Color(0xFF10B981);       // 에메랄드 그린
  static const Color successLight = Color(0xFF34D399);

  // 스트릭(불꽃) 컬러
  static const Color fireOrange = Color(0xFFF97316);    // 스트릭 오렌지
  static const Color fireAmber = Color(0xFFFBBF24);

  // 다크 테마 배경 및 표면
  static const Color darkBackground = Color(0xFF0F172A); // 딥 슬레이트 블랙
  static const Color darkSurface = Color(0xFF1E293B);    // 카드 배경
  static const Color darkSurfaceLight = Color(0xFF334155);// 테두리 / 디바이더
  static const Color darkTextPrimary = Color(0xFFF8FAFC);// 화이트 텍스트
  static const Color darkTextSecondary = Color(0xFF94A3B8);// 서브 텍스트
  static const Color darkTextMuted = Color(0xFF64748B);  // 비활성 텍스트

  // 라이트 테마 배경 및 표면
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // 습관 아이콘 추천 컬러 팔레트 (10가지)
  static const List<Color> habitColorPalette = [
    Color(0xFF8B5CF6), // 바이올렛
    Color(0xFF3B82F6), // 블루
    Color(0xFF06B6D4), // 시안
    Color(0xFF10B981), // 에메랄드
    Color(0xFF84CC16), // 라임
    Color(0xFFF59E0B), // 앰버
    Color(0xFFF97316), // 오렌지
    Color(0xFFEF4444), // 레드
    Color(0xFFEC4899), // 핑크
    Color(0xFF6366F1), // 인디고
  ];
}

/// 현재 테마(다크/라이트)에 따라 동적으로 색상을 반환하는 확장 함수
extension ThemeColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  Color get bg => isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
  Color get surface => isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;
  Color get surfaceBorder => isDarkMode ? AppColors.darkSurfaceLight : AppColors.lightSurfaceBorder;
  Color get textPrimary => isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get textSecondary => isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get textMuted => isDarkMode ? AppColors.darkTextMuted : AppColors.lightTextMuted;
}
