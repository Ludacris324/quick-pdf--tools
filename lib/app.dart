import 'package:flutter/material.dart';
import 'package:quick_pdf_tool/core/constants/app_constants.dart';
import 'package:quick_pdf_tool/core/theme/app_theme.dart';
import 'package:quick_pdf_tool/features/home/presentation/screens/home_screen.dart';

class QuickPdfApp extends StatelessWidget {
  const QuickPdfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      locale: const Locale('ar'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomeScreen(),
    );
  }
}
