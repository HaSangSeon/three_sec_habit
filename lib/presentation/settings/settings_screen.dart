import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/notification_service.dart';
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

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Text(
        title,
        style: TextStyle(
          color: context.textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      const SizedBox(width: 6),
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
                  // 다크/라이트 모드 토글
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.read<ThemeProvider>().toggleTheme(!context.isDarkMode),
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
                        context.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        size: 18,
                        color: context.isDarkMode
                            ? const Color(0xFFFDE047)
                            : const Color(0xFF059669),
                      ),
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
          // 1. 알림 설정 섹션
          _buildSectionHeader('알림', context),
          Card(
            margin: EdgeInsets.zero,
            color: context.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: context.surfaceBorder),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_rounded, color: AppColors.primaryLight),
                  title: Text(
                    '전체 알림 허용',
                    style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '등록된 모든 습관의 정시 리마인더 알림',
                    style: TextStyle(color: context.textMuted, fontSize: 12),
                  ),
                  value: _allNotificationsEnabled,
                  activeTrackColor: AppColors.primary,
                  activeThumbColor: Colors.white,
                  onChanged: (val) {
                    setState(() => _allNotificationsEnabled = val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(val ? '알림이 켜졌습니다.' : '모든 알림이 꺼졌습니다.'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                Divider(color: context.surfaceBorder, height: 1),
                ListTile(
                  leading: const Icon(Icons.send_rounded, color: AppColors.primaryLight),
                  title: Text(
                    '테스트 알림 발송',
                    style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '즉시 푸시 알림을 수신하여 동작을 테스트합니다',
                    style: TextStyle(color: context.textMuted, fontSize: 12),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '테스트',
                      style: TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  onTap: () async {
                    await NotificationService.showTestNotification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('⚡ 테스트 알림을 발송했습니다! 상단 알림창을 확인해보세요.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. 데이터 관리 섹션 (백업 및 복원)
          _buildSectionHeader('데이터 관리', context),
          Card(
            margin: EdgeInsets.zero,
            color: context.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: context.surfaceBorder),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download_outlined, color: AppColors.primaryLight),
                  title: Text(
                    '데이터 백업 (내보내기)',
                    style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '습관 및 체크 기록을 JSON 파일로 저장합니다',
                    style: TextStyle(color: context.textMuted, fontSize: 12),
                  ),
                  trailing: Icon(Icons.chevron_right, color: context.textMuted),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('로컬 백업 기능이 준비되었습니다.'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                Divider(color: context.surfaceBorder, height: 1),
                ListTile(
                  leading: const Icon(Icons.file_upload_outlined, color: AppColors.primaryLight),
                  title: Text(
                    '데이터 복원 (가져오기)',
                    style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '백업된 JSON 파일로부터 기록을 복구합니다',
                    style: TextStyle(color: context.textMuted, fontSize: 12),
                  ),
                  trailing: Icon(Icons.chevron_right, color: context.textMuted),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('데이터 복원 기능이 준비되었습니다.'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. 앱 정보
          _buildSectionHeader('앱 정보', context),
          Card(
            margin: EdgeInsets.zero,
            color: context.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: context.surfaceBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('버전', style: TextStyle(color: context.textSecondary)),
                      Text('v1.0.0 (Build 4)', style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('개발 철학', style: TextStyle(color: context.textSecondary)),
                      const Text('체크 한 번, 3초 컷 ⚡️', style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
