import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
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
    if (kIsWeb || AppConstants.hideAdsForScreenshot) return;
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
    if (AppConstants.hideAdsForScreenshot) {
      return const SizedBox.shrink();
    }

    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    final height = _bannerAd!.size.height.toDouble();

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
}
