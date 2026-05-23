import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quick_pdf_tool/core/ads/ad_service.dart';
import 'package:quick_pdf_tool/core/theme/app_theme.dart';
import 'package:quick_pdf_tool/core/utils/permission_service.dart';
import 'package:quick_pdf_tool/features/ocr/data/ocr_service.dart';
import 'package:quick_pdf_tool/shared/widgets/app_scaffold.dart';
import 'package:quick_pdf_tool/shared/widgets/primary_button.dart';
import 'package:quick_pdf_tool/shared/widgets/processing_overlay.dart';
import 'package:quick_pdf_tool/shared/widgets/result_panel.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  final _service = OcrService();
  final _picker = ImagePicker();
  File? _image;
  String? _extractedText;
  bool _isProcessing = false;

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final allowed = source == ImageSource.camera
        ? await PermissionService.ensureCamera()
        : await PermissionService.ensureGallery();
    if (!allowed) {
      _showMessage('يُرجى السماح بالوصول من إعدادات التطبيق');
      return;
    }

    final picked = await _picker.pickImage(source: source, imageQuality: 95);
    if (picked == null) return;
    setState(() {
      _image = File(picked.path);
      _extractedText = null;
    });
  }

  Future<void> _runOcr() async {
    final image = _image;
    if (image == null) {
      _showMessage('اختر صورة تحتوي على نص');
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final text = await _service.extractTextFromImage(image);
      if (!mounted) return;
      setState(() => _extractedText = text);
      await AdService.instance.showInterstitialOnFileReady();
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppScaffold(
          title: 'استخراج النص (OCR)',
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SectionHeader(
                title: 'صورة تحتوي نصاً',
                subtitle:
                    'يعمل على الجهاز عبر Google ML Kit — مناسب للمستندات والإيصالات.',
              ),
              const SizedBox(height: 16),
              if (_image == null)
                _OcrEmptyState(
                  onGallery: () => _pick(ImageSource.gallery),
                  onCamera: () => _pick(ImageSource.camera),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.file(_image!, fit: BoxFit.cover),
                  ),
                ),
              const SizedBox(height: 16),
              if (_image != null)
                GhostButton(
                  label: 'تغيير الصورة',
                  icon: Icons.swap_horiz_rounded,
                  onPressed: () => _pick(ImageSource.gallery),
                ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'استخراج النص',
                icon: Icons.text_fields_rounded,
                isLoading: _isProcessing,
                onPressed: _image == null ? null : _runOcr,
              ),
              if (_extractedText != null) ...[
                const SizedBox(height: 24),
                TextResultPanel(text: _extractedText!),
              ],
            ],
          ),
        ),
        if (_isProcessing)
          const ProcessingOverlay(message: 'جاري قراءة النص من الصورة…'),
      ],
    );
  }
}

class _OcrEmptyState extends StatelessWidget {
  const _OcrEmptyState({
    required this.onGallery,
    required this.onCamera,
  });

  final VoidCallback onGallery;
  final VoidCallback onCamera;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.document_scanner_outlined,
            size: 48,
            color: AppColors.accent,
          ),
          const SizedBox(height: 12),
          Text(
            'التقط أو اختر صورة',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'من المعرض',
            icon: Icons.photo_outlined,
            onPressed: onGallery,
          ),
          const SizedBox(height: 10),
          GhostButton(
            label: 'من الكاميرا',
            icon: Icons.camera_alt_outlined,
            onPressed: onCamera,
          ),
        ],
      ),
    );
  }
}
