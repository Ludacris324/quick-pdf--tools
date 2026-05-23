import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_pdf_tool/core/theme/app_theme.dart';
import 'package:quick_pdf_tool/shared/widgets/primary_button.dart';

class FileResultPanel extends StatelessWidget {
  const FileResultPanel({
    required this.title,
    required this.subtitle,
    required this.onShare,
    this.extra,
    super.key,
  });

  final String title;
  final String subtitle;
  final VoidCallback onShare;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (extra != null) ...[
              const SizedBox(height: 16),
              extra!,
            ],
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'مشاركة / فتح',
              icon: Icons.ios_share_rounded,
              onPressed: onShare,
            ),
          ],
        ),
      ),
    );
  }
}

class TextResultPanel extends StatelessWidget {
  const TextResultPanel({
    required this.text,
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.text_snippet_rounded, color: AppColors.accent),
                const SizedBox(width: 10),
                Text(
                  'النص المستخرج',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'نسخ',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم نسخ النص')),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 280),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.55,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
