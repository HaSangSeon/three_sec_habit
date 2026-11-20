import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// 개인정보 처리방침 안내 다이얼로그
class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const PrivacyPolicyDialog(),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String body,
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
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
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
    const accent = Color(0xFF10B981);

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
            // 1. 프리미엄 에메랄드 그라데이션 헤더
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: isDark ? 0.24 : 0.13),
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
                            Icon(Icons.verified_user_rounded,
                                size: 13, color: accent),
                            SizedBox(width: 5),
                            Text(
                              '100% 기기 내 안전 저장',
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
                        onTap: () => Navigator.of(context).pop(),
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
                    '개인정보 처리방침',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 19,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '회원가입과 서버 전송 없이 개인 기록을 안전하게 보호합니다.',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 12.2,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: context.surfaceBorder.withValues(alpha: 0.6),
            ),

            // 2. 내용 섹션 카드
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                child: Column(
                  children: [
                    _buildSectionCard(
                      context,
                      icon: Icons.storage_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      title: '1. 개인정보 수집 및 저장',
                      body:
                          '3초 습관 앱은 회원가입이나 외부 서버 전송 없이, 모든 습관 및 실천 기록을 사용자 휴대폰 내부(로컬 DB)에만 안전하게 저장합니다.',
                    ),
                    const SizedBox(height: 10),
                    _buildSectionCard(
                      context,
                      icon: Icons.folder_shared_rounded,
                      iconColor: accent,
                      title: '2. 데이터 백업 및 복원',
                      body:
                          '사용자가 직접 내보낸 백업 파일(JSON)은 외부 서버에 수집되지 않으며, 사용자가 선택한 기기 폴더나 개인 저장소에만 보관됩니다.',
                    ),
                    const SizedBox(height: 10),
                    _buildSectionCard(
                      context,
                      icon: Icons.notifications_none_rounded,
                      iconColor: AppColors.primaryLight,
                      title: '3. 알림·음성 및 광고 서비스',
                      body:
                          '• 푸시 알림 및 한국어 음성 사운드는 기기 내장 리소스로만 동작하며 녹음/외부 전송을 하지 않습니다.\n• 앱 내 광고 송출을 위해 Google AdMob SDK가 사용될 수 있으며, 해당 영역은 구글 개인정보처리방침을 따릅니다.',
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
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '확인',
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
