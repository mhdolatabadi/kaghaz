import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaghaz/core/db/database.dart';
import 'package:kaghaz/features/ink/ink_model.dart';
import 'package:kaghaz/features/pdf/export_pdf.dart';
import 'package:kaghaz/features/pdf/pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  NotePage page(int position, PageKind kind, {String ink = '[]', String body = ''}) =>
      NotePage(
        id: position + 1,
        notebookId: 1,
        position: position,
        kind: kind,
        background: PageBackground.grid,
        ink: ink,
        body: body,
        width: defaultPageWidth,
        height: defaultPageHeight,
        updatedAt: DateTime(2026),
      );

  test('exports ink and text pages to a multi-page PDF', () async {
    final ink = InkDocument.encode([
      const Stroke(
        points: [InkPoint(10, 10, 0.2), InkPoint(200, 120, 0.9), InkPoint(300, 80, 0.5)],
        color: Color(0xFF1C64F2),
        width: 4,
      ),
      const Stroke(
        points: [InkPoint(10, 300), InkPoint(400, 300)],
        color: Color(0xFFFFE066),
        width: 18,
        highlighter: true,
        pressure: false,
      ),
    ]);
    final Uint8List bytes = await buildNotebookPdf(
      [page(0, PageKind.ink, ink: ink), page(1, PageKind.text, body: 'سلام دنیا')],
      PdfRenderer(AppDatabase(NativeDatabase.memory())),
    );
    final text = String.fromCharCodes(bytes);
    expect(text, startsWith('%PDF'));
    expect(RegExp(r'/Type\s*/Page[^s]').allMatches(text).length, 2);
  });
}
