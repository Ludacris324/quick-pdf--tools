import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quick_pdf_tool/core/ads/ad_config.dart';

/// Central AdMob helper — banner slots live in [BannerAdSlot];
/// call [showInterstitialOnFileReady] after PDF/OCR/compress finishes.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;
  InterstitialAd? _interstitialAd;
  bool _isLoadingInterstitial = false;

  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isIos => !kIsWeb && Platform.isIOS;
  bool get supportsAds => isAndroid || isIos;

  Future<void> initialize() async {
    if (_initialized || !supportsAds) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    _preloadInterstitial();
  }

  String get bannerUnitId => AdConfig.bannerAdUnitId(isAndroid: isAndroid);

  String get interstitialUnitId =>
      AdConfig.interstitialAdUnitId(isAndroid: isAndroid);

  void _preloadInterstitial() {
    if (!supportsAds || _isLoadingInterstitial || _interstitialAd != null) {
      return;
    }
    _isLoadingInterstitial = true;

    InterstitialAd.load(
      adUnitId: interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoadingInterstitial = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _preloadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose();
              _interstitialAd = null;
              _preloadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (_) {
          _isLoadingInterstitial = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Show interstitial when export/OCR/compress completes (file is ready).
  Future<void> showInterstitialOnFileReady() async {
    if (!supportsAds) return;

    final ad = _interstitialAd;
    if (ad == null) {
      _preloadInterstitial();
      return;
    }

    await ad.show();
    _interstitialAd = null;
    _preloadInterstitial();
  }

  BannerAd createBannerAd({
    required void Function(BannerAd ad) onLoaded,
    required void Function(LoadAdError error) onFailed,
  }) {
    return BannerAd(
      adUnitId: bannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onLoaded(ad as BannerAd),
        onAdFailedToLoad: (_, error) => onFailed(error),
      ),
    )..load();
  }
}
