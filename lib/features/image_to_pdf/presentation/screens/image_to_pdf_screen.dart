import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quick_pdf_tool/core/ads/ad_service.dart';
import 'package:quick_pdf_tool/core/theme/app_theme.dart';
import 'package:quick_pdf_tool/core/utils/file_utils.dart';
import 'package:quick_pdf_tool/core/utils/permission_service.dart';
import 'package:quick_pdf_tool/features/image_to_pdf/data/image_to_pdf_service.dart';
import 'package:quick_pdf_tool/shared/widgets/app_scaffold.dart';
import 'package:quick_pdf_tool/shared/widgets/primary_button.dart';
import 'package:quick_pdf_tool/shared/widgets/processing_overlay.dart';
import 'package:quick_pdf_tool/shared/widgets/result_panel.dart';
import 'package:share_plus/share_plus.dart';

class ImageToPdfScreen extends StatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
  final _service = ImageToPdfService();
  final _picker = ImagePicker();
  final List<File> _images = [];
  File? _resultPdf;
  bool _isProcessing = false;

  Future<void> _pickImages(ImageSource source) async {
    final allowed = source == ImageSource.camera
        ? await PermissionService.ensureCamera()
        : await PermissionService.ensureGallery();
    if (!allowed) {
      _showMessage('يُرجى السماح بالوصول من إعدادات التطبيق');
      return;
    }

    if (source == ImageSource.gallery) {
      final picked = await _picker.pickMultiImage(imageQuality: 92);
      if (picked.isEmpty) return;
      setState(() {
        _images.addAll(picked.map((x) => File(x.path)));
        _resultPdf = null;
      });
      return;
    }

    final single = await _picker.pickImage(source: source, imageQuality: 92);
    if (single == null) return;
    setState(() {
      _images.add(File(single.path));
      _resultPdf = null;
    });
  }

  Future<void> _convert() async {
    if (_images.isEmpty) {
      _showMessage('أضف صورة واحدة على الأقل');
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final pdf = await _service.createPdfFromImages(_images);
      if (!mounted) return;
      setState(() => _resultPdf = pdf);
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

  Future<void> _sharePdf() async {
    final file = _resultPdf;
    if (file == null) return;
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'ملف PDF من Quick PDF Tool',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppScaffold(
          title: 'صور → PDF',
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SectionHeader(
                title: 'الصور المختارة',
                subtitle: 'يمكنك إضافة عدة صور؛ كل صورة ستصبح صفحة في PDF.',
              ),
              const SizedBox(height: 16),
              if (_images.isEmpty)
                _EmptyPicker(
                  onGallery: () => _pickImages(ImageSource.gallery),
                  onCamera: () => _pickImages(ImageSource.camera),
                )
              else ...[
                _ImageGrid(
                  images: _images,
                  onRemove: (index) {
                    setState(() {
                      _images.removeAt(index);
                      _resultPdf = null;
                    });
                  },
                ),
                const SizedBox(height: 14),
                GhostButton(
                  label: 'إضافة المزيد من المعرض',
                  icon: Icons.add_photo_alternate_outlined,
                  onPressed: () => _pickImages(ImageSource.gallery),
                ),
              ],
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'إنشاء PDF',
                icon: Icons.picture_as_pdf_rounded,
                isLoading: _isProcessing,
                onPressed: _images.isEmpty ? null : _convert,
              ),
              if (_resultPdf != null) ...[
                const SizedBox(height: 24),
                FutureBuilder<int>(
                  future: _resultPdf!.length(),
                  builder: (context, snapshot) {
                    final sizeLabel = snapshot.hasData
                        ? FileUtils.formatBytes(snapshot.data!)
                        : '…';
                    return FileResultPanel(
                      title: 'تم إنشاء الملف',
                      subtitle: '${_resultPdf!.path.split(Platform.pathSeparator).last} • $sizeLabel',
                      onShare: _sharePdf,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        if (_isProcessing)
          const ProcessingOverlay(message: 'جاري تحويل الصور إلى PDF…'),
      ],
    );
  }
}

class _EmptyPicker extends StatelessWidget {
  const _EmptyPicker({
    required this.onGallery,
    required this.onCamera,
  });

  final VoidCallback onGallery;
  final VoidCallback onCamera;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 12),
          Text(
            'لم تُختر صور بعد',
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

class _ImageGrid extends StatelessWidget {
  const _ImageGrid({
    required this.images,
    required this.onRemove,
  });

  final List<File> images;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(images[index], fit: BoxFit.cover),
            ),
            Positioned(
              top: 4,
              left: 4,
              child: Material(
                color: AppColors.background.withValues(alpha: 0.75),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => onRemove(index),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close_rounded, size: 16),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
