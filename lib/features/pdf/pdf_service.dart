import 'dart:async';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../core/db/database.dart';
import '../../core/db/providers.dart';

/// A PDF chosen by the user or handed to the app by the system.
class PickedPdf {
  const PickedPdf(this.name, this.bytes);

  final String name;
  final Uint8List bytes;

  /// The file name without its extension, used as a notebook title.
  String get title {
    final dot = name.toLowerCase().lastIndexOf('.pdf');
    return dot > 0 ? name.substring(0, dot) : name;
  }
}

Future<PickedPdf?> pickPdf() async {
  final file = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: const ['pdf'],
  );
  if (file == null) return null;
  return PickedPdf(file.name, await file.readAsBytes());
}

/// Page sizes in PDF points. Throws when [bytes] is not a readable PDF.
Future<List<PdfPageSize>> readPageSizes(Uint8List bytes) async {
  final doc = await PdfDocument.openData(Uint8List.fromList(bytes));
  try {
    return [for (final p in doc.pages) PdfPageSize(p.width, p.height)];
  } finally {
    await doc.dispose();
  }
}

/// PDFs that Android hands over through "Open with" or "Share".
///
/// The platform side lives in MainActivity.kt; other platforms never emit.
class OpenedFiles {
  OpenedFiles() {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'fileOpened') _emit(call.arguments);
    });
    _channel
        .invokeMethod<Object?>('takeInitialFile')
        .then(_emit, onError: (_) {});
  }

  static const _channel = MethodChannel('kaghaz/opened_files');
  final _controller = StreamController<PickedPdf>.broadcast();
  PickedPdf? _initial;

  Stream<PickedPdf> get stream => _controller.stream;

  /// A file that arrived before anyone listened; returned once.
  PickedPdf? takeInitial() {
    final file = _initial;
    _initial = null;
    return file;
  }

  void _emit(Object? args) {
    if (args is! Map) return;
    final bytes = args['bytes'];
    if (bytes is! Uint8List) return;
    final file = PickedPdf(args['name'] as String? ?? 'document.pdf', bytes);
    if (_controller.hasListener) {
      _controller.add(file);
    } else {
      _initial = file;
    }
  }
}

final openedFilesProvider = Provider<OpenedFiles>((ref) => OpenedFiles());

/// Opens stored PDFs once and renders their pages to images, keeping the
/// most recent renders in memory.
class PdfRenderer {
  PdfRenderer(this._db);

  final AppDatabase _db;
  final _docs = <int, Future<PdfDocument>>{};
  final _images = <String, Future<ui.Image?>>{}; // Insertion order is LRU order.
  static const _maxImages = 24;

  Future<PdfDocument> _document(int pdfId) => _docs.putIfAbsent(pdfId, () async {
        final file = await _db.getPdf(pdfId);
        return PdfDocument.openData(Uint8List.fromList(file.bytes));
      });

  /// Renders page [pageIndex] at [pixelWidth] pixels wide.
  Future<ui.Image?> render(int pdfId, int pageIndex, int pixelWidth) {
    final key = '$pdfId:$pageIndex:$pixelWidth';
    final cached = _images.remove(key);
    if (cached != null) return _images[key] = cached;

    final future = () async {
      final doc = await _document(pdfId);
      if (pageIndex >= doc.pages.length) return null;
      final page = doc.pages[pageIndex];
      final height = (pixelWidth * page.height / page.width).round();
      return page.renderForDisplay(
        width: pixelWidth,
        height: height,
        fullWidth: pixelWidth.toDouble(),
        fullHeight: height.toDouble(),
        backgroundColor: 0xFFFFFFFF,
      );
    }();
    _images[key] = future;
    while (_images.length > _maxImages) {
      final oldest = _images.keys.first;
      _images.remove(oldest)!.then((image) => image?.dispose());
    }
    return future;
  }

  void dispose() {
    for (final image in _images.values) {
      image.then((i) => i?.dispose());
    }
    for (final doc in _docs.values) {
      doc.then((d) => d.dispose());
    }
  }
}

final pdfRendererProvider = Provider<PdfRenderer>((ref) {
  final renderer = PdfRenderer(ref.watch(databaseProvider));
  ref.onDispose(renderer.dispose);
  return renderer;
});
