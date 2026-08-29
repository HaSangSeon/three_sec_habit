import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_constants.dart';
import '../utils/date_util.dart';

/// Google AdMob 광고 관리 서비스
class AdService {
  AdService._();

  static bool _isInitialized = false;
  static String _lastInterstitialShownDate = '';

  /// AdMob SDK 초기화
  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
    } catch (e) {
      debugPrint('AdMob initialization error: $e');
    }
  }

  /// 하단 배너 광고 생성
  static BannerAd? createBannerAd({
    required Function() onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) {
    if (!_isInitialized) return null;
    return BannerAd(
      adUnitId: AppConstants.testBannerAdId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onAdLoaded(),
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
          onAdFailedToLoad(error);
        },
      ),
    );
  }

  /// 하루 1회 전면 광고 노출 (통계 화면 진입 시 등)
  static void showInterstitialOncePerDay() {
    if (!_isInitialized) return;
    final todayStr = DateUtil.today();
    if (_lastInterstitialShownDate == todayStr) {
      // 오늘 이미 1회 노출되었으므로 과도한 노출 방지를 위해 스킵
      return;
    }

    try {
      InterstitialAd.load(
        adUnitId: AppConstants.testInterstitialAdId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _lastInterstitialShownDate = todayStr;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) => ad.dispose(),
              onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose(),
            );
            ad.show();
          },
          onAdFailedToLoad: (error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ),
      );
    } catch (e) {
      debugPrint('Error showing interstitial ad: $e');
    }
  }
}
