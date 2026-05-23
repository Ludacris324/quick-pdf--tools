/// Google AdMob configuration — replace test IDs before release.
///
/// 1. Create app in [AdMob Console](https://apps.admob.com/).
/// 2. Add `com.google.android.gms.ads.APPLICATION_ID` in AndroidManifest.
/// 3. Add `GADApplicationIdentifier` in iOS Info.plist.
/// 4. Swap [bannerAdUnitId] and [interstitialAdUnitId] with your production units.
class AdConfig {
  AdConfig._();

  /// Set to `false` when you wire real ad unit IDs and ship to stores.
  static const bool useTestAds = true;

  // ——— Android ———
  static const String _androidBannerTest =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _androidInterstitialTest =
      'ca-app-pub-3940256099942544/1033173712';

  // ——— iOS ———
  static const String _iosBannerTest =
      'ca-app-pub-3940256099942544/2934735716';
  static const String _iosInterstitialTest =
      'ca-app-pub-3940256099942544/4411468910';

  // TODO(admob): Production banner — Android
  // static const String _androidBannerProd = 'ca-app-pub-XXXXXXXX/YYYYYYYYYY';
  // TODO(admob): Production interstitial — Android
  // static const String _androidInterstitialProd = 'ca-app-pub-XXXXXXXX/ZZZZZZZZZZ';

  // TODO(admob): Production banner — iOS
  // static const String _iosBannerProd = 'ca-app-pub-XXXXXXXX/YYYYYYYYYY';
  // TODO(admob): Production interstitial — iOS
  // static const String _iosInterstitialProd = 'ca-app-pub-XXXXXXXX/ZZZZZZZZZZ';

  static String bannerAdUnitId({required bool isAndroid}) {
    if (useTestAds) {
      return isAndroid ? _androidBannerTest : _iosBannerTest;
    }
    // return isAndroid ? _androidBannerProd : _iosBannerProd;
    throw UnimplementedError('Set production banner ad unit IDs in AdConfig');
  }

  static String interstitialAdUnitId({required bool isAndroid}) {
    if (useTestAds) {
      return isAndroid ? _androidInterstitialTest : _iosInterstitialTest;
    }
    // return isAndroid ? _androidInterstitialProd : _iosInterstitialProd;
    throw UnimplementedError(
      'Set production interstitial ad unit IDs in AdConfig',
    );
  }
}
