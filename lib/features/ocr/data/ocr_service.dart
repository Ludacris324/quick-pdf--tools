import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _recognizer = TextRecognizer();

  Future<String> extractTextFromImage(File imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final recognized = await _recognizer.processImage(inputImage);
    final text = recognized.text.trim();
    if (text.isEmpty) {
      throw StateError('لم يتم العثور على نص في الصورة');
    }
    return text;
  }

  void dispose() => _recognizer.close();
}
