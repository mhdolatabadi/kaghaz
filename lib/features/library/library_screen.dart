import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../../core/theme.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/pickers.dart';
import '../notebooks/notebook_screen.dart';
import 'notebook_dialog.dart';

const _wideLayout = 840.0;

/// The home screen: a folder sidebar and a shelf of folders and notebooks.
///
/// Notebooks and folders can be dragged (long-press) onto a folder in the
/// shelf, the sidebar, or the breadcrumb to move them.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= _wideLayout;
      return Scaffold(
        drawer: wide ? null : const Drawer(child: _Sidebar()),
        floatingActionButton: wide ? null : const _NewButton(),
        body: Row(
          children: [
            if (wide)
              SizedBox(
                width: 280,
                child: Material(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: const _Sidebar(),
                ),
              ),
            const Expanded(child: _Shelf()),
          ],
        ),
      );
    });
  }
}

// Actions shared by the sidebar, shelf and menus.

Future<void> createFolder(BuildContext context, WidgetRef ref, int? parentId) async {
  final name = await promptText(context, title: 'پوشه‌ی جدید', confirm: 'ساختن');
  if (name == null) return;
  final count = ref.read(allFoldersProvider).value?.length ?? 0;
  await ref.read(databaseProvider).createFolder(
        name,
        parentId: parentId,
        color: coverColors[(count + 3) % coverColors.length].toARGB32(),
      );
}

Future<void> createNotebook(BuildContext context, WidgetRef ref) async {
  final view = ref.read(libraryViewProvider);
  final count = ref.read(allNotebooksProvider).value?.length ?? 0;
  final settings = await showNotebookDialog(context, seed: count);
  if (settings == null) return;
  final db = ref.read(databaseProvider);
  final id = await db.createNotebook(
    settings.title,
    color: settings.color.toARGB32(),
    folderId: view is FolderView ? view.folderId : null,
    background: settings.paper,
  );
  if (view is FavoritesView) await db.setFavorite(id, true);
}

Future<void> _onNotebookAction(
  BuildContext context,
  WidgetRef ref,
  Notebook notebook,
  String action,
) async {
  final db = ref.read(databaseProvider);
  switch (action) {
    case 'edit':
      final s = await showNotebookDialog(
        context,
        initial: NotebookSettings(
          notebook.title,
          Color(notebook.color),
          notebook.defaultBackground,
        ),
      );
      if (s != null) {
        await db.updateNotebook(
          notebook.id,
          title: s.title,
          color: s.color.toARGB32(),
          defaultBackground: s.paper,
        );
      }
    case 'favorite':
      await db.setFavorite(notebook.id, !notebook.favorite);
    case 'move':
      final choice = await pickFolder(context, title: 'انتقال «${notebook.title}» به');
      if (choice != null && context.mounted) {
        await moveNotebookWithUndo(context, ref, notebook, choice.folderId);
      }
    case 'delete':
      if (await confirmDelete(
        context,
        '«${notebook.title}» و همه‌ی صفحه‌هایش حذف می‌شوند.',
      )) {
        await db.deleteNotebook(notebook.id);
      }
  }
}

Future<void> _onFolderAction(
  BuildContext context,
  WidgetRef ref,
  Folder folder,
  String action,
) async {
  final db = ref.read(databaseProvider);
  switch (action) {
    case 'rename':
      final name = await promptText(context, title: 'تغییر نام پوشه', initial: folder.name);
      if (name != null) await db.renameFolder(folder.id, name);
    case 'move':
      final choice = await pickFolder(
        context,
        title: 'انتقال «${folder.name}» به',
        excluding: folder.id,
      );
      if (choice != null && context.mounted) {
        await moveFolderWithUndo(context, ref, folder, choice.folderId);
      }
    case 'delete':
      if (await confirmDelete(
        context,
        'پوشه‌ی «${folder.name}» حذف می‌شود. دفترچه‌ها و زیرپوشه‌هایش به پوشه‌ی بالاتر منتقل می‌شوند.',
      )) {
        final view = ref.read(libraryViewProvider);
        if (view is FolderView && view.folderId == folder.id) {
          ref.read(libraryViewProvider.notifier).show(FolderView(folder.parentId));
        }
        await db.deleteFolder(folder.id);
      }
  }
}

void _showMoved(BuildContext context, String what, String where, VoidCallback undo) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text('$what به «$where» منتقل شد'),
      action: SnackBarAction(label: 'بازگردانی', onPressed: undo),
    ));
}

String _folderName(WidgetRef ref, int? folderId) {
  if (folderId == null) return 'کتابخانه';
  final folders = ref.read(allFoldersProvider).value ?? const <Folder>[];
  return folders.where((f) => f.id == folderId).firstOrNull?.name ?? '';
}

Future<void> moveNotebookWithUndo(
  BuildContext context,
  WidgetRef ref,
  Notebook notebook,
  int? folderId,
) async {
  final db = ref.read(databaseProvider);
  final from = notebook.folderId;
  await db.moveNotebook(notebook.id, folderId);
  if (context.mounted) {
    _showMoved(context, '«${notebook.title}»', _folderName(ref, folderId),
        () => db.moveNotebook(notebook.id, from));
  }
}

Future<void> moveFolderWithUndo(
  BuildContext context,
  WidgetRef ref,
  Folder folder,
  int? parentId,
) async {
  final db = ref.read(databaseProvider);
  final from = folder.parentId;
  if (await db.moveFolder(folder.id, parentId)) {
    if (context.mounted) {
      _showMoved(context, 'پوشه‌ی «${folder.name}»', _folderName(ref, parentId),
          () => db.moveFolder(folder.id, from));
    }
  } else if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('پوشه را نمی‌توان داخل خودش برد.')),
    );
  }
}

/// Accepts dropped notebooks and folders and moves them into [folderId].
class _FolderDropTarget extends ConsumerWidget {
  const _FolderDropTarget({required this.folderId, required this.builder});

  final int? folderId;
  final Widget Function(BuildContext context, bool hovering) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<Object>(
      onWillAcceptWithDetails: (d) => switch (d.data) {
        Notebook n => n.folderId != folderId,
        Folder f => f.id != folderId && f.parentId != folderId,
        _ => false,
      },
      onAcceptWithDetails: (d) async {
        switch (d.data) {
          case Notebook n:
            await moveNotebookWithUndo(context, ref, n, folderId);
          case Folder f:
            await moveFolderWithUndo(context, ref, f, folderId);
        }
      },
      builder: (context, candidates, _) => builder(context, candidates.isNotEmpty),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final view = ref.watch(libraryViewProvider);
    final allFolders = ref.watch(allFoldersProvider).value ?? const <Folder>[];
    final folders = folderTree(allFolders);
    final notebooks = ref.watch(allNotebooksProvider).value ?? const <Notebook>[];
    final counts = folderItemCounts(allFolders, notebooks);
    void show(LibraryView v) {
      ref.read(libraryViewProvider.notifier).show(v);
      if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) Navigator.pop(context);
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 8, 20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.edit_note, color: theme.colorScheme.onPrimary),
                ),
                const SizedBox(width: 12),
                Text(
                  'کاغذ',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          _FolderDropTarget(
            folderId: null,
            builder: (context, hovering) => _NavItem(
              icon: Icons.home_outlined,
              label: 'کتابخانه',
              selected: view == const FolderView(null),
              highlighted: hovering,
              onTap: () => show(const FolderView(null)),
            ),
          ),
          _NavItem(
            icon: Icons.menu_book_outlined,
            label: 'همه‌ی دفترچه‌ها',
            selected: view is AllNotebooksView,
            count: notebooks.length,
            onTap: () => show(const AllNotebooksView()),
          ),
          _NavItem(
            icon: Icons.star_outline,
            label: 'علاقه‌مندی‌ها',
            selected: view is FavoritesView,
            count: notebooks.where((n) => n.favorite).length,
            onTap: () => show(const FavoritesView()),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 24, 0, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'پوشه‌ها',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
                IconButton(
                  tooltip: 'پوشه‌ی جدید',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => createFolder(context, ref, null),
                  icon: const Icon(Icons.create_new_folder_outlined, size: 20),
                ),
              ],
            ),
          ),
          if (folders.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'هنوز پوشه‌ای ندارید.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          for (final (folder, depth) in folders)
            Padding(
              padding: EdgeInsetsDirectional.only(start: depth * 16.0),
              child: _FolderDropTarget(
                folderId: folder.id,
                builder: (context, hovering) => _NavItem(
                  icon: Icons.folder,
                  iconColor: Color(folder.color),
                  label: folder.name,
                  selected: view == FolderView(folder.id),
                  highlighted: hovering,
                  count: counts[folder.id] ?? 0,
                  onTap: () => show(FolderView(folder.id)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.iconColor,
    this.highlighted = false,
    this.count,
  });

  final int? count;
  final IconData icon;
  final Color? iconColor;
  final String label;
  final bool selected;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: highlighted || selected ? scheme.primaryContainer : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: highlighted
              ? BorderSide(color: scheme.primary, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 20, color: iconColor ?? (selected ? scheme.primary : null)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? scheme.primary : null,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (count != null)
                  Text(
                    fa(count!),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NewButton extends ConsumerWidget {
  const _NewButton({this.compact = false});

  /// A header button instead of a floating action button.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(libraryViewProvider);
    return MenuAnchor(
      alignmentOffset: const Offset(0, -8),
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.menu_book_outlined),
          onPressed: () => createNotebook(context, ref),
          child: const Text('دفترچه‌ی جدید'),
        ),
        if (view is FolderView)
          MenuItemButton(
            leadingIcon: const Icon(Icons.create_new_folder_outlined),
            onPressed: () => createFolder(context, ref, view.folderId),
            child: const Text('پوشه‌ی جدید'),
          ),
      ],
      builder: (context, menu, _) {
        void toggle() => menu.isOpen ? menu.close() : menu.open();
        return compact
            ? FilledButton.icon(
                onPressed: toggle,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('جدید'),
              )
            : FloatingActionButton.extended(
                onPressed: toggle,
                icon: const Icon(Icons.add),
                label: const Text('جدید'),
              );
      },
    );
  }
}

class _SearchField extends ConsumerStatefulWidget {
  const _SearchField();

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    return TextField(
      controller: _controller,
      onChanged: ref.read(searchQueryProvider.notifier).set,
      decoration: InputDecoration(
        hintText: 'جستجو در دفترچه‌ها و پوشه‌ها…',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  _controller.clear();
                  ref.read(searchQueryProvider.notifier).set('');
                },
              ),
      ),
    );
  }
}

class _Shelf extends ConsumerWidget {
  const _Shelf();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final view = ref.watch(libraryViewProvider);
    final query = ref.watch(searchQueryProvider).trim();
    final searching = query.isNotEmpty;
    final notebooks = ref.watch(
        searching ? allNotebooksProvider : libraryNotebooksProvider);
    final folderId = view is FolderView ? view.folderId : null;
    var subfolders = searching
        ? ref.watch(allFoldersProvider).value ?? const <Folder>[]
        : view is FolderView
            ? ref.watch(subfoldersProvider(folderId)).value ?? const <Folder>[]
            : const <Folder>[];
    final wide = MediaQuery.sizeOf(context).width >= _wideLayout;

    bool matches(String text) => text.contains(query);
    if (searching) subfolders = subfolders.where((f) => matches(f.name)).toList();

    final title = searching
        ? 'نتایج جستجو'
        : switch (view) {
            AllNotebooksView() => 'همه‌ی دفترچه‌ها',
            FavoritesView() => 'علاقه‌مندی‌ها',
            FolderView() => null,
          };

    return SafeArea(
      child: LayoutBuilder(builder: (context, constraints) {
        final columns = math.max(2, (constraints.maxWidth - 48) ~/ 170);
        SliverGrid grid(int count, Widget Function(int) item, double aspect) =>
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio: aspect,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => item(i),
                childCount: count,
              ),
            );

        var list = notebooks.value ?? const <Notebook>[];
        if (searching) list = list.where((n) => matches(n.title)).toList();
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    if (!wide)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: IconButton(
                          onPressed: () => Scaffold.of(context).openDrawer(),
                          icon: const Icon(Icons.menu),
                        ),
                      ),
                    const Expanded(child: _SearchField()),
                    const SizedBox(width: 8),
                    const _SortMenu(),
                    if (wide) ...[
                      const SizedBox(width: 8),
                      const _NewButton(compact: true),
                    ],
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              sliver: SliverToBoxAdapter(
                child: title != null
                    ? Text(title, style: theme.textTheme.headlineSmall)
                    : _Breadcrumb(folderId: folderId),
              ),
            ),
            if (subfolders.isNotEmpty) ...[
              _sectionHeader(context, 'پوشه‌ها'),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: grid(
                  subfolders.length,
                  (i) => _FolderTile(folder: subfolders[i]),
                  2.4,
                ),
              ),
            ],
            if (subfolders.isNotEmpty && list.isNotEmpty)
              _sectionHeader(context, 'دفترچه‌ها'),
            if (notebooks.isLoading && !notebooks.hasValue)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (list.isEmpty && subfolders.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(view: view),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                sliver: grid(
                  list.length,
                  (i) => _NotebookTile(notebook: list[i]),
                  0.62,
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _sectionHeader(BuildContext context, String text) => SliverPadding(
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 12),
        sliver: SliverToBoxAdapter(
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      );
}

class _Breadcrumb extends ConsumerWidget {
  const _Breadcrumb({required this.folderId});

  final int? folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final path = ref.watch(folderPathProvider(folderId)).value ?? const <Folder>[];
    final crumbs = <(int?, String)>[
      (null, 'کتابخانه'),
      for (final f in path) (f.id, f.name),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < crumbs.length; i++) ...[
            if (i > 0)
              Icon(Icons.chevron_left, color: theme.colorScheme.outline),
            _FolderDropTarget(
              folderId: crumbs[i].$1,
              builder: (context, hovering) {
                final last = i == crumbs.length - 1;
                return Material(
                  color: hovering ? theme.colorScheme.primaryContainer : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: last
                        ? null
                        : () => ref
                            .read(libraryViewProvider.notifier)
                            .show(FolderView(crumbs[i].$1)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Text(
                        crumbs[i].$2,
                        style: (last
                                ? theme.textTheme.headlineSmall
                                : theme.textTheme.titleMedium)
                            ?.copyWith(
                          fontWeight: last ? FontWeight.w700 : FontWeight.w500,
                          color: last ? null : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _SortMenu extends ConsumerWidget {
  const _SortMenu();

  static const _labels = {
    NotebookSort.recent: 'آخرین تغییر',
    NotebookSort.name: 'نام',
    NotebookSort.created: 'تاریخ ساخت',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(notebookSortProvider);
    return PopupMenuButton<NotebookSort>(
      tooltip: 'مرتب‌سازی',
      initialValue: sort,
      onSelected: ref.read(notebookSortProvider.notifier).set,
      itemBuilder: (_) => [
        for (final e in _labels.entries)
          PopupMenuItem(value: e.key, child: Text(e.value)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort, size: 18),
            if (MediaQuery.sizeOf(context).width >= 600) ...[
              const SizedBox(width: 6),
              Text(_labels[sort]!),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.view});

  final LibraryView view;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, text) = switch (view) {
      FavoritesView() => (
          Icons.star_outline,
          'دفترچه‌ای را از منوی آن به علاقه‌مندی‌ها اضافه کنید.'
        ),
      _ => (Icons.menu_book_outlined, 'با دکمه‌ی «جدید» اولین دفترچه را بسازید.'),
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wraps [child] so a long press picks it up for dragging.
Widget _draggable<T extends Object>({
  required T data,
  required Widget child,
  required Widget feedback,
}) {
  return LongPressDraggable<T>(
    data: data,
    delay: const Duration(milliseconds: 300),
    feedback: Material(
      color: Colors.transparent,
      child: Opacity(opacity: 0.85, child: feedback),
    ),
    childWhenDragging: Opacity(opacity: 0.3, child: child),
    child: child,
  );
}

class _NotebookTile extends ConsumerWidget {
  const _NotebookTile({required this.notebook});

  final Notebook notebook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pages = ref.watch(pageCountsProvider).value?[notebook.id] ?? 0;
    final cover = NotebookCoverArt(color: Color(notebook.color), title: notebook.title);
    return _draggable<Notebook>(
      data: notebook,
      feedback: Transform.rotate(
        angle: -0.03,
        child: SizedBox(
          width: 140,
          child: NotebookCoverArt(
            color: Color(notebook.color),
            title: notebook.title,
            lifted: true,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotebookScreen(notebookId: notebook.id),
                ),
              ),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Center(child: cover),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (notebook.favorite)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 4),
                  child: Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notebook.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${relativeDate(notebook.updatedAt)}، ${fa(pages)} صفحه',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                iconSize: 20,
                onSelected: (a) => _onNotebookAction(context, ref, notebook, a),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('ویرایش')),
                  PopupMenuItem(
                    value: 'favorite',
                    child: Text(notebook.favorite
                        ? 'حذف از علاقه‌مندی‌ها'
                        : 'افزودن به علاقه‌مندی‌ها'),
                  ),
                  const PopupMenuItem(value: 'move', child: Text('انتقال به پوشه…')),
                  const PopupMenuItem(value: 'delete', child: Text('حذف')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FolderTile extends ConsumerWidget {
  const _FolderTile({required this.folder});

  final Folder folder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = Color(folder.color);
    final count = folderItemCounts(
      ref.watch(allFoldersProvider).value ?? const [],
      ref.watch(allNotebooksProvider).value ?? const [],
    )[folder.id] ?? 0;
    Widget tile(bool hovering) => Card(
          margin: EdgeInsets.zero,
          color: hovering ? theme.colorScheme.primaryContainer : null,
          shape: hovering
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.primary, width: 2),
                )
              : null,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () =>
                ref.read(libraryViewProvider.notifier).show(FolderView(folder.id)),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 0, 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.folder, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          folder.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          hovering ? 'رها کنید تا منتقل شود' : '${fa(count)} مورد',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    iconSize: 20,
                    onSelected: (a) => _onFolderAction(context, ref, folder, a),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'rename', child: Text('تغییر نام')),
                      PopupMenuItem(value: 'move', child: Text('انتقال به…')),
                      PopupMenuItem(value: 'delete', child: Text('حذف پوشه')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );

    return _draggable<Folder>(
      data: folder,
      feedback: SizedBox(width: 200, height: 72, child: tile(false)),
      child: _FolderDropTarget(
        folderId: folder.id,
        builder: (context, hovering) => tile(hovering),
      ),
    );
  }
}

/// Direct children (notebooks and subfolders) of each folder.
Map<int, int> folderItemCounts(List<Folder> folders, List<Notebook> notebooks) {
  final counts = <int, int>{};
  for (final f in folders) {
    if (f.parentId case final p?) counts[p] = (counts[p] ?? 0) + 1;
  }
  for (final n in notebooks) {
    if (n.folderId case final f?) counts[f] = (counts[f] ?? 0) + 1;
  }
  return counts;
}
