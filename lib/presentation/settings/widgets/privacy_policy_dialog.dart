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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: context.surfaceBorder),
      ),
      title: Row(
        children: [
          const Icon(Icons.privacy_tip_rounded, color: AppColors.primary, size: 22),
          const SizedBox(width: 8),
          Text(
            '개인정보 처리방침',
            style: TextStyle(
              color: context.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. 개인정보 수집 및 저장',
                style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5),
              ),
              const SizedBox(height: 4),
              Text(
                '• 3초 습관 앱은 회원가입이나 서버 전송 없이, 모든 습관 및 실천 기록을 사용자의 기기 내부(SQLite DB)에만 안전하게 저장합니다.',
                style: TextStyle(color: context.textSecondary, fontSize: 12.5, height: 1.4),
              ),
              const SizedBox(height: 12),
              Text(
                '2. 데이터 백업 및 이동',
                style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5),
              ),
              const SizedBox(height: 4),
              Text(
                '• 사용자가 직접 백업한 JSON 파일은 외부 서버에 전송되지 않으며, 사용자가 선택한 저장소(드라이브, 파일 등)에만 보관됩니다.',
                style: TextStyle(color: context.textSecondary, fontSize: 12.5, height: 1.4),
              ),
              const SizedBox(height: 12),
              Text(
                '3. 알림 및 광고 서비스',
                style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5),
              ),
              const SizedBox(height: 4),
              Text(
                '• 로컬 푸시 알림은 기기 자체 타이머로 동작합니다.\n• 구글 애드몹(Google AdMob)을 통한 배너 광고 송출 시 구글의 개인정보처리방침이 적용됩니다.',
                style: TextStyle(color: context.textSecondary, fontSize: 12.5, height: 1.4),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('확인', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
