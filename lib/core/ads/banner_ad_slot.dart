import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quick_pdf_tool/core/ads/ad_service.dart';
import 'package:quick_pdf_tool/core/theme/app_theme.dart';

/// Fixed banner slot at the bottom of feature screens.
/// Wire your AdMob banner unit via [AdConfig] / [AdService].
class BannerAdSlot extends StatefulWidget {
  const BannerAdSlot({super.key});

  @override
  State<BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends State<BannerAdSlot> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    if (!AdService.instance.supportsAds) return;

    final banner = AdService.instance.createBannerAd(
      onLoaded: (ad) {
        if (!mounted) return;
        setState(() {
          _bannerAd = ad;
          _isLoaded = true;
        });
      },
      onFailed: (_) {
        if (!mounted) return;
        setState(() => _isLoaded = false);
      },
    );
    _bannerAd = banner;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdService.instance.supportsAds) {
      return _placeholder(label: 'AdMob Banner — Android / iOS only');
    }

    if (!_isLoaded || _bannerAd == null) {
      return _placeholder(label: 'جاري تحميل الإعلان…');
    }

    final height = _bannerAd!.size.height.toDouble();

    return Container(
      width: double.infinity,
      height: height,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  Widget _placeholder({required String label}) {
    return Container(
      width: double.infinity,
      height: 50,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
    );
  }
}
