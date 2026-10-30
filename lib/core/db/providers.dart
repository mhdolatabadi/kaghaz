import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Which slice of the library is on screen.
sealed class LibraryView {
  const LibraryView();
}

class AllNotebooksView extends LibraryView {
  const AllNotebooksView();
  @override
  bool operator ==(Object other) => other is AllNotebooksView;
  @override
  int get hashCode => 1;
}

class FavoritesView extends LibraryView {
  const FavoritesView();
  @override
  bool operator ==(Object other) => other is FavoritesView;
  @override
  int get hashCode => 2;
}

/// A folder, or the library root when [folderId] is null.
class FolderView extends LibraryView {
  const FolderView(this.folderId);
  final int? folderId;
  @override
  bool operator ==(Object other) =>
      other is FolderView && other.folderId == folderId;
  @override
  int get hashCode => Object.hash(3, folderId);
}

class LibraryViewNotifier extends Notifier<LibraryView> {
  @override
  LibraryView build() => const FolderView(null);

  void show(LibraryView view) => state = view;
}

final libraryViewProvider =
    NotifierProvider<LibraryViewNotifier, LibraryView>(LibraryViewNotifier.new);

class SortNotifier extends Notifier<NotebookSort> {
  @override
  NotebookSort build() => NotebookSort.recent;

  void set(NotebookSort sort) => state = sort;
}

final notebookSortProvider =
    NotifierProvider<SortNotifier, NotebookSort>(SortNotifier.new);

final allFoldersProvider = StreamProvider<List<Folder>>(
    (ref) => ref.watch(databaseProvider).watchAllFolders());

final subfoldersProvider = StreamProvider.family<List<Folder>, int?>(
    (ref, parentId) => ref.watch(databaseProvider).watchFolders(parentId));

final folderPathProvider = FutureProvider.autoDispose.family<List<Folder>, int?>(
    (ref, folderId) {
  // Recompute when any folder is renamed or moved.
  ref.watch(allFoldersProvider);
  return ref.watch(databaseProvider).folderPath(folderId);
});

final libraryNotebooksProvider = StreamProvider<List<Notebook>>((ref) {
  final db = ref.watch(databaseProvider);
  final sort = ref.watch(notebookSortProvider);
  return switch (ref.watch(libraryViewProvider)) {
    AllNotebooksView() => db.watchNotebooks(allFolders: true, sort: sort),
    FavoritesView() => db.watchNotebooks(favoritesOnly: true, sort: sort),
    FolderView(:final folderId) => db.watchNotebooks(folderId: folderId, sort: sort),
  };
});

final pageCountsProvider = StreamProvider<Map<int, int>>(
    (ref) => ref.watch(databaseProvider).watchPageCounts());

class SearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String query) => state = query;
}

/// Filters the library by notebook and folder name.
final searchQueryProvider =
    NotifierProvider<SearchNotifier, String>(SearchNotifier.new);

final allNotebooksProvider = StreamProvider<List<Notebook>>(
    (ref) => ref.watch(databaseProvider).watchNotebooks(allFolders: true));

final notebookProvider = StreamProvider.family<Notebook?, int>(
    (ref, id) => ref.watch(databaseProvider).watchNotebook(id));

final pagesProvider = StreamProvider.family<List<NotePage>, int>(
    (ref, notebookId) => ref.watch(databaseProvider).watchPages(notebookId));

/// Loaded once per editor: the editor owns the live state and writes back.
final pageProvider = FutureProvider.autoDispose.family<NotePage, int>(
    (ref, id) => ref.watch(databaseProvider).getPage(id));
