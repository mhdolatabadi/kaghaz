import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../../core/theme.dart';
import '../../core/widgets/dialogs.dart';
import '../ink/ink_canvas.dart';
import '../ink/ink_controller.dart';
import '../ink/ink_model.dart';
import '../notebooks/notebook_screen.dart';
import 'ink_toolbar.dart';

const _wideLayout = 840.0;

/// Edits a notebook one page at a time, with a page panel on wide screens.
///
/// Pages are not swiped because a swipe would fight with drawing.
class PageEditorScreen extends ConsumerStatefulWidget {
  const PageEditorScreen({
    super.key,
    required this.notebookId,
    required this.initialPageId,
  });

  final int notebookId;
  final int initialPageId;

  @override
  ConsumerState<PageEditorScreen> createState() => _PageEditorScreenState();
}

class _PageEditorScreenState extends ConsumerState<PageEditorScreen> {
  late int _pageId = widget.initialPageId;
  bool _panelOpen = true;

  AppDatabase get _db => ref.read(databaseProvider);

  Future<void> _addPage(NotePage after) async {
    final id = await _db.addPage(
      widget.notebookId,
      PageKind.ink,
      afterPosition: after.position,
    );
    setState(() => _pageId = id);
  }

  Future<void> _deletePage(List<NotePage> pages, int index) async {
    if (pages.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('دفترچه باید دست‌کم یک صفحه داشته باشد.')),
      );
      return;
    }
    if (!await confirmDelete(context, 'صفحه‌ی ${fa(index + 1)} حذف می‌شود.')) return;
    final next = pages[index == pages.length - 1 ? index - 1 : index + 1];
    setState(() => _pageId = next.id);
    await _db.deletePage(pages[index]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notebook = ref.watch(notebookProvider(widget.notebookId)).value;
    final pages = ref.watch(pagesProvider(widget.notebookId)).value;
    final wide = MediaQuery.sizeOf(context).width >= _wideLayout;

    if (pages == null || pages.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    var index = pages.indexWhere((p) => p.id == _pageId);
    if (index < 0) index = 0;
    final page = pages[index];

    return Scaffold(
      backgroundColor: KaghazTheme.of(context).canvas,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Flexible(
              child: Text(notebook?.title ?? '', overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 12),
            Text(
              '${fa(index + 1)} / ${fa(pages.length)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'صفحه‌ی قبل',
            onPressed: index > 0
                ? () => setState(() => _pageId = pages[index - 1].id)
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            tooltip: 'صفحه‌ی بعد',
            onPressed: index < pages.length - 1
                ? () => setState(() => _pageId = pages[index + 1].id)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
          IconButton(
            tooltip: 'افزودن صفحه بعد از این صفحه',
            onPressed: () => _addPage(page),
            icon: const Icon(Icons.note_add_outlined),
          ),
          if (wide)
            IconButton(
              tooltip: 'پنل صفحه‌ها',
              isSelected: _panelOpen,
              onPressed: () => setState(() => _panelOpen = !_panelOpen),
              icon: const Icon(Icons.view_sidebar_outlined),
            ),
          PopupMenuButton<String>(
            onSelected: (action) {
              switch (action) {
                case 'duplicate':
                  _db.duplicatePage(page.id);
                case 'delete':
                  _deletePage(pages, index);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'duplicate', child: Text('کپی این صفحه')),
              PopupMenuItem(value: 'delete', child: Text('حذف این صفحه')),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: _PageLoader(key: ValueKey(page.id), pageId: page.id),
          ),
          if (wide && _panelOpen)
            _PagePanel(
              notebookId: widget.notebookId,
              pages: pages,
              currentId: page.id,
              onSelect: (id) => setState(() => _pageId = id),
            ),
        ],
      ),
    );
  }
}

/// Thumbnails of every page; tap to open, drag to reorder.
class _PagePanel extends ConsumerWidget {
  const _PagePanel({
    required this.notebookId,
    required this.pages,
    required this.currentId,
    required this.onSelect,
  });

  final int notebookId;
  final List<NotePage> pages;
  final int currentId;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: BorderDirectional(start: BorderSide(color: scheme.outlineVariant)),
      ),
      child: ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
        buildDefaultDragHandles: false,
        itemCount: pages.length,
        onReorderItem: (from, to) {
          final ids = [for (final p in pages) p.id];
          ids.insert(to, ids.removeAt(from));
          ref.read(databaseProvider).reorderPages(notebookId, ids);
        },
        itemBuilder: (context, i) {
          final p = pages[i];
          final current = p.id == currentId;
          return ReorderableDelayedDragStartListener(
            key: ValueKey(p.id),
            index: i,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => onSelect(p.id),
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: pageSize.width / pageSize.height,
                      child: DecoratedBox(
                        position: DecorationPosition.foreground,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            width: current ? 2.5 : 0,
                            color: current ? scheme.primary : Colors.transparent,
                          ),
                        ),
                        child: PageThumbnail(page: p),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fa(i + 1),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: current ? scheme.primary : null,
                            fontWeight: current ? FontWeight.w700 : null,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PageLoader extends ConsumerWidget {
  const _PageLoader({super.key, required this.pageId});

  final int pageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(pageProvider(pageId)).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطا: $e')),
          data: (page) => switch (page.kind) {
            PageKind.ink => InkPageEditor(page: page),
            PageKind.text => TextPageEditor(page: page),
          },
        );
  }
}

/// Saves after edits settle, and once more when the editor closes.
mixin _DebouncedSave<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  Timer? _saveTimer;
  late final AppDatabase db = ref.read(databaseProvider);

  Future<void> save();

  void scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 600), save);
  }

  @override
  void dispose() {
    if (_saveTimer?.isActive ?? false) {
      _saveTimer!.cancel();
      save();
    }
    super.dispose();
  }
}

class InkPageEditor extends ConsumerStatefulWidget {
  const InkPageEditor({super.key, required this.page});

  final NotePage page;

  @override
  ConsumerState<InkPageEditor> createState() => _InkPageEditorState();
}

class _InkPageEditorState extends ConsumerState<InkPageEditor>
    with _DebouncedSave {
  late final InkController _controller;
  late PageBackground _background = widget.page.background;
  int _savedRevision = 0;

  @override
  void initState() {
    super.initState();
    db; // Resolve before dispose, when ref can no longer be read.
    _controller = InkController(strokes: InkDocument.decode(widget.page.ink))
      ..addListener(_onInkChanged);
  }

  void _onInkChanged() {
    if (_controller.revision != _savedRevision) scheduleSave();
  }

  @override
  Future<void> save() async {
    _savedRevision = _controller.revision;
    await db.saveInk(widget.page.id, InkDocument.encode(_controller.strokes));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    final toolbar = InkToolbar(
      controller: _controller,
      background: _background,
      onBackgroundChanged: (b) {
        setState(() => _background = b);
        db.setBackground(widget.page.id, b);
      },
    );
    final canvas = ClipRect(
      child: InkCanvas(
        controller: _controller,
        background: _background,
        topInset: compact ? 12 : 84,
      ),
    );
    if (compact) {
      return Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: canvas),
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Center(child: SelectionBar(controller: _controller)),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: toolbar,
            ),
          ),
        ],
      );
    }
    return Stack(
      children: [
        Positioned.fill(child: canvas),
        Positioned(
          top: 14,
          left: 16,
          right: 16,
          child: Column(
            children: [
              Center(child: toolbar),
              const SizedBox(height: 10),
              SelectionBar(controller: _controller),
            ],
          ),
        ),
      ],
    );
  }
}

class TextPageEditor extends ConsumerStatefulWidget {
  const TextPageEditor({super.key, required this.page});

  final NotePage page;

  @override
  ConsumerState<TextPageEditor> createState() => _TextPageEditorState();
}

class _TextPageEditorState extends ConsumerState<TextPageEditor>
    with _DebouncedSave {
  late final _text = TextEditingController(text: widget.page.body);

  @override
  void initState() {
    super.initState();
    db;
  }

  @override
  Future<void> save() => db.saveBody(widget.page.id, _text.text);

  @override
  void dispose() {
    super.dispose();
    _text.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 820, minHeight: 900),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Color(0x0F000000), blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          child: TextField(
            controller: _text,
            onChanged: (_) => scheduleSave(),
            maxLines: null,
            minLines: 20,
            autofocus: widget.page.body.isEmpty,
            style: const TextStyle(
              fontSize: 18,
              height: 1.9,
              color: KaghazColors.textPrimary,
            ),
            decoration: const InputDecoration(
              hintText: 'بنویسید…',
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }
}
