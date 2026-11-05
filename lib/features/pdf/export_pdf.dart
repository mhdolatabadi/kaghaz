import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../ink/ink_model.dart';
import '../ink/ink_painter.dart' show PaperPainter;
import 'pdf_service.dart';

/// PDF points per logical page unit: a default page becomes A4 (595pt wide).
const _pointsPerUnit = 595.28 / defaultPageWidth;

/// Builds a PDF of the notebook, with ink as vector paths, and hands it to
/// the platform to share (Android) or download (web).
Future<void> exportNotebookPdf(
  BuildContext context,
  WidgetRef ref,
  int notebookId,
) async {
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(
    const SnackBar(content: Text('در حال ساختن PDF…'), duration: Duration(seconds: 30)),
  );
  try {
    final db = ref.read(databaseProvider);
    final notebook = await db.watchNotebook(notebookId).first;
    final pages = await db.getPages(notebookId);
    final bytes = await buildNotebookPdf(pages, ref.read(pdfRendererProvider));
    messenger.hideCurrentSnackBar();
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${notebook?.title ?? 'kaghaz'}.pdf',
    );
  } catch (e) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('ساختن PDF ناموفق بود: $e')));
  }
}

Future<Uint8List> buildNotebookPdf(List<NotePage> pages, PdfRenderer renderer) async {
  final font = pw.Font.ttf(await rootBundle.load('assets/fonts/Vazirmatn-Regular.ttf'));
  final doc = pw.Document(title: 'Kaghaz');
  for (final page in pages) {
    final w = page.width * _pointsPerUnit;
    final h = page.height * _pointsPerUnit;

    pw.ImageProvider? underlay;
    if (page.pdfId case final pdfId?) {
      // Raster at 2x the page's logical width; the original vector content of
      // imported pages is not carried over.
      final image = (await renderer.render(pdfId, page.pdfPage ?? 0, (page.width * 2).round()))
          ?.clone();
      final png = await image?.toByteData(format: ui.ImageByteFormat.png);
      image?.dispose();
      if (png != null) underlay = pw.MemoryImage(png.buffer.asUint8List());
    }
    final strokes = page.kind == PageKind.ink ? InkDocument.decode(page.ink) : const <Stroke>[];

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat(w, h),
      margin: pw.EdgeInsets.zero,
      build: (_) => pw.Stack(children: [
        if (underlay != null)
          pw.Positioned.fill(child: pw.Image(underlay, fit: pw.BoxFit.fill)),
        pw.CustomPaint(
          size: PdfPoint(w, h),
          painter: (canvas, size) {
            _paintPaper(canvas, page, h);
            for (final s in strokes) {
              _paintStroke(canvas, s, h);
            }
          },
        ),
        if (page.kind == PageKind.text)
          pw.Padding(
            padding: const pw.EdgeInsets.all(48),
            child: pw.Text(
              page.body,
              textDirection: pw.TextDirection.rtl,
              style: pw.TextStyle(font: font, fontSize: 12, lineSpacing: 6),
            ),
          ),
      ]),
    ));
  }
  return doc.save();
}

PdfColor _color(Color c) => PdfColor.fromInt(c.toARGB32());

void _paintPaper(PdfGraphics canvas, NotePage page, double h) {
  const spacing = PaperPainter.spacing * _pointsPerUnit;
  final w = page.width * _pointsPerUnit;
  canvas
    ..setStrokeColor(PdfColor.fromInt(0xFFDCE0EA))
    ..setLineWidth(0.5);
  switch (page.background) {
    case PageBackground.blank:
      return;
    case PageBackground.lined:
      for (var y = spacing * 2; y < h; y += spacing) {
        canvas
          ..moveTo(0, h - y)
          ..lineTo(w, h - y);
      }
    case PageBackground.grid:
      for (var y = spacing; y < h; y += spacing) {
        canvas
          ..moveTo(0, h - y)
          ..lineTo(w, h - y);
      }
      for (var x = spacing; x < w; x += spacing) {
        canvas
          ..moveTo(x, 0)
          ..lineTo(x, h);
      }
    case PageBackground.dotted:
      canvas.setFillColor(PdfColor.fromInt(0xFFC9CED8));
      for (var y = spacing; y < h; y += spacing) {
        for (var x = spacing; x < w; x += spacing) {
          canvas.drawEllipse(x, h - y, 0.8, 0.8);
        }
      }
      canvas.fillPath();
      return;
  }
  canvas.strokePath();
}

void _paintStroke(PdfGraphics canvas, Stroke stroke, double h) {
  final pts = [
    for (final p in stroke.points) (p.x * _pointsPerUnit, h - p.y * _pointsPerUnit, p.pressure),
  ];
  if (pts.isEmpty) return;
  canvas
    ..saveContext()
    ..setStrokeColor(_color(stroke.color))
    ..setLineCap(stroke.highlighter ? PdfLineCap.butt : PdfLineCap.round)
    ..setLineJoin(PdfLineJoin.round);
  if (stroke.highlighter) {
    canvas.setGraphicState(const PdfGraphicState(opacity: 0.4));
  }
  final width = stroke.width * _pointsPerUnit;

  if (pts.length == 1) {
    canvas
      ..setFillColor(_color(stroke.color))
      ..drawEllipse(pts[0].$1, pts[0].$2, width / 2, width / 2)
      ..fillPath()
      ..restoreContext();
    return;
  }
  if (stroke.pressure && !stroke.highlighter) {
    // Same width curve as the on-screen painter, one segment at a time.
    for (var i = 1; i < pts.length; i++) {
      canvas
        ..setLineWidth(width * (0.4 + 0.9 * pts[i].$3))
        ..moveTo(pts[i - 1].$1, pts[i - 1].$2)
        ..lineTo(pts[i].$1, pts[i].$2)
        ..strokePath();
    }
  } else {
    canvas
      ..setLineWidth(width)
      ..moveTo(pts[0].$1, pts[0].$2);
    for (final p in pts.skip(1)) {
      canvas.lineTo(p.$1, p.$2);
    }
    canvas.strokePath();
  }
  canvas.restoreContext();
}
