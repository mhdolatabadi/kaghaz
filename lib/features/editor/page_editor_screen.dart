import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../ink/ink_canvas.dart';
import '../ink/ink_controller.dart';
import '../ink/ink_model.dart';
import 'ink_toolbar.dart';

/// Edits one page at a time, with buttons to move between pages.
///
/// Pages are not swiped because a swipe would fight with drawing.
class PageEditorScreen extends StatefulWidget {
  const PageEditorScreen({
    super.key,
    required this.pageIds,
    required this.initialIndex,
  });

  final List<int> pageIds;
  final int initialIndex;

  @override
  State<PageEditorScreen> createState() => _PageEditorScreenState();
}

class _PageEditorScreenState extends State<PageEditorScreen> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final count = widget.pageIds.length;
    return Scaffold(
      appBar: AppBar(
        title: Text('صفحه‌ی ${_index + 1} از $count'),
        actions: [
          IconButton(
            tooltip: 'صفحه‌ی قبل',
            onPressed: _index > 0 ? () => setState(() => _index--) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            tooltip: 'صفحه‌ی بعد',
            onPressed: _index < count - 1 ? () => setState(() => _index++) : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      body: _PageLoader(
        key: ValueKey(widget.pageIds[_index]),
        pageId: widget.pageIds[_index],
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
    return Column(
      children: [
        Expanded(
          child: ClipRect(
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: InkCanvas(controller: _controller, background: _background),
            ),
          ),
        ),
        InkToolbar(
          controller: _controller,
          background: _background,
          onBackgroundChanged: (b) {
            setState(() => _background = b);
            db.setBackground(widget.page.id, b);
          },
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: TextField(
          controller: _text,
          onChanged: (_) => scheduleSave(),
          maxLines: null,
          expands: true,
          autofocus: widget.page.body.isEmpty,
          textAlignVertical: TextAlignVertical.top,
          style: const TextStyle(fontSize: 18, height: 1.8),
          decoration: const InputDecoration(
            hintText: 'بنویسید…',
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(24),
          ),
        ),
      ),
    );
  }
}
