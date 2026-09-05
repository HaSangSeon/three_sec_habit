import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/home_widget_service.dart';
import '../../core/services/notification_service.dart';
import '../../providers/habit_provider.dart';
import '../../providers/theme_provider.dart';
import '../common/help_guide_dialog.dart';

/// 앱 설정 화면 (다크모드 전환, 알림 설정, 백업/복원 안내)
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _allNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();
  }

  Future<void> _loadNotificationSetting() async {
    final enabled = await NotificationService.isAllNotificationsEnabled();
    if (mounted) {
      setState(() => _allNotificationsEnabled = enabled);
    }
  }

  Widget _buildSectionHeader(String title, IconData icon, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 15,
            color: AppColors.primaryLight,
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideRow(BuildContext context, String title, String description) {
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

  void _showBatteryOptimizationGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text('확인', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: context.bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: context.bg,
            border: Border(
              bottom: BorderSide(
                color: context.surfaceBorder.withValues(alpha: 0.6),
                width: 0.8,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 앱 타이틀 — 모던 프리미엄 브랜드 뱃지 + 타이포그래피
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: context.isDarkMode ? 0.22 : 0.12),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: context.isDarkMode ? 0.4 : 0.2),
                            width: 1.0,
                          ),
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: AppColors.primaryLight,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '설정',
                        style: TextStyle(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          letterSpacing: -0.6,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // 도움말 아이콘
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => HelpGuideDialog.show(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.surface,
                        border: Border.all(
                          color: context.surfaceBorder,
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.help_outline_rounded,
                        size: 18,
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // 1. 화면 및 테마 설정
          _buildSectionHeader('화면 및 테마', Icons.palette_outlined, context),
          Card(
            margin: EdgeInsets.zero,
            color: context.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: context.surfaceBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '테마 모드 선택',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildThemeOption(
                        label: '라이트',
                        icon: Icons.light_mode_rounded,
                        isSelected: themeProvider.themeMode == ThemeMode.light,
                        onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                        context: context,
                      ),
                      const SizedBox(width: 8),
                      _buildThemeOption(
                        label: '다크',
                        icon: Icons.dark_mode_rounded,
                        isSelected: themeProvider.themeMode == ThemeMode.dark,
                        onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                        context: context,
                      ),
                      const SizedBox(width: 8),
                      _buildThemeOption(
                        label: '시스템',
                        icon: Icons.smartphone_rounded,
                        isSelected: themeProvider.themeMode == ThemeMode.system,
                        onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                        context: context,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. 바탕화면 위젯 설정 (1초 빠른 체크)
          _buildSectionHeader('바탕화면 위젯 (1초 빠른 체크)', Icons.widgets_outlined, context),
          Card(
            margin: EdgeInsets.zero,
            color: context.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: context.surfaceBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.touch_app_rounded,
                          color: AppColors.primaryLight,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '스마트폰 홈 화면에서 원터치 체크',
                              style: TextStyle(
                                color: context.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '앱을 켜지 않고도 바탕화면에서 오늘 해야 할 습관을 바로 확인하고 터치 한 번으로 즉시 완료할 수 있습니다.',
                              style: TextStyle(
                                color: context.textMuted,
                                fontSize: 12.5,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(height: 1, color: context.surfaceBorder),
                  const SizedBox(height: 14),
                  // 4x2 위젯 옵션
                  _buildWidgetOptionTile(
                    title: '4x2 체크리스트 위젯',
                    subtitle: '오늘 해야 할 습관 목록 표시 & 원터치 완료',
                    badge: '추천',
                    badgeColor: AppColors.primaryLight,
                    icon: Icons.view_agenda_rounded,
                    onAdd: () => _showWidgetPreviewAndPinDialog(context, initialIs4x2: true),
                    context: context,
                  ),
                  const SizedBox(height: 10),
                  // 2x2 위젯 옵션
                  _buildWidgetOptionTile(
                    title: '2x2 퀵 대시보드 위젯',
                    subtitle: '오늘 달성률(%) 강조 & 1순위 습관 빠른 완료',
                    badge: '심플',
                    badgeColor: AppColors.success,
                    icon: Icons.dashboard_customize_rounded,
                    onAdd: () => _showWidgetPreviewAndPinDialog(context, initialIs4x2: false),
                    context: context,
                  ),
                  const SizedBox(height: 10),
                  // 위젯 사용 팁 버튼
                  InkWell(
                    onTap: () => _showWidgetPreviewAndPinDialog(context, initialIs4x2: true),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.visibility_rounded,
                            size: 15,
                            color: AppColors.primaryLight,
                          ),
                          const SizedBox(width: 6),
                          const Flexible(
                            child: Text(
                              '바탕화면 위젯 실시간 미리보기 & 사용 팁',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.primaryLight,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. 알림 설정 섹션
          _buildSectionHeader('알림', Icons.notifications_none_rounded, context),
          Card(
            margin: EdgeInsets.zero,
            color: context.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: context.surfaceBorder),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_rounded, color: AppColors.primaryLight, size: 22),
                  title: Text(
                    '전체 알림 허용',
                    style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600, fontSize: 14.5),
                  ),
                  subtitle: Text(
                    '등록된 모든 습관의 정시 리마인더 알림',
                    style: TextStyle(color: context.textMuted, fontSize: 12),
                  ),
                  value: _allNotificationsEnabled,
                  activeTrackColor: AppColors.primary,
                  activeThumbColor: Colors.white,
                  onChanged: (val) async {
                    setState(() => _allNotificationsEnabled = val);
                    final habitProvider =
                        Provider.of<HabitProvider>(context, listen: false);
                    await NotificationService.setAllNotificationsEnabled(
                      val,
                      habitProvider.habits,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            val
                                ? '모든 습관 알림이 활성화되었습니다.'
                                : '모든 알림이 해제되었습니다.',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                ),
                if (_allNotificationsEnabled) ...[
                  Divider(color: context.surfaceBorder, height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: InkWell(
                      onTap: () async {
                        final success = await NotificationService.showTestNotification(
                          title: '⚡ [3초 습관] 푸시 알림 테스트',
                          body: '정상 작동 중입니다! 오늘의 작은 3초가 큰 변화를 만듭니다 ⚡️',
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? '⚡ 테스트 알림이 발송되었습니다! (화면 상단바 확인)'
                                    : '⚠️ 알림 권한이 차단되어 있습니다. 시스템 알림 설정을 허용해주세요.',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.22),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.notifications_active_outlined,
                              size: 17,
                              color: AppColors.primaryLight,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '푸시 알림 테스트 발송하기',
                              style: TextStyle(
                                color: context.isDarkMode
                                    ? const Color(0xFFDDD6FE)
                                    : AppColors.primaryDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Center(
                      child: InkWell(
                        onTap: () => _showBatteryOptimizationGuide(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.info_outline_rounded, size: 14, color: context.textMuted),
                              const SizedBox(width: 5),
                              Text(
                                '알림이 늦게 오거나 안 오시나요? (기기별 수신 팁)',
                                style: TextStyle(
                                  color: context.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. 데이터 관리 섹션 (백업 및 복원)
          _buildSectionHeader('데이터 관리', Icons.storage_rounded, context),
          Card(
            margin: EdgeInsets.zero,
            color: context.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: context.surfaceBorder),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download_outlined, color: AppColors.primaryLight, size: 22),
                  title: Text(
                    '데이터 백업 (내보내기)',
                    style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600, fontSize: 14.5),
                  ),
                  subtitle: Text(
                    '습관 및 실천 기록을 JSON 파일로 백업/공유합니다',
                    style: TextStyle(color: context.textMuted, fontSize: 12),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: context.textMuted),
                  onTap: () => _handleBackup(context),
                ),
                Divider(color: context.surfaceBorder, height: 1),
                ListTile(
                  leading: const Icon(Icons.file_upload_outlined, color: AppColors.primaryLight, size: 22),
                  title: Text(
                    '데이터 복원 (가져오기)',
                    style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600, fontSize: 14.5),
                  ),
                  subtitle: Text(
                    '백업된 JSON 파일로부터 습관과 기록을 복구합니다',
                    style: TextStyle(color: context.textMuted, fontSize: 12),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: context.textMuted),
                  onTap: () => _handleRestore(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 5. 고객지원 및 법적 고지
          _buildSectionHeader('지원 및 안내', Icons.support_agent_rounded, context),
          Card(
            margin: EdgeInsets.zero,
            color: context.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: context.surfaceBorder),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.menu_book_rounded, color: AppColors.primaryLight, size: 22),
                  title: Text(
                    '3초 습관 사용 가이드',
                    style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600, fontSize: 14.5),
                  ),
                  subtitle: Text(
                    '핵심 기능 및 꿀팁 확인하기',
                    style: TextStyle(color: context.textMuted, fontSize: 12),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: context.textMuted),
                  onTap: () => HelpGuideDialog.show(context),
                ),
                Divider(color: context.surfaceBorder, height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primaryLight, size: 22),
                  title: Text(
                    '개인정보 처리방침',
                    style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600, fontSize: 14.5),
                  ),
                  subtitle: Text(
                    '안전한 로컬 데이터 처리 및 보안 안내',
                    style: TextStyle(color: context.textMuted, fontSize: 12),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: context.textMuted),
                  onTap: () => _showPrivacyPolicyDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 6. 앱 정보
          _buildSectionHeader('앱 정보', Icons.info_outline_rounded, context),
          Card(
            margin: EdgeInsets.zero,
            color: context.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: context.surfaceBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '3초 습관',
                            style: TextStyle(
                              color: context.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'v1.0.0 (Build 5)',
                            style: TextStyle(
                              color: context.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppColors.success, size: 12),
                        SizedBox(width: 4),
                        Text(
                          '최신 버전',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (context.isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : context.surfaceBorder,
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : context.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : context.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleBackup(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final result = await BackupService.exportBackup();

    if (!context.mounted) return;

    if (result['success'] == true) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            '📦 습관 ${result['habitCount']}개, 실천기록 ${result['logCount']}개가 백업되었습니다.',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('백업 실패: ${result['error']}'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleRestore(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: context.surfaceBorder),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 24),
            const SizedBox(width: 8),
            Text(
              '데이터 복원 확인',
              style: TextStyle(
                color: context.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
          ],
        ),
        content: Text(
          '백업 파일을 가져오면 현재 기기의 데이터가 백업 파일의 내용으로 복원 및 교체됩니다.\n\n계속 진행하시겠습니까?',
          style: TextStyle(color: context.textSecondary, fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('취소', style: TextStyle(color: context.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('복원 진행', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final habitProvider = context.read<HabitProvider>();

    final result = await BackupService.importBackup();

    if (!context.mounted) return;

    if (result['cancelled'] == true) {
      return;
    }

    if (result['success'] == true) {
      await habitProvider.loadHabits();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            '🎉 습관 ${result['habitCount']}개, 실천기록 ${result['logCount']}개가 성공적으로 복원되었습니다!',
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('복원 실패: ${result['error']}'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('확인', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePinWidget({required bool is4x2}) async {
    final name = is4x2 ? '4x2 체크리스트 위젯' : '2x2 퀵 대시보드 위젯';
    final success = is4x2
        ? await HomeWidgetService.pinWidget4x2()
        : await HomeWidgetService.pinWidget2x2();

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('홈 화면에 [$name] 추가 창이 열렸습니다.'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _showWidgetPreviewAndPinDialog(context, initialIs4x2: is4x2);
    }
  }

  void _showWidgetPreviewAndPinDialog(BuildContext context, {bool initialIs4x2 = true}) {
    showDialog(
      context: context,
      builder: (ctx) {
        bool is4x2 = initialIs4x2;
        bool showManualGuide = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 440, maxHeight: 720),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: context.surfaceBorder, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 36,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.28),
                            AppColors.primaryLight.withValues(alpha: 0.10),
                            context.surface,
                          ],
                          stops: const [0.0, 0.45, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primaryLight.withValues(alpha: 0.45),
                                    width: 1,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.widgets_rounded, size: 13, color: AppColors.primaryLight),
                                    SizedBox(width: 5),
                                    Text(
                                      '홈 화면 실시간 스마트 위젯',
                                      style: TextStyle(
                                        color: AppColors.primaryLight,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () => Navigator.of(ctx).pop(),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.close_rounded, size: 18, color: context.textSecondary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '바탕화면 위젯 미리보기 & 추가',
                            style: TextStyle(
                              color: context.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '앱을 켜지 않고 홈 화면에서 1초 만에 체크하고 진행 상황을 확인하세요.',
                            style: TextStyle(
                              color: context.textMuted,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 위젯 종류 전환 탭 세그먼트
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: context.isDarkMode
                                    ? Colors.black.withValues(alpha: 0.3)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: context.surfaceBorder),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildWidgetSegmentTab(
                                      title: '4x2 체크리스트 (추천)',
                                      icon: Icons.view_agenda_rounded,
                                      isSelected: is4x2,
                                      onTap: () => setDialogState(() => is4x2 = true),
                                      context: context,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: _buildWidgetSegmentTab(
                                      title: '2x2 퀵 대시보드',
                                      icon: Icons.dashboard_customize_rounded,
                                      isSelected: !is4x2,
                                      onTap: () => setDialogState(() => is4x2 = false),
                                      context: context,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // 스마트폰 홈 화면 속 실제 위젯 그래픽 뷰
                            _buildRealisticWidgetMockup(is4x2: is4x2, context: context),
                            const SizedBox(height: 16),

                            // 핵심 특장점 칩 카드
                            _buildFeatureCard(
                              icon: Icons.check_circle_outline_rounded,
                              iconColor: AppColors.success,
                              title: '원터치 즉시 완료 & 해제 (토글)',
                              desc: '위젯 우측의 버튼을 누르면 즉시 [✓] 완료되며, 실수로 눌렀을 땐 다시 눌러 바로 취소할 수 있습니다.',
                              badge: '양방향 연동',
                              badgeColor: AppColors.success,
                              context: context,
                            ),
                            const SizedBox(height: 8),
                            _buildFeatureCard(
                              icon: Icons.repeat_rounded,
                              iconColor: AppColors.primaryLight,
                              title: '회차형 습관 단계별 카운팅 (+1)',
                              desc: '물마시기, 푸시업 등 목표 횟수가 있는 습관은 [+1] 버튼으로 1잔/1회씩 누적되며 목표 시 자동 완료됩니다.',
                              badge: '실시간 카운트',
                              badgeColor: AppColors.primaryLight,
                              context: context,
                            ),
                            const SizedBox(height: 8),
                            _buildFeatureCard(
                              icon: Icons.sync_rounded,
                              iconColor: Colors.amber,
                              title: '앱과 100% 실시간 양방향 자동 동기화',
                              desc: '위젯에서 체크한 내역은 앱 내 캘린더 잔디와 통계에 즉시 반영되며 순서와 데이터가 항상 일치합니다.',
                              badge: '실시간 동기화',
                              badgeColor: Colors.amber,
                              context: context,
                            ),
                            const SizedBox(height: 12),

                            // 수동 추가 안내 아코디언 토글
                            InkWell(
                              onTap: () => setDialogState(() => showManualGuide = !showManualGuide),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: context.surfaceBorder.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: context.surfaceBorder, width: 0.8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.help_outline_rounded, size: 16, color: AppColors.primaryLight),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '스마트폰 홈 화면에서 직접 꺼내는 방법',
                                        style: TextStyle(
                                          color: context.textPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      showManualGuide ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                      size: 18,
                                      color: context.textMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (showManualGuide) ...[
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: context.isDarkMode
                                      ? Colors.white.withValues(alpha: 0.02)
                                      : Colors.black.withValues(alpha: 0.02),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: context.surfaceBorder),
                                ),
                                child: Column(
                                  children: [
                                    _buildManualStep('1', '스마트폰 홈 화면의 빈 곳을 1~2초간 길게 터치합니다.', context),
                                    const SizedBox(height: 6),
                                    _buildManualStep('2', '하단에 뜨는 메뉴에서 [위젯]을 선택합니다.', context),
                                    const SizedBox(height: 6),
                                    _buildManualStep('3', '[3초 습관]을 찾아 ${is4x2 ? '4x2' : '2x2'} 위젯을 원하는 위치로 드래그합니다.', context),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // 3. 하단 액션 버튼 바 (닫기 + 홈 화면에 위젯 추가)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                      decoration: BoxDecoration(
                        color: context.surface,
                        border: Border(top: BorderSide(color: context.surfaceBorder, width: 0.8)),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: 46,
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: context.textSecondary,
                                  side: BorderSide(color: context.surfaceBorder),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  '닫기',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 46,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  _handlePinWidget(is4x2: is4x2);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shadowColor: AppColors.primary.withValues(alpha: 0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.bolt_rounded, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      is4x2 ? '4x2 위젯 홈에 추가' : '2x2 위젯 홈에 추가',
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWidgetSegmentTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : context.textSecondary,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? Colors.white : context.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealisticWidgetMockup({required bool is4x2, required BuildContext context}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF131722),
            Color(0xFF1E1B2E),
            Color(0xFF0F1218),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2D3344), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  '스마트폰 홈 화면 실제 설치 모습',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                is4x2 ? '가로 4칸 × 세로 2칸' : '가로 2칸 × 세로 2칸',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (is4x2)
            _buildRealistic4x2WidgetMockup()
          else
            _buildRealistic2x2WidgetMockup(),
        ],
      ),
    );
  }

  Widget _buildRealistic4x2WidgetMockup() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C202B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E3446), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '⚡ 3초 습관 · 오늘 루틴',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.4)),
                ),
                child: const Text(
                  '2 / 3 완료 (67%)',
                  style: TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: const Color(0xFF292E3D),
          ),
          const SizedBox(height: 8),
          _buildMockupHabitRow(
            title: '아침 미온수 한 잔 마시기',
            isCompleted: true,
            trailing: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Color(0xFF22C55E),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          _buildMockupHabitRow(
            title: '물 8잔 마시기',
            isCompleted: false,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    '5 / 8잔',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Text(
                    '+1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          _buildMockupHabitRow(
            title: '하루 30분 유산소 운동',
            isCompleted: false,
            trailing: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF94A3B8), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockupHabitRow({
    required String title,
    required bool isCompleted,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF232836),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2E3446), width: 0.8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isCompleted ? const Color(0xFF94A3B8) : const Color(0xFFF1F5F9),
                fontSize: 12,
                fontWeight: isCompleted ? FontWeight.w500 : FontWeight.w600,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                decorationColor: const Color(0xFF94A3B8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }

  Widget _buildRealistic2x2WidgetMockup() {
    return Center(
      child: Container(
        width: 190,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1C202B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF2E3446), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Text(
                  '⚡ 3초 습관',
                  style: TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Spacer(),
                Text(
                  '오늘',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '2 / 3',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.4)),
              ),
              child: const Text(
                '67% 달성',
                style: TextStyle(
                  color: Color(0xFF22C55E),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF232836),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2E3446), width: 0.8),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1순위 빠른 체크',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '하루 30분 달리기',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryLight, width: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
    required String badge,
    required Color badgeColor,
    required BuildContext context,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.surfaceBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    color: context.textMuted,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualStep(String number, String text, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 17,
          height: 17,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: AppColors.primaryLight,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: context.textMuted,
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWidgetOptionTile({
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required VoidCallback onAdd,
    required BuildContext context,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.isDarkMode
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.surfaceBorder, width: 0.8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: badgeColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: onAdd,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 14),
                    SizedBox(width: 2),
                    Text('추가', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
