import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/home_widget_service.dart';
import '../../providers/habit_provider.dart';
import '../../providers/theme_provider.dart';
import '../common/help_guide_dialog.dart';
import 'widgets/privacy_policy_dialog.dart';
import 'widgets/widget_preview_pin_dialog.dart';

/// 앱 설정 화면 (다크모드 전환, 알림 설정, 백업/복원 안내)
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = 'v1.0.7';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          final build = info.buildNumber.isNotEmpty ? ' (Build ${info.buildNumber})' : '';
          _appVersion = 'v${info.version}$build';
        });
      }
    } catch (_) {
      // Platform channel 실패 또는 테스트 환경 시 기본값 유지
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
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
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
            color: context.bg,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF10B981).withValues(alpha: context.isDarkMode ? 0.14 : 0.05),
                context.bg,
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF10B981).withValues(alpha: context.isDarkMode ? 0.22 : 0.12),
                width: 1.0,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 앱 타이틀 — 모던 프리미엄 브랜드 뱃지 + 타이포그래피 + 상태 캡슐 (초소형 화면 및 폰트 확대 대응)
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0D9488), Color(0xFF10B981)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '환경 설정',
                                  style: TextStyle(
                                    color: context.textPrimary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                    letterSpacing: -0.6,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: context.isDarkMode ? 0.22 : 0.10),
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                      color: const Color(0xFF10B981).withValues(alpha: context.isDarkMode ? 0.42 : 0.25),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    '시스템',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: context.isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669),
                                      letterSpacing: -0.2,
                                      height: 1.1,
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
                  const SizedBox(width: 8),
                  // 도움말 아이콘
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => HelpGuideDialog.show(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: context.surface,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: context.surfaceBorder.withValues(alpha: context.isDarkMode ? 0.8 : 0.6),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.25 : 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 1.5),
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
                    onAdd: () => WidgetPreviewPinDialog.show(context, initialIs4x2: true, onPinWidget: _handlePinWidget),
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
                    onAdd: () => WidgetPreviewPinDialog.show(context, initialIs4x2: false, onPinWidget: _handlePinWidget),
                    context: context,
                  ),
                  const SizedBox(height: 10),
                  // 위젯 사용 팁 버튼
                  InkWell(
                    onTap: () => WidgetPreviewPinDialog.show(context, initialIs4x2: true, onPinWidget: _handlePinWidget),
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
                  onTap: () => PrivacyPolicyDialog.show(context),
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
                  Expanded(
                    child: Row(
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
                        Flexible(
                          child: Column(
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
                                _appVersion,
                                style: TextStyle(
                                  color: context.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
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
          const SizedBox(height: 24),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '런처 환경에 따라 원클릭 추가가 제한될 수 있습니다.\n홈 화면 빈 공간을 길게 눌러 [위젯] 메뉴에서 직접 추가해 주세요.',
          ),
          backgroundColor: const Color(0xFF475569),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: '방법 보기',
            textColor: AppColors.primaryLight,
            onPressed: () {
              WidgetPreviewPinDialog.show(
                context,
                initialIs4x2: is4x2,
                onPinWidget: _handlePinWidget,
              );
            },
          ),
        ),
      );
    }
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
