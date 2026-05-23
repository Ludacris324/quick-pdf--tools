# Quick PDF Tool

تطبيق Flutter يوفّر ثلاث أدوات: **صور → PDF**، **OCR**، و**ضغط PDF** — مع واجهة Dark Mode عربية (RTL) وأماكن جاهزة لإعلانات **Google AdMob**.

## المتطلبات

- Flutter 3.24+ / Dart 3.5+
- Android: `minSdk 21` (يُفضّل 24+ لـ ML Kit)
- iOS 13+

## التشغيل

```bash
cd quick_pdf_tool
flutter pub get
flutter run
```

## هيكل المشروع

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── ads/          # AdMob: AdConfig, AdService, BannerAdSlot
│   ├── constants/
│   ├── theme/        # Dark theme + ألوان
│   └── utils/
├── features/
│   ├── home/
│   ├── image_to_pdf/ # data + presentation
│   ├── ocr/
│   └── compress_pdf/
└── shared/widgets/
```

## ربط AdMob

1. **`lib/core/ads/ad_config.dart`** — ضع معرّفات الإنتاج وعطّل `useTestAds`.
2. **`lib/core/ads/ad_service.dart`** — تحميل وعرض Interstitial عند جاهزية الملف (`showInterstitialOnFileReady`).
3. **`lib/core/ads/banner_ad_slot.dart`** — بانر ثابت أسفل شاشات الأدوات عبر `AppScaffold`.
4. **Android** — `android/app/src/main/AndroidManifest.xml` (APPLICATION_ID).
5. **iOS** — `ios/Runner/Info.plist` (`GADApplicationIdentifier`).

معرّفات الاختبار الرسمية من Google مفعّلة افتراضياً.

## الحزم المستخدمة

| الميزة | الحزمة |
|--------|--------|
| PDF من صور | `pdf` |
| OCR | `google_mlkit_text_recognition` |
| ضغط PDF | `file_compression_plus` |
| إعلانات | `google_mobile_ads` |
| مشاركة | `share_plus` |
| خطوط/UI | `google_fonts` |

## ملاحظات

- OCR يعمل على **Android و iOS** (ليس الويب).
- ضغط PDF يعتمد على Syncfusion داخل `file_compression_plus` — راجع ترخيص Syncfusion للإنتاج التجاري.
- أضف أذونات الكاميرا/المعرض في المنصّة قبل النشر.
