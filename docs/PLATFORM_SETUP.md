# إعداد المنصّات و AdMob

## 1) إنشاء مجلدات Android / iOS

من مجلد المشروع:

```bash
flutter create . --project-name quick_pdf_tool --org com.quickpdftool
flutter pub get
```

## 2) Android — AdMob + أذونات

في `android/app/src/main/AndroidManifest.xml` داخل `<application>`:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy"/>
```

قبل `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

في `android/app/build.gradle` تأكد من `minSdkVersion 24` أو أعلى لـ ML Kit.

## 3) iOS — AdMob + أذونات

في `ios/Runner/Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy</string>
<key>NSCameraUsageDescription</key>
<string>لالتقاط صور للتحويل أو OCR</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>لاختيار الصور وملفات PDF</string>
```

ثم:

```bash
cd ios && pod install
```

## 4) تفعيل إعلانات الإنتاج

في `lib/core/ads/ad_config.dart`:

- ضع معرّفات Banner و Interstitial الحقيقية.
- عيّن `useTestAds = false`.

Interstitial يُستدعى تلقائياً عند اكتمال: PDF، OCR، أو الضغط عبر `AdService.showInterstitialOnFileReady()`.
