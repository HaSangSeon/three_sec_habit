import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/ad_service.dart';

/// 하단 AdMob 가로 100% 맞춤형 적응형 배너 광고 위젯
class AdBannerSlot extends StatefulWidget {
  const AdBannerSlot({super.key});

  @override
  State<AdBannerSlot> createState() => _AdBannerSlotState();
}

class _AdBannerSlotState extends State<AdBannerSlot> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  int? _loadedWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentWidth = MediaQuery.of(context).size.width.truncate();
    if (_loadedWidth != currentWidth && !_isAdLoading) {
      _loadAdaptiveAd(currentWidth);
    }
  }

  Future<void> _loadAdaptiveAd(int width) async {
    if (kIsWeb) return;
    _isAdLoading = true;
    _loadedWidth = width;

    try {
      final ad = await AdService.createAdaptiveBannerAd(
        width: width,
        onAdLoaded: () {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _isAdLoading = false;
            });
          }
        },
        onAdFailedToLoad: (error) {
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
              _isAdLoading = false;
            });
          }
        },
      );

      if (ad != null) {
        _bannerAd?.dispose();
        _bannerAd = ad;
        await _bannerAd?.load();
      } else {
        _isAdLoading = false;
      }
    } catch (e) {
      debugPrint('Error loading adaptive banner ad: $e');
      _isAdLoading = false;
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = AdService.bannerHeight;

    if (_isAdLoaded && _bannerAd != null) {
      return Container(
        width: double.infinity,
        height: height,
        alignment: Alignment.center,
        color: context.bg,
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    }

    // 광고 로딩 중 또는 폴백 UI (완벽한 CLS 방지: 로드 전후 높이를 일치시킴)
    return Container(
      width: double.infinity,
      height: height,
      alignment: Alignment.center,
      color: context.bg,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Container(
        width: double.infinity,
        height: (height - 4).clamp(44.0, 60.0),
        decoration: BoxDecoration(
          color: context.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: context.surfaceBorder,
            width: 0.8,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'AD',
                  style: TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '3초 습관과 함께하는 생산적인 하루 ⚡️',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
