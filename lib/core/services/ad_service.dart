import 'package:flutter/foundation.dart';
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

  /// 배너 광고 단위 ID (릴리즈 시 실제 AdMob ID, 디버그 시 테스트 ID)
  static String get bannerAdUnitId =>
      kReleaseMode ? AppConstants.realBannerAdId : AppConstants.testBannerAdId;

  /// 하단 배너 광고 생성 (기본 320x50)
  static BannerAd? createBannerAd({
    required Function() onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) {
    if (!_isInitialized) return null;
    return BannerAd(
      adUnitId: bannerAdUnitId,
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

  /// 가로 100% 화면 맞춤형 적응형(Adaptive) 배너 광고 생성
  static Future<BannerAd?> createAdaptiveBannerAd({
    required int width,
    required Function() onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) async {
    if (!_isInitialized) return null;
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (size == null) return null;

    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onAdLoaded(),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Adaptive BannerAd failed to load: $error');
          ad.dispose();
          onAdFailedToLoad(error);
        },
      ),
    );
  }

  /// 전면 광고 단위 ID (릴리즈 시 실제 AdMob ID, 디버그 시 테스트 ID)
  static String get interstitialAdUnitId =>
      kReleaseMode ? AppConstants.realInterstitialAdId : AppConstants.testInterstitialAdId;

  /// 오늘의 모든 습관 올 클리어(100% 달성) 시 하루 딱 1회 기분 좋게 전면 광고 노출
  static void showAllClearInterstitialAd() {
    if (!_isInitialized) return;
    final todayStr = DateUtil.today();
    if (_lastInterstitialShownDate == todayStr) {
      // 오늘 이미 올클리어 전면 광고를 시청했으므로 과도한 피로도 방지를 위해 스킵 (하루 1회 엄격 제한)
      return;
    }

    try {
      InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
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
            debugPrint('All-Clear InterstitialAd failed to load: $error');
          },
        ),
      );
    } catch (e) {
      debugPrint('Error showing all-clear interstitial ad: $e');
    }
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
        adUnitId: interstitialAdUnitId,
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
