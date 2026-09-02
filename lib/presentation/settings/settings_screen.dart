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

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: context.bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(66),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: context.isDarkMode
                  ? const [
                      Color(0xFF064E3B),
                      Color(0xFF065F46),
                      Color(0xFF0F3460),
                    ]
                  : const [
                      Color(0xFF059669),
                      Color(0xFF10B981),
                      Color(0xFF0EA5E9),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              bottom: BorderSide(
                color: context.isDarkMode
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : const Color(0xFFDDD6FE),
                width: 1.2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: context.isDarkMode
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.settings_rounded,
                        color: Colors.white.withValues(alpha: 0.95),
                        size: 20,
                        shadows: [
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '설정',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          letterSpacing: -0.5,
                          height: 1.0,
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
                        color: context.isDarkMode
                            ? const Color(0xFF1E293B)
                            : Colors.white,
                        border: Border.all(
                          color: context.isDarkMode
                              ? const Color(0xFF10B981).withValues(alpha: 0.35)
                              : const Color(0xFFA7F3D0),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF059669).withValues(
                              alpha: context.isDarkMode ? 0.25 : 0.12,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.help_outline_rounded,
                        size: 18,
                        color: context.isDarkMode
                            ? Colors.white.withValues(alpha: 0.9)
                            : const Color(0xFF059669),
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
                    onAdd: () => _handlePinWidget(is4x2: true),
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
                    onAdd: () => _handlePinWidget(is4x2: false),
                    context: context,
                  ),
                  const SizedBox(height: 10),
                  // 위젯 사용 팁 버튼
                  InkWell(
                    onTap: () => _showWidgetGuideDialog(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.help_outline_rounded,
                            size: 15,
                            color: AppColors.primaryLight,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '위젯 사용 팁 및 수동 추가 방법 보기',
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
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
                  leading: const Icon(Icons.mail_outline_rounded, color: AppColors.primaryLight, size: 22),
                  title: Text(
                    '문의 및 피드백',
                    style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600, fontSize: 14.5),
                  ),
                  subtitle: Text(
                    '개선 아이디어 및 오류 제보하기',
                    style: TextStyle(color: context.textMuted, fontSize: 12),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: context.textMuted),
                  onTap: () => _showFeedbackDialog(context),
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
                Divider(color: context.surfaceBorder, height: 1),
                ListTile(
                  leading: const Icon(Icons.code_rounded, color: AppColors.primaryLight, size: 22),
                  title: Text(
                    '오픈소스 라이선스',
                    style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600, fontSize: 14.5),
                  ),
                  subtitle: Text(
                    '사용된 오픈소스 라이브러리 라이선스',
                    style: TextStyle(color: context.textMuted, fontSize: 12),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: context.textMuted),
                  onTap: () {
                    showLicensePage(
                      context: context,
                      applicationName: '3초 습관',
                      applicationVersion: 'v1.0.0 (Build 5)',
                      applicationIcon: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 36),
                      ),
                    );
                  },
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

  void _showFeedbackDialog(BuildContext context) {
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
            const Icon(Icons.mail_outline_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              '문의 및 피드백',
              style: TextStyle(
                color: context.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '3초 습관을 이용해 주셔서 감사합니다!\n소중한 의견과 피드백은 앱 발전에 큰 힘이 됩니다.',
              style: TextStyle(color: context.textSecondary, fontSize: 13.5, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.surfaceBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email_rounded, color: AppColors.primaryLight, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      'contact@threesechabit.com',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
      _showWidgetGuideDialog(context);
    }
  }

  void _showWidgetGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.surfaceBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. 프리미엄 그라데이션 헤더
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.22),
                      AppColors.primaryLight.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primaryLight.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt_rounded, size: 14, color: AppColors.primaryLight),
                              SizedBox(width: 4),
                              Text(
                                '3초 습관 위젯 200% 활용법',
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
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(Icons.close_rounded, size: 20, color: context.textMuted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '바탕화면 위젯 사용 & 추가 가이드',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 17.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '앱을 켜지 않고도 홈 화면에서 1초 만에 실천하고 체크하세요.',
                      style: TextStyle(
                        color: context.textMuted,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. 가이드 카드 리스트 (스크롤 지원)
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFeatureCard(
                        icon: Icons.check_circle_outline_rounded,
                        iconColor: AppColors.success,
                        title: '원터치 즉시 완료 & 해제 (토글)',
                        desc: '위젯 우측의 [○]을 누르면 즉시 [✓]로 완료되며 달성률이 갱신됩니다. 다시 누르면 언제든 완료 취소(해제)할 수 있습니다.',
                        badge: '양방향 토글',
                        badgeColor: AppColors.success,
                        context: context,
                      ),
                      const SizedBox(height: 10),
                      _buildFeatureCard(
                        icon: Icons.repeat_rounded,
                        iconColor: AppColors.primaryLight,
                        title: '회차형 습관 단계별 카운팅 (+1)',
                        desc: '물마시기, 푸시업 등 목표 횟수가 있는 습관은 [+1] 버튼으로 1회씩 누적되며, 목표 달성 시 자동으로 [✓] 완료됩니다.',
                        badge: '실시간 잔수/횟수 표시',
                        badgeColor: AppColors.primaryLight,
                        context: context,
                      ),
                      const SizedBox(height: 10),
                      _buildFeatureCard(
                        icon: Icons.swap_vert_rounded,
                        iconColor: Colors.amber,
                        title: '전체 목록 부드러운 스크롤 & 순서 유지',
                        desc: '습관이 5개, 10개 이상이어도 위젯 내에서 위아래로 스크롤하여 모두 볼 수 있으며, 앱 내 설정 순서가 100% 유지됩니다.',
                        badge: '스크롤 지원',
                        badgeColor: Colors.amber,
                        context: context,
                      ),
                      const SizedBox(height: 16),

                      // 수동 추가 방법 안내 박스
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.surfaceBorder.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: context.surfaceBorder,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.add_to_home_screen_rounded,
                                  size: 16,
                                  color: AppColors.primaryLight,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '스마트폰 홈 화면에 수동으로 추가하는 법',
                                  style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildManualStep('1', '스마트폰 홈 화면의 빈 곳을 1~2초간 길게 터치합니다.', context),
                            const SizedBox(height: 6),
                            _buildManualStep('2', '하단에 뜨는 메뉴에서 [위젯 (Widgets)]을 선택합니다.', context),
                            const SizedBox(height: 6),
                            _buildManualStep('3', '[3초 습관]을 찾아 4x2 또는 2x2 위젯을 원하는 위치로 드래그합니다.', context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. 하단 확인 버튼
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      '확인했어요 ✨',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
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
    return Container(
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
                    Text(
                      title,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 15),
                SizedBox(width: 2),
                Text('추가', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
