import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:quick_pdf_tool/core/ads/ad_service.dart';
import 'package:quick_pdf_tool/core/theme/app_theme.dart';
import 'package:quick_pdf_tool/core/utils/file_utils.dart';
import 'package:quick_pdf_tool/core/utils/permission_service.dart';
import 'package:quick_pdf_tool/features/compress_pdf/data/pdf_compress_service.dart';
import 'package:quick_pdf_tool/shared/widgets/app_scaffold.dart';
import 'package:quick_pdf_tool/shared/widgets/primary_button.dart';
import 'package:quick_pdf_tool/shared/widgets/processing_overlay.dart';
import 'package:quick_pdf_tool/shared/widgets/result_panel.dart';
import 'package:share_plus/share_plus.dart';

class CompressPdfScreen extends StatefulWidget {
  const CompressPdfScreen({super.key});

  @override
  State<CompressPdfScreen> createState() => _CompressPdfScreenState();
}

class _CompressPdfScreenState extends State<CompressPdfScreen> {
  final _service = PdfCompressService();
  File? _sourcePdf;
  File? _compressedPdf;
  int? _originalBytes;
  int? _compressedBytes;
  bool _isProcessing = false;

  Future<void> _pickPdf() async {
    await PermissionService.ensureStorageForFiles();

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: false,
    );
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final size = await file.length();
    setState(() {
      _sourcePdf = file;
      _originalBytes = size;
      _compressedPdf = null;
      _compressedBytes = null;
    });
  }

  Future<void> _compress() async {
    final source = _sourcePdf;
    if (source == null) {
      _showMessage('اختر ملف PDF أولاً');
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final outcome = await _service.compress(source);
      if (!mounted) return;
      setState(() {
        _compressedPdf = outcome.file;
        _originalBytes = outcome.originalBytes;
        _compressedBytes = outcome.compressedBytes;
      });
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

  Future<void> _share() async {
    final file = _compressedPdf;
    if (file == null) return;
    await Share.shareXFiles([XFile(file.path)]);
  }

  String? get _savingsLabel {
    final original = _originalBytes;
    final compressed = _compressedBytes;
    if (original == null || compressed == null || original == 0) return null;
    final saved = ((1 - compressed / original) * 100).clamp(0, 100);
    return 'وفّرت ${saved.toStringAsFixed(0)}% من الحجم';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppScaffold(
          title: 'ضغط PDF',
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SectionHeader(
                title: 'ملف PDF',
                subtitle: 'اختر ملفاً ثم اضغط لتوليد نسخة أخف للمشاركة.',
              ),
              const SizedBox(height: 16),
              _PdfPickerCard(
                fileName: _sourcePdf?.path.split(Platform.pathSeparator).last,
                sizeLabel: _originalBytes != null
                    ? FileUtils.formatBytes(_originalBytes!)
                    : null,
                onPick: _pickPdf,
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'ضغط الملف',
                icon: Icons.compress_rounded,
                isLoading: _isProcessing,
                onPressed: _sourcePdf == null ? null : _compress,
              ),
              if (_compressedPdf != null) ...[
                const SizedBox(height: 24),
                FileResultPanel(
                  title: 'الملف جاهز',
                  subtitle: _savingsLabel ??
                      FileUtils.formatBytes(_compressedBytes ?? 0),
                  onShare: _share,
                  extra: _CompressionStats(
                    before: _originalBytes,
                    after: _compressedBytes,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_isProcessing)
          const ProcessingOverlay(message: 'جاري ضغط ملف PDF…'),
      ],
    );
  }
}

class _PdfPickerCard extends StatelessWidget {
  const _PdfPickerCard({
    required this.onPick,
    this.fileName,
    this.sizeLabel,
  });

  final VoidCallback onPick;
  final String? fileName;
  final String? sizeLabel;

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasFile ? Icons.insert_drive_file_rounded : Icons.upload_file_rounded,
                  color: hasFile ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasFile ? fileName! : 'لم يُختر ملف بعد',
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (sizeLabel != null) ...[
              const SizedBox(height: 8),
              Text(
                'الحجم الأصلي: $sizeLabel',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
            const SizedBox(height: 16),
            PrimaryButton(
              label: hasFile ? 'تغيير الملف' : 'اختيار PDF',
              icon: Icons.folder_open_rounded,
              onPressed: onPick,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompressionStats extends StatelessWidget {
  const _CompressionStats({
    required this.before,
    required this.after,
  });

  final int? before;
  final int? after;

  @override
  Widget build(BuildContext context) {
    if (before == null || after == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _StatChip(
            label: 'قبل',
            value: FileUtils.formatBytes(before!),
          ),
        ),
        const SizedBox(width: 10),
        const Icon(Icons.arrow_back, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            label: 'بعد',
            value: FileUtils.formatBytes(after!),
            highlight: true,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: highlight ? AppColors.primary : null,
                ),
          ),
        ],
      ),
    );
  }
}
