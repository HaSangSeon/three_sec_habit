import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// 홈 화면 실시간 스마트 위젯 미리보기 및 추가 다이얼로그
class WidgetPreviewPinDialog extends StatefulWidget {
  final bool initialIs4x2;
  final Future<void> Function({required bool is4x2}) onPinWidget;

  const WidgetPreviewPinDialog({
    super.key,
    this.initialIs4x2 = true,
    required this.onPinWidget,
  });

  static Future<void> show(
    BuildContext context, {
    bool initialIs4x2 = true,
    required Future<void> Function({required bool is4x2}) onPinWidget,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => WidgetPreviewPinDialog(
        initialIs4x2: initialIs4x2,
        onPinWidget: onPinWidget,
      ),
    );
  }

  @override
  State<WidgetPreviewPinDialog> createState() => _WidgetPreviewPinDialogState();
}

class _WidgetPreviewPinDialogState extends State<WidgetPreviewPinDialog> {
  late bool _is4x2;
  bool _showManualGuide = false;
  bool? _previewDarkMode; // null이면 현재 앱의 context.isDarkMode를 실시간 반영

  @override
  void initState() {
    super.initState();
    _is4x2 = widget.initialIs4x2;
  }

  Widget _buildWidgetSegmentTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
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

  Widget _buildRealisticWidgetMockup({required bool is4x2}) {
    final isDark = _previewDarkMode ?? context.isDarkMode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [
                  Color(0xFF131722),
                  Color(0xFF1E1B2E),
                  Color(0xFF0F1218),
                ]
              : const [
                  Color(0xFFF1F5F9),
                  Color(0xFFEDE9FE),
                  Color(0xFFE2E8F0),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2D3344) : const Color(0xFFCBD5E1),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
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
              Expanded(
                child: Text(
                  '스마트폰 홈 화면 실제 설치 모습',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // 라이트/다크 미니 전환 칩
              GestureDetector(
                onTap: () {
                  setState(() {
                    _previewDarkMode = !isDark;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : const Color(0xFFCBD5E1),
                      width: 0.8,
                    ),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        size: 11,
                        color: isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isDark ? '다크 위젯' : '라이트 위젯',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (is4x2)
            _buildRealistic4x2WidgetMockup(isDark: isDark)
          else
            _buildRealistic2x2WidgetMockup(isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildRealistic4x2WidgetMockup({required bool isDark}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C202B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3446) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
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
              Expanded(
                child: Text(
                  '⚡ 3초 습관 · 오늘 루틴',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? AppColors.primaryLight : const Color(0xFF7C3AED),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF22C55E).withValues(alpha: 0.4)
                        : const Color(0xFFA7F3D0),
                  ),
                ),
                child: Text(
                  '2 / 3 완료 (67%)',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF22C55E) : const Color(0xFF059669),
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
            color: isDark ? const Color(0xFF292E3D) : const Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 8),
          _buildMockupHabitRow(
            title: '아침 미온수 한 잔 마시기',
            isCompleted: true,
            isDark: isDark,
            trailing: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF22C55E) : const Color(0xFF059669),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          _buildMockupHabitRow(
            title: '물 8잔 마시기',
            isCompleted: false,
            isDark: isDark,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.primary.withValues(alpha: 0.18)
                        : const Color(0xFF7C3AED).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark
                          ? AppColors.primaryLight.withValues(alpha: 0.3)
                          : const Color(0xFF7C3AED).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    '5 / 8잔',
                    style: TextStyle(
                      color: isDark ? AppColors.primaryLight : const Color(0xFF7C3AED),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primary : const Color(0xFF7C3AED),
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
            isDark: isDark,
            trailing: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
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
    required bool isDark,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF232836) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3446) : const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isCompleted
                    ? const Color(0xFF94A3B8)
                    : (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A)),
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

  Widget _buildRealistic2x2WidgetMockup({required bool isDark}) {
    return Center(
      child: Container(
        width: 190,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C202B) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF2E3446) : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
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
                Text(
                  '⚡ 3초 습관',
                  style: TextStyle(
                    color: isDark ? AppColors.primaryLight : const Color(0xFF7C3AED),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  '오늘',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '2 / 3',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                    : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF22C55E).withValues(alpha: 0.4)
                      : const Color(0xFFA7F3D0),
                ),
              ),
              child: Text(
                '67% 달성',
                style: TextStyle(
                  color: isDark ? const Color(0xFF22C55E) : const Color(0xFF059669),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF232836) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? const Color(0xFF2E3446) : const Color(0xFFE2E8F0),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1순위 빠른 체크',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '하루 30분 달리기',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                      border: Border.all(
                        color: isDark ? AppColors.primaryLight : const Color(0xFF7C3AED),
                        width: 1.5,
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
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
    required String badge,
    required Color badgeColor,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2330) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3547) : const Color(0xFFE2E8F0),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iconColor.withValues(alpha: isDark ? 0.24 : 0.14),
                  iconColor.withValues(alpha: isDark ? 0.12 : 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: iconColor.withValues(alpha: isDark ? 0.35 : 0.20),
                width: 0.8,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: 11),
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
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: isDark ? 0.18 : 0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: badgeColor.withValues(alpha: isDark ? 0.35 : 0.20),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3.5),
                Text(
                  desc,
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 11.5,
                    height: 1.4,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualStep(String number, String text) {
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

  @override
  Widget build(BuildContext context) {
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
                        onTap: () => Navigator.of(context).pop(),
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
                              isSelected: _is4x2,
                              onTap: () => setState(() => _is4x2 = true),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildWidgetSegmentTab(
                              title: '2x2 퀵 대시보드',
                              icon: Icons.dashboard_customize_rounded,
                              isSelected: !_is4x2,
                              onTap: () => setState(() => _is4x2 = false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 스마트폰 홈 화면 속 실제 위젯 그래픽 뷰
                    _buildRealisticWidgetMockup(is4x2: _is4x2),
                    const SizedBox(height: 16),

                    // 핵심 특장점 칩 카드
                    _buildFeatureCard(
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: AppColors.success,
                      title: '원터치 즉시 완료 & 취소',
                      desc: '위젯 체크 버튼을 누르면 즉시 [✓] 완료되며, 다시 누르면 간편하게 취소할 수 있습니다.',
                      badge: '토글 연동',
                      badgeColor: AppColors.success,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureCard(
                      icon: Icons.repeat_rounded,
                      iconColor: AppColors.primaryLight,
                      title: '회차형 습관 단계별 카운팅',
                      desc: '물마시기, 운동 등 목표 횟수가 있는 습관은 [+1] 버튼으로 1회씩 누적됩니다.',
                      badge: '+1 누적',
                      badgeColor: AppColors.primaryLight,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureCard(
                      icon: Icons.sync_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: '실시간 양방향 자동 연동',
                      desc: '위젯에서 체크한 내역은 앱 내 잔디 캘린더와 통계에 즉시 100% 반영됩니다.',
                      badge: '100% 동기화',
                      badgeColor: const Color(0xFFF59E0B),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),

                    // 수동 추가 안내 아코디언 토글
                    InkWell(
                      onTap: () => setState(() => _showManualGuide = !_showManualGuide),
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
                              _showManualGuide ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: context.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_showManualGuide) ...[
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
                            _buildManualStep('1', '스마트폰 홈 화면의 빈 곳을 1~2초간 길게 터치합니다.'),
                            const SizedBox(height: 6),
                            _buildManualStep('2', '하단에 뜨는 메뉴에서 [위젯]을 선택합니다.'),
                            const SizedBox(height: 6),
                            _buildManualStep('3', '[3초 습관]을 찾아 ${_is4x2 ? '4x2' : '2x2'} 위젯을 원하는 위치로 드래그합니다.'),
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
                        onPressed: () => Navigator.of(context).pop(),
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
                          Navigator.of(context).pop();
                          widget.onPinWidget(is4x2: _is4x2);
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
                              _is4x2 ? '4x2 위젯 홈에 추가' : '2x2 위젯 홈에 추가',
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
  }
}
