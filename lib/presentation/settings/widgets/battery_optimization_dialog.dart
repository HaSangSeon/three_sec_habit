import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// 기기별 정시 알림 수신 및 배터리 절전 해제 안내 다이얼로그
class BatteryOptimizationDialog extends StatelessWidget {
  const BatteryOptimizationDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const BatteryOptimizationDialog(),
    );
  }

  static Widget _buildGuideRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    final isDark = context.isDarkMode;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.surfaceBorder.withValues(alpha: 0.8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.14),
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
                    color: context.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 12.2,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    const accent = Color(0xFFF59E0B);

    return Dialog(
      backgroundColor: context.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: BorderSide(
          color: accent.withValues(alpha: isDark ? 0.35 : 0.22),
          width: 1,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. 프리미엄 앰버 그라데이션 헤더
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: isDark ? 0.26 : 0.14),
                    accent.withValues(alpha: isDark ? 0.08 : 0.04),
                    context.surface,
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
                            horizontal: 10, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt_rounded, size: 13, color: accent),
                            SizedBox(width: 4),
                            Text(
                              '알림 지연 해결 가이드',
                              style: TextStyle(
                                color: accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
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
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '알림이 안 오거나 늦게 올 때',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 18.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '휴대폰 절전 기능 때문에 화면이 꺼져 있을 때 알림이 늦을 수 있어요. 아래 1가지만 확인하면 제시간에 울립니다.',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 12.2,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: context.surfaceBorder.withValues(alpha: 0.6),
            ),

            // 2. 기기별 안내 카드 리스트
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                child: Column(
                  children: [
                    _buildGuideRow(
                      context,
                      icon: Icons.phone_android_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      title: '삼성 갤럭시 휴대폰',
                      description:
                          '휴대폰 [설정] → [애플리케이션] → [3초 습관] → [배터리]를 누른 뒤 "제한 없음"으로 바꿔주세요. (절전 모드 방지)',
                    ),
                    const SizedBox(height: 10),
                    _buildGuideRow(
                      context,
                      icon: Icons.battery_saver_rounded,
                      iconColor: accent,
                      title: '샤오미 · 홍미 · 보급형 기기',
                      description:
                          '[보안] 앱 → [권한] → [자동 시작]에서 3초 습관을 켜고, 배터리 절약 설정을 "제한 없음"으로 선택해 주세요.',
                    ),
                    const SizedBox(height: 10),
                    _buildGuideRow(
                      context,
                      icon: Icons.notifications_active_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: '알림 소리·무음 상태 확인',
                      description:
                          '휴대폰 [설정 → 애플리케이션 → 3초 습관 → 알림]이 켜져 있는지, 기기가 방해 금지 모드가 아닌지 확인해 주세요.',
                    ),
                  ],
                ),
              ),
            ),

            // 3. 하단 풀와이드 확인 버튼
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
              decoration: BoxDecoration(
                color: context.surface,
                border: Border(
                  top: BorderSide(color: context.surfaceBorder, width: 0.8),
                ),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(26)),
              ),
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '확인했어요',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
