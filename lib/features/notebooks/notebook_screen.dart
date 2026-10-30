import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../../core/theme.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/pickers.dart';
import '../editor/page_editor_screen.dart';
import '../ink/ink_canvas.dart';
import '../ink/ink_model.dart';
import '../ink/ink_painter.dart';

/// The pages of one notebook as a grid of thumbnails.
///
/// Long-press a page and drop it on another to reorder.
class NotebookScreen extends ConsumerStatefulWidget {
  const NotebookScreen({super.key, required this.notebookId});

  final int notebookId;

  @override
  ConsumerState<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends ConsumerState<NotebookScreen> {
  /// Order shown while a reorder is being saved, so tiles don't jump back.
  List<NotePage>? _pending;

  AppDatabase get _db => ref.read(databaseProvider);

  void _open(int pageId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PageEditorScreen(
          notebookId: widget.notebookId,
          initialPageId: pageId,
        ),
      ),
    );
  }

  Future<void> _add(PageKind kind) async {
    final id = await _db.addPage(widget.notebookId, kind);
    if (mounted) _open(id);
  }

  Future<void> _reorder(List<NotePage> pages, NotePage moved, int toIndex) async {
    final next = [...pages]..remove(moved);
    next.insert(toIndex.clamp(0, next.length), moved);
    setState(() => _pending = next);
    await _db.reorderPages(widget.notebookId, [for (final p in next) p.id]);
    if (mounted) setState(() => _pending = null);
  }

  Future<void> _onAction(NotePage page, int number, String action) async {
    switch (action) {
      case 'duplicate':
        await _db.duplicatePage(page.id);
      case 'move':
        final target = await pickNotebook(
          context,
          title: 'انتقال صفحه‌ی ${fa(number)} به',
          excluding: widget.notebookId,
        );
        if (target != null) {
          await _db.movePage(page.id, target.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('صفحه به «${target.title}» منتقل شد.')),
            );
          }
        }
      case 'delete':
        if (await confirmDelete(context, 'صفحه‌ی ${fa(number)} حذف می‌شود.')) {
          await _db.deletePage(page);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notebook = ref.watch(notebookProvider(widget.notebookId)).value;
    final pages = ref.watch(pagesProvider(widget.notebookId));
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (notebook != null)
              Container(
                width: 14,
                height: 20,
                margin: const EdgeInsetsDirectional.only(end: 10),
                decoration: BoxDecoration(
                  color: Color(notebook.color),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            Flexible(child: Text(notebook?.title ?? '')),
          ],
        ),
      ),
      floatingActionButton: MenuAnchor(
        menuChildren: [
          MenuItemButton(
            leadingIcon: const Icon(Icons.draw_outlined),
            onPressed: () => _add(PageKind.ink),
            child: const Text('صفحه‌ی دست‌نویس'),
          ),
          MenuItemButton(
            leadingIcon: const Icon(Icons.notes),
            onPressed: () => _add(PageKind.text),
            child: const Text('صفحه‌ی متنی'),
          ),
        ],
        builder: (context, menu, _) => FloatingActionButton.extended(
          onPressed: () => menu.isOpen ? menu.close() : menu.open(),
          icon: const Icon(Icons.add),
          label: const Text('صفحه‌ی جدید'),
        ),
      ),
      body: pages.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
        data: (fresh) {
          final list = _pending ?? fresh;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  children: [
                    Text(
                      '${fa(list.length)} صفحه',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const Spacer(),
                    Text(
                      'برای جابه‌جایی، صفحه را نگه دارید و بکشید',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  final columns = math.max(2, constraints.maxWidth ~/ 190);
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      childAspectRatio: pageSize.width / (pageSize.height + 160),
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, i) => _ReorderablePage(
                      page: list[i],
                      number: i + 1,
                      onTap: () => _open(list[i].id),
                      onDrop: (moved) => _reorder(list, moved, i),
                      onAction: (a) => _onAction(list[i], i + 1, a),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReorderablePage extends StatelessWidget {
  const _ReorderablePage({
    required this.page,
    required this.number,
    required this.onTap,
    required this.onDrop,
    required this.onAction,
  });

  final NotePage page;
  final int number;
  final VoidCallback onTap;
  final ValueChanged<NotePage> onDrop;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final thumb = PageThumbnail(page: page);
    return DragTarget<NotePage>(
      onWillAcceptWithDetails: (d) => d.data.id != page.id,
      onAcceptWithDetails: (d) => onDrop(d.data),
      builder: (context, candidates, _) {
        final hovering = candidates.isNotEmpty;
        return LongPressDraggable<NotePage>(
          data: page,
          delay: const Duration(milliseconds: 250),
          feedback: SizedBox(
            width: 130,
            height: 130 * pageSize.height / pageSize.width,
            child: Opacity(opacity: 0.85, child: thumb),
          ),
          childWhenDragging: Opacity(opacity: 0.25, child: _tile(context, thumb)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsetsDirectional.only(start: hovering ? 14 : 0),
            decoration: BoxDecoration(
              border: BorderDirectional(
                start: BorderSide(
                  width: 3,
                  color: hovering ? scheme.primary : Colors.transparent,
                ),
              ),
            ),
            child: _tile(context, thumb),
          ),
        );
      },
    );
  }

  Widget _tile(BuildContext context, Widget thumb) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: MouseRegion(cursor: SystemMouseCursors.click, child: thumb),
          ),
        ),
        Row(
          children: [
            const SizedBox(width: 8),
            Icon(
              page.kind == PageKind.ink ? Icons.draw_outlined : Icons.notes,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(fa(number), style: theme.textTheme.titleSmall),
            const Spacer(),
            PopupMenuButton<String>(
              iconSize: 20,
              onSelected: onAction,
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'duplicate', child: Text('کپی صفحه')),
                PopupMenuItem(value: 'move', child: Text('انتقال به دفترچه‌ی دیگر…')),
                PopupMenuItem(value: 'delete', child: Text('حذف')),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// A scaled-down rendering of a page's paper and content.
class PageThumbnail extends StatelessWidget {
  const PageThumbnail({super.key, required this.page});

  final NotePage page;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
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
    );
  }
}
