import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/notification_service.dart';
import '../../providers/theme_provider.dart';

/// 앱 설정 화면 (다크모드 전환, 알림 설정, 백업/복원 안내)
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _allNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: context.bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: context.surface,
            border: Border(
              bottom: BorderSide(
                color: context.surfaceBorder,
                width: 1.0,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                    alpha: context.isDarkMode ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF475569), Color(0xFF64748B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.settings_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '설정',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '앱 환경 및 알림 관리',
                    style: TextStyle(
                      color: context.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  // 다크/라이트 모드 토글
                  GestureDetector(
                    onTap: () => themeProvider.toggleTheme(!context.isDarkMode),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.isDarkMode
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.04),
                      ),
                      child: Icon(
                        context.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        size: 17,
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
          // 1. 테마 설정 섹션
          _buildSectionHeader('화면 테마', context),
          Card(
            margin: EdgeInsets.zero,
            color: context.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: context.surfaceBorder),
            ),
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode_rounded, color: AppColors.primaryLight),
              title: Text(
                '다크 모드',
                style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '어둡고 눈이 편안한 테마를 사용합니다',
                style: TextStyle(color: context.textMuted, fontSize: 12),
              ),
              value: themeProvider.isDarkMode,
              activeTrackColor: AppColors.primary,
              activeThumbColor: Colors.white,
              onChanged: (val) {
                themeProvider.toggleTheme(val);
              },
            ),
          ),
          const SizedBox(height: 24),

          // 2. 알림 설정 섹션
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
                      Text('1.0.0 (3초 컷)', style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w700)),
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

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: context.textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
