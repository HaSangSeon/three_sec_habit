import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// 배터리 최적화 및 정시 알림 수신 팁 다이얼로그
class BatteryOptimizationDialog extends StatelessWidget {
  const BatteryOptimizationDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const BatteryOptimizationDialog(),
    );
  }

  static Widget _buildGuideRow(BuildContext context, String title, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt_rounded, color: AppColors.primaryLight, size: 22),
          ),
          const SizedBox(width: 10),
          Text(
            '기기별 정시 알림 수신 팁',
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '스마트폰 제조사의 배터리 절전 정책으로 인해 화면이 꺼져있을 때 알림이 지연될 수 있습니다. 아래 설정을 확인하시면 제시간에 알림을 받으실 수 있습니다.',
              style: TextStyle(color: context.textSecondary, fontSize: 12.5, height: 1.45),
            ),
            const SizedBox(height: 14),
            _buildGuideRow(
              context,
              '📱 삼성 갤럭시 (One UI)',
              '스마트폰 [설정] → [애플리케이션] → [3초 습관] → [배터리] 항목을 "제한 없음"으로 설정해주세요. (절전 상태 진입 방지)',
            ),
            const SizedBox(height: 10),
            _buildGuideRow(
              context,
              '⚡ 샤오미 / 홍미 / POCO',
              '[보안] 앱 → [권한] → [자동 시작]에서 3초 습관을 "허용"하고, 배터리 절약 모드를 "제한 없음"으로 설정해주세요.',
            ),
            const SizedBox(height: 10),
            _buildGuideRow(
              context,
              '🔔 시스템 알림 권한 (Android 13+)',
              '스마트폰 [설정] → [애플리케이션] → [3초 습관] → [알림]이 "허용" 상태인지 확인해주세요.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('확인', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
