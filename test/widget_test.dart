import 'package:flutter_test/flutter_test.dart';
import 'package:quick_pdf_tool/app.dart';

void main() {
  testWidgets('app loads home', (tester) async {
    await tester.pumpWidget(const QuickPdfApp());
    expect(find.text('Quick PDF Tool'), findsOneWidget);
    expect(find.text('صور → PDF'), findsOneWidget);
  });
}
