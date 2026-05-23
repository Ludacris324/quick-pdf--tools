import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_pdf_tool/app.dart';
import 'package:quick_pdf_tool/core/ads/ad_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0B0F14),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await AdService.instance.initialize();

  runApp(const QuickPdfApp());
}
