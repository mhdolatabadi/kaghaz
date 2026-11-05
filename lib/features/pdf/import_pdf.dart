import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../../core/theme.dart';
import '../library/notebook_dialog.dart';
import '../notebooks/notebook_screen.dart';
import 'pdf_service.dart';

/// Asks whether to add [pdf] to the notes, then imports it.
///
/// With [notebookId] the pages are appended to that notebook; otherwise a
/// new notebook is created in [folderId] and opened.
Future<void> offerPdfImport(
  BuildContext context,
  WidgetRef ref,
  PickedPdf pdf, {
  int? notebookId,
  int? folderId,
}) async {
  final List<PdfPageSize> sizes;
  try {
    sizes = await readPageSizes(pdf.bytes);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('این فایل PDF قابل خواندن نیست.')),
      );
    }
    return;
  }
  if (!context.mounted) return;

  final title = await showDialog<String>(
    context: context,
    builder: (_) => _ImportDialog(
      pdf: pdf,
      pageCount: sizes.length,
      appending: notebookId != null,
    ),
  );
  if (title == null || !context.mounted) return;

  final db = ref.read(databaseProvider);
  final count = ref.read(allNotebooksProvider).value?.length ?? 0;
  final id = await db.importPdf(
    name: title,
    bytes: pdf.bytes,
    pages: sizes,
    notebookId: notebookId,
    folderId: folderId,
    color: coverColors[count % coverColors.length].toARGB32(),
  );
  if (!context.mounted) return;
  if (notebookId == null) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NotebookScreen(notebookId: id)),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${fa(sizes.length)} صفحه از «${pdf.title}» اضافه شد.')),
    );
  }
}

class _ImportDialog extends StatefulWidget {
  const _ImportDialog({
    required this.pdf,
    required this.pageCount,
    required this.appending,
  });

  final PickedPdf pdf;
  final int pageCount;
  final bool appending;

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  late final _title = TextEditingController(text: widget.pdf.title);
  ui.Image? _preview;

  @override
  void initState() {
    super.initState();
    _renderPreview();
  }

  Future<void> _renderPreview() async {
    final doc = await PdfDocument.openData(Uint8List.fromList(widget.pdf.bytes));
    try {
      final page = doc.pages.first;
      final image = await page.renderForDisplay(
        width: 300,
        height: (300 * page.height / page.width).round(),
        fullWidth: 300,
        fullHeight: 300 * page.height / page.width,
        backgroundColor: 0xFFFFFFFF,
      );
      if (mounted) {
        setState(() => _preview = image);
      } else {
        image?.dispose();
      }
    } finally {
      await doc.dispose();
    }
  }

  @override
  void dispose() {
    _preview?.dispose();
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = _preview;
    return AlertDialog(
      title: Text(widget.appending ? 'افزودن صفحه‌های PDF' : 'افزودن به یادداشت‌ها؟'),
      content: SizedBox(
        width: 420,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 110,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant),
                boxShadow: floatingShadow,
              ),
              clipBehavior: Clip.antiAlias,
              child: preview == null
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : RawImage(image: preview, fit: BoxFit.contain),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.appending
                        ? '${fa(widget.pageCount)} صفحه به انتهای این دفترچه اضافه می‌شود و می‌توانید روی آن‌ها بنویسید.'
                        : 'این PDF به یک دفترچه تبدیل می‌شود: می‌توانید روی صفحه‌هایش بنویسید و بین آن‌ها صفحه‌ی خالی اضافه کنید.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.pdf.name}، ${fa(widget.pageCount)} صفحه',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (!widget.appending) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _title,
                      decoration: const InputDecoration(labelText: 'نام دفترچه'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('انصراف'),
        ),
        FilledButton.icon(
          onPressed: () {
            final title = _title.text.trim();
            Navigator.pop(context, title.isEmpty ? widget.pdf.title : title);
          },
          icon: const Icon(Icons.note_add_outlined, size: 18),
          label: Text(widget.appending ? 'افزودن' : 'افزودن به یادداشت‌ها'),
        ),
      ],
    );
  }
}
