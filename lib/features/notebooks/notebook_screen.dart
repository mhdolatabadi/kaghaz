import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../../core/widgets/dialogs.dart';
import '../editor/page_editor_screen.dart';
import '../ink/ink_canvas.dart';
import '../ink/ink_model.dart';
import '../ink/ink_painter.dart';

/// The pages of one notebook as a grid of thumbnails.
class NotebookScreen extends ConsumerWidget {
  const NotebookScreen({super.key, required this.notebookId});

  final int notebookId;

  void _open(BuildContext context, List<NotePage> pages, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PageEditorScreen(
          pageIds: [for (final p in pages) p.id],
          initialIndex: index,
        ),
      ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref, PageKind kind) async {
    final db = ref.read(databaseProvider);
    final id = await db.addPage(notebookId, kind);
    final pages = await db.watchPages(notebookId).first;
    if (!context.mounted) return;
    _open(context, pages, pages.indexWhere((p) => p.id == id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notebook = ref.watch(notebookProvider(notebookId)).value;
    final pages = ref.watch(pagesProvider(notebookId));
    return Scaffold(
      appBar: AppBar(title: Text(notebook?.title ?? '')),
      floatingActionButton: MenuAnchor(
        menuChildren: [
          MenuItemButton(
            leadingIcon: const Icon(Icons.draw_outlined),
            onPressed: () => _add(context, ref, PageKind.ink),
            child: const Text('صفحه‌ی دست‌نویس'),
          ),
          MenuItemButton(
            leadingIcon: const Icon(Icons.notes),
            onPressed: () => _add(context, ref, PageKind.text),
            child: const Text('صفحه‌ی متنی'),
          ),
        ],
        builder: (context, menu, _) => FloatingActionButton(
          tooltip: 'صفحه‌ی جدید',
          onPressed: () => menu.isOpen ? menu.close() : menu.open(),
          child: const Icon(Icons.add),
        ),
      ),
      body: pages.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
        data: (list) => LayoutBuilder(builder: (context, constraints) {
          final columns = math.max(2, constraints.maxWidth ~/ 200);
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: pageSize.width / (pageSize.height + 140),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: list.length,
            itemBuilder: (context, i) => _PageTile(
              page: list[i],
              number: i + 1,
              onTap: () => _open(context, list, i),
              onDelete: () async {
                if (await confirmDelete(context, 'صفحه‌ی ${i + 1} حذف می‌شود.')) {
                  await ref.read(databaseProvider).deletePage(list[i]);
                }
              },
            ),
          );
        }),
      ),
    );
  }
}

class _PageTile extends StatelessWidget {
  const _PageTile({
    required this.page,
    required this.number,
    required this.onTap,
    required this.onDelete,
  });

  final NotePage page;
  final int number;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Expanded(
          child: Material(
            color: Colors.white,
            elevation: 1,
            borderRadius: BorderRadius.circular(6),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              onLongPress: onDelete,
              child: FittedBox(
                child: SizedBox.fromSize(
                  size: pageSize,
                  child: CustomPaint(
                    painter: PaperPainter(
                      page.background,
                      lineColor: scheme.primary.withValues(alpha: 0.18),
                    ),
                    foregroundPainter: page.kind == PageKind.ink
                        ? StrokesPainter(InkDocument.decode(page.ink))
                        : null,
                    child: page.kind == PageKind.text
                        ? Padding(
                            padding: const EdgeInsets.all(80),
                            child: Text(
                              page.body,
                              overflow: TextOverflow.fade,
                              style: const TextStyle(
                                fontSize: 40,
                                height: 1.6,
                                color: Colors.black87,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              page.kind == PageKind.ink ? Icons.draw_outlined : Icons.notes,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text('$number'),
          ],
        ),
      ],
    );
  }
}
