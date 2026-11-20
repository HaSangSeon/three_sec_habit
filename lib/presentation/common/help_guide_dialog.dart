import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// 3초 습관 통합 사용 가이드 다이얼로그 (최신 기능 반영 및 프리미엄 헤더 디자인)
class HelpGuideDialog {
  static void show(BuildContext context) {
    final isDark = context.isDarkMode;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: ctx.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: BorderSide(
            color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.2),
            width: 1,
          ),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.84,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. 프리미엄 그라데이션 헤더
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: isDark ? 0.28 : 0.14),
                      AppColors.primaryLight.withValues(alpha: isDark ? 0.10 : 0.05),
                      ctx.surface,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  AppColors.primaryLight.withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome_rounded,
                                  size: 13, color: AppColors.primaryLight),
                              SizedBox(width: 5),
                              Text(
                                '핵심 기능 1분 마스터',
                                style: TextStyle(
                                  color: AppColors.primaryLight,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(ctx),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.10)
                                  : Colors.black.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: ctx.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '3초 습관 이용 가이드',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                        color: ctx.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '작은 3초의 실천이 매일의 꾸준함을 만듭니다.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: ctx.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: ctx.surfaceBorder.withValues(alpha: 0.6),
              ),

              // 2. 스크롤 가능한 핵심 가이드 항목 5가지
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                  child: Column(
                    children: [
                      _buildItem(
                        icon: Icons.record_voice_over_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        title: '말로 챙겨주는 스마트 음성 알림',
                        description:
                            '인기 추천 습관이나 아이콘을 고르면 "물 마실 시간이에요!", "약 챙겨 드세요!" 같은 한국어 음성이 자동 설정되며, 조용한 곳에서는 기본음으로 바꿀 수 있어요.',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _buildItem(
                        icon: Icons.widgets_rounded,
                        iconColor: const Color(0xFF0EA5E9),
                        title: '앱 안 켜고 바탕화면 위젯에서 3초 체크',
                        description:
                            '[설정 → 바탕화면 위젯]에서 4x2 또는 2x2 위젯을 홈 화면에 추가해 보세요. 앱을 열지 않고도 원터치 완료(✓)와 +1 카운트가 바로 기록됩니다.',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _buildItem(
                        icon: Icons.repeat_rounded,
                        iconColor: const Color(0xFF3B82F6),
                        title: '한 번만 등록하면 요일마다 자동 반복',
                        description:
                            '매일 새로 등록할 필요 없이 매일·특정 요일·주 N회 주기에 맞춰 오늘 목록에 자동으로 나타나고, 완료 시 오늘 남은 알림은 조용히 건너뜁니다.',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _buildItem(
                        icon: Icons.check_circle_rounded,
                        iconColor: const Color(0xFF10B981),
                        title: '횟수 누적(+1) & 실수해도 바로 되돌리기',
                        description:
                            '물 8잔, 식후 약 3회처럼 목표 횟수를 정해 +1씩 채우거나, 잘못 체크했을 때는 한 번 더 눌러 간편하게 되돌릴 수 있어요.',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _buildItem(
                        icon: Icons.calendar_month_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        title: '달력 소급 체크 & 안전한 백업/복원',
                        description:
                            '상단 달력(📅)을 눌러 어제 깜빡한 체크를 채워 넣을 수 있고, 설정의 [데이터 백업]으로 휴대폰 교체 시에도 기록을 그대로 옮길 수 있어요.',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),

              // 3. 하단 확인 버튼
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                decoration: BoxDecoration(
                  color: ctx.surface,
                  border: Border(
                    top: BorderSide(color: ctx.surfaceBorder, width: 0.8),
                  ),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(26)),
                ),
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '이해했어요!',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
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
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
          width: 0.9,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: isDark
                        ? const Color(0xFFF1F5F9)
                        : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.2,
                    height: 1.42,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
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
