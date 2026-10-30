import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final notebooksProvider = StreamProvider<List<Notebook>>(
    (ref) => ref.watch(databaseProvider).watchNotebooks());

final notebookProvider = StreamProvider.family<Notebook?, int>(
    (ref, id) => ref.watch(databaseProvider).watchNotebook(id));

final pagesProvider = StreamProvider.family<List<NotePage>, int>(
    (ref, notebookId) => ref.watch(databaseProvider).watchPages(notebookId));

/// Loaded once per editor: the editor owns the live state and writes back.
final pageProvider = FutureProvider.autoDispose.family<NotePage, int>(
    (ref, id) => ref.watch(databaseProvider).getPage(id));
