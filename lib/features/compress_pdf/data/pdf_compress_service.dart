import 'dart:io';

import 'package:file_compression_plus/file_compression_plus.dart';
import 'package:quick_pdf_tool/core/utils/file_utils.dart';

class PdfCompressService {
  Future<({File file, int originalBytes, int compressedBytes})> compress(
    File source,
  ) async {
    final originalBytes = await source.length();
    if (originalBytes == 0) {
      throw StateError('ملف PDF فارغ');
    }

    final tempCompressed = await FileCompressor.compressPdf(
      file: source,
      compressionLevel: PdfCompressionLevel.best,
    );

    final output = await FileUtils.uniqueOutputFile(
      prefix: 'compressed_pdf',
      extension: 'pdf',
    );
    await tempCompressed.copy(output.path);
    final compressedBytes = await output.length();

    return (
      file: output,
      originalBytes: originalBytes,
      compressedBytes: compressedBytes,
    );
  }
}
