import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pdf_service.dart';

/// Draws one PDF page, filling its box. Shows plain white until rendered.
class PdfPageView extends ConsumerStatefulWidget {
  const PdfPageView({
    super.key,
    required this.pdfId,
    required this.page,
    required this.pixelWidth,
  });

  final int pdfId;
  final int page;

  /// Resolution to render at; higher is sharper when zoomed in.
  final int pixelWidth;

  @override
  ConsumerState<PdfPageView> createState() => _PdfPageViewState();
}

class _PdfPageViewState extends ConsumerState<PdfPageView> {
  ui.Image? _image;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(PdfPageView old) {
    super.didUpdateWidget(old);
    if (old.pdfId != widget.pdfId ||
        old.page != widget.page ||
        old.pixelWidth != widget.pixelWidth) {
      _load();
    }
  }

  Future<void> _load() async {
    final key = (widget.pdfId, widget.page, widget.pixelWidth);
    try {
      final image = await ref
          .read(pdfRendererProvider)
          .render(widget.pdfId, widget.page, widget.pixelWidth);
      if (!mounted || key != (widget.pdfId, widget.page, widget.pixelWidth)) return;
      setState(() {
        _image?.dispose();
        // The renderer may evict and dispose its copy; keep our own.
        _image = image?.clone();
        _failed = image == null;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return const ColoredBox(
        color: Colors.white,
        child: Center(child: Icon(Icons.broken_image_outlined, color: Colors.black26)),
      );
    }
    return RawImage(image: _image, fit: BoxFit.fill, filterQuality: FilterQuality.medium);
  }
}
