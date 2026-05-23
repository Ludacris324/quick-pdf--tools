# Quick PDF Tool

تطبيق Flutter **مستقل تماماً** عن مشروع إدارة الأسطول (`adarat-al-ustool-admin`).

| | |
|---|---|
| **هذا التطبيق** | أدوات PDF: صور → PDF، OCR، ضغط |
| **إدارة الأسطول** | مشروع منفصل في `../adarat-al-ustool-admin` |

يوفّر واجهة Dark Mode عربية (RTL) وأماكن جاهزة لإعلانات **Google AdMob**.

## المتطلبات

- Flutter 3.24+ / Dart 3.5+
- Android: `minSdk 24` (ML Kit)
- iOS 13+

## التشغيل

```bash
cd d:\ntn\.github\quick_pdf_tool
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
packages/file_compression_plus/   # ضغط PDF (نسخة Dart محلية)
```

## ربط AdMob

1. **`lib/core/ads/ad_config.dart`** — ضع معرّفات الإنتاج وعطّل `useTestAds`.
2. **`lib/core/ads/ad_service.dart`** — تحميل وعرض Interstitial عند جاهزية الملف.
3. **`lib/core/ads/banner_ad_slot.dart`** — بانر ثابت أسفل شاشات الأدوات.
4. **Android** — `android/app/src/main/AndroidManifest.xml`.
5. **iOS** — `ios/Runner/Info.plist`.

معرّفات الاختبار الرسمية من Google مفعّلة افتراضياً.

## الحزم المستخدمة

| الميزة | الحزمة |
|--------|--------|
| PDF من صور | `pdf` |
| OCR | `google_mlkit_text_recognition` |
| ضغط PDF | `file_compression_plus` (محلي) |
| إعلانات | `google_mobile_ads` |
| مشاركة | `share_plus` |
| صلاحيات | `permission_handler` |

## ملاحظات

- OCR يعمل على **Android و iOS** فقط.
- ضغط PDF يعتمد على Syncfusion عبر `file_compression_plus` — راجع ترخيص Syncfusion للإنتاج التجاري.
- راجع `docs/PLATFORM_SETUP.md` لإعداد المنصّات.

## GitHub

```bash
gh auth login
gh repo create quick_pdf_tool --public --source=. --remote=origin --push
```
