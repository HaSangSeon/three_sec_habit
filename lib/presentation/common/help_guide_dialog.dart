import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// 3초 습관 통합 사용 가이드 다이얼로그
class HelpGuideDialog {
  static void show(BuildContext context) {
    final isDark = context.isDarkMode;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 타이틀 바
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.lightbulb_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '3초 습관 이용 가이드',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 1. 습관 자동 반복
              _buildItem(
                icon: Icons.repeat_rounded,
                iconColor: const Color(0xFF3B82F6),
                title: '습관은 매일 등록하는 게 아니에요!',
                description: '한 번 등록해 두면 설정한 요일(매일, 평일 등)마다 오늘 할 일 목록에 자동으로 나타납니다.',
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              // 2. 3초 실천 & 체크
              _buildItem(
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF10B981),
                title: '매일 실천하고 체크(✅)하기',
                description: '3초 안에 작게 시작하고 체크하면 연속 달성일(스트릭)과 잔디 기록이 차곡차곡 쌓입니다.',
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              // 3. 달력 활용법
              _buildItem(
                icon: Icons.calendar_month_rounded,
                iconColor: const Color(0xFF8B5CF6),
                title: '달력(📅)으로 과거 기록 관리',
                description: '상단 달력을 눌러 과거 날짜의 실천 상태를 확인하거나 깜빡 잊은 체크를 소급해서 완료할 수 있습니다.',
                isDark: isDark,
              ),
              const SizedBox(height: 20),

              // 확인 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '이해했어요!',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
