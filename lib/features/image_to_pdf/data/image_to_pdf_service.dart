import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:quick_pdf_tool/core/utils/file_utils.dart';

class ImageToPdfService {
  Future<File> createPdfFromImages(List<File> images) async {
    if (images.isEmpty) {
      throw ArgumentError('اختر صورة واحدة على الأقل');
    }

    final doc = pw.Document();
    for (final imageFile in images) {
      final bytes = await imageFile.readAsBytes();
      final image = pw.MemoryImage(bytes);
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Center(
            child: pw.FittedBox(
              fit: pw.BoxFit.contain,
              child: pw.Image(image),
            ),
          ),
        ),
      );
    }

    final output = await FileUtils.uniqueOutputFile(
      prefix: 'images_to_pdf',
      extension: 'pdf',
    );
    await output.writeAsBytes(await doc.save());
    return output;
  }
}
