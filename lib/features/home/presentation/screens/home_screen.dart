import 'package:flutter/material.dart';
import 'package:quick_pdf_tool/core/constants/app_constants.dart';
import 'package:quick_pdf_tool/core/theme/app_theme.dart';
import 'package:quick_pdf_tool/features/compress_pdf/presentation/screens/compress_pdf_screen.dart';
import 'package:quick_pdf_tool/features/home/presentation/widgets/feature_card.dart';
import 'package:quick_pdf_tool/features/image_to_pdf/presentation/screens/image_to_pdf_screen.dart';
import 'package:quick_pdf_tool/features/ocr/presentation/screens/ocr_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf_rounded,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppConstants.appName,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              Text(
                                'أدوات PDF سريعة — بدون تعقيد',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'اختر الأداة',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'كل الأدوات تعمل على جهازك مع واجهة مظلمة مريحة للعين.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
              sliver: SliverList.separated(
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return FeatureCard(
                        title: 'صور → PDF',
                        description: 'حوّل صور متعددة إلى ملف PDF واحد جاهز للمشاركة.',
                        icon: Icons.photo_library_rounded,
                        gradient: const [
                          Color(0xFF3B4FD8),
                          Color(0xFF1E2A6B),
                        ],
                        onTap: () => _open(context, const ImageToPdfScreen()),
                      );
                    case 1:
                      return FeatureCard(
                        title: 'استخراج النص (OCR)',
                        description: 'اقرأ النص من الصور باستخدام Google ML Kit.',
                        icon: Icons.document_scanner_rounded,
                        gradient: const [
                          Color(0xFF0E7490),
                          Color(0xFF134E4A),
                        ],
                        onTap: () => _open(context, const OcrScreen()),
                      );
                    default:
                      return FeatureCard(
                        title: 'ضغط PDF',
                        description: 'قلّل حجم ملف PDF مع الحفاظ على جودة مقبولة.',
                        icon: Icons.compress_rounded,
                        gradient: const [
                          Color(0xFF7C3AED),
                          Color(0xFF4C1D95),
                        ],
                        onTap: () => _open(context, const CompressPdfScreen()),
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
