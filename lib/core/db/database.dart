import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// What a page holds: freehand ink or typed text.
enum PageKind { ink, text }

/// The paper pattern drawn behind a page.
enum PageBackground { blank, lined, grid, dotted }

/// How the library orders notebooks.
enum NotebookSort { recent, name, created }

class Folders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// Null for folders at the library root.
  IntColumn get parentId => integer()
      .nullable()
      .references(Folders, #id, onDelete: KeyAction.cascade)();
  IntColumn get color => integer().withDefault(const Constant(0xFF5C7CFA))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Notebooks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  IntColumn get color => integer().withDefault(const Constant(0xFF3D5A80))();

  /// Null for notebooks at the library root.
  IntColumn get folderId => integer()
      .nullable()
      .references(Folders, #id, onDelete: KeyAction.setNull)();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();

  /// Paper used for new pages added to this notebook.
  TextColumn get defaultBackground =>
      textEnum<PageBackground>().withDefault(const Constant('lined'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('NotePage')
class NotePages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get notebookId =>
      integer().references(Notebooks, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get kind => textEnum<PageKind>()();
  TextColumn get background =>
      textEnum<PageBackground>().withDefault(const Constant('lined'))();

  /// Strokes serialized by `InkDocument.encode`.
  TextColumn get ink => text().withDefault(const Constant('[]'))();

  /// Typed content for text pages.
  TextColumn get body => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Folders, Notebooks, NotePages])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openDefault());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(folders);
            await m.addColumn(notebooks, notebooks.folderId);
            await m.addColumn(notebooks, notebooks.favorite);
            await m.addColumn(notebooks, notebooks.defaultBackground);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _openDefault() => driftDatabase(
        name: 'kaghaz',
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
        ),
      );

  // Folders

  Stream<List<Folder>> watchAllFolders() =>
      (select(folders)..orderBy([(f) => OrderingTerm.asc(f.name)])).watch();

  Stream<List<Folder>> watchFolders(int? parentId) => (select(folders)
        ..where((f) =>
            parentId == null ? f.parentId.isNull() : f.parentId.equals(parentId))
        ..orderBy([(f) => OrderingTerm.asc(f.name)]))
      .watch();

  Future<int> createFolder(String name, {int? parentId, int? color}) =>
      into(folders).insert(FoldersCompanion.insert(
        name: name,
        parentId: Value(parentId),
        color: Value.absentIfNull(color),
      ));

  Future<void> renameFolder(int id, String name) =>
      (update(folders)..where((f) => f.id.equals(id)))
          .write(FoldersCompanion(name: Value(name)));

  /// Moves a folder under [parentId]; refuses to move it into itself.
  Future<bool> moveFolder(int id, int? parentId) async {
    if (parentId != null && await _isWithin(parentId, id)) return false;
    await (update(folders)..where((f) => f.id.equals(id)))
        .write(FoldersCompanion(parentId: Value(parentId)));
    return true;
  }

  /// Deletes a folder. Its notebooks and subfolders move up to its parent,
  /// so deleting a folder never deletes notes.
  Future<void> deleteFolder(int id) => transaction(() async {
        final folder =
            await (select(folders)..where((f) => f.id.equals(id))).getSingle();
        await (update(folders)..where((f) => f.parentId.equals(id)))
            .write(FoldersCompanion(parentId: Value(folder.parentId)));
        await (update(notebooks)..where((n) => n.folderId.equals(id)))
            .write(NotebooksCompanion(folderId: Value(folder.parentId)));
        await (delete(folders)..where((f) => f.id.equals(id))).go();
      });

  /// Whether [folderId] is [ancestorId] or sits somewhere below it.
  Future<bool> _isWithin(int folderId, int ancestorId) async {
    int? current = folderId;
    while (current != null) {
      if (current == ancestorId) return true;
      final row = await (select(folders)..where((f) => f.id.equals(current!)))
          .getSingleOrNull();
      current = row?.parentId;
    }
    return false;
  }

  /// The chain of folders from the root down to [folderId].
  Future<List<Folder>> folderPath(int? folderId) async {
    final path = <Folder>[];
    var current = folderId;
    while (current != null) {
      final row = await (select(folders)..where((f) => f.id.equals(current!)))
          .getSingleOrNull();
      if (row == null) break;
      path.insert(0, row);
      current = row.parentId;
    }
    return path;
  }

  // Notebooks

  Stream<List<Notebook>> watchNotebooks({
    int? folderId,
    bool allFolders = false,
    bool favoritesOnly = false,
    NotebookSort sort = NotebookSort.recent,
  }) {
    final query = select(notebooks);
    if (favoritesOnly) {
      query.where((n) => n.favorite.equals(true));
    } else if (!allFolders) {
      query.where((n) =>
          folderId == null ? n.folderId.isNull() : n.folderId.equals(folderId));
    }
    query.orderBy([
      (n) => switch (sort) {
            NotebookSort.recent => OrderingTerm.desc(n.updatedAt),
            NotebookSort.name => OrderingTerm.asc(n.title),
            NotebookSort.created => OrderingTerm.desc(n.createdAt),
          },
    ]);
    return query.watch();
  }

  Stream<Notebook?> watchNotebook(int id) =>
      (select(notebooks)..where((n) => n.id.equals(id))).watchSingleOrNull();

  /// Creates a notebook with one empty page of its default paper.
  Future<int> createNotebook(
    String title, {
    int? color,
    int? folderId,
    PageBackground background = PageBackground.lined,
    PageKind firstPage = PageKind.ink,
  }) {
    return transaction(() async {
      final id = await into(notebooks).insert(NotebooksCompanion.insert(
        title: title,
        color: Value.absentIfNull(color),
        folderId: Value(folderId),
        defaultBackground: Value(background),
      ));
      await addPage(id, firstPage);
      return id;
    });
  }

  Future<void> updateNotebook(
    int id, {
    String? title,
    int? color,
    PageBackground? defaultBackground,
  }) =>
      (update(notebooks)..where((n) => n.id.equals(id))).write(NotebooksCompanion(
        title: Value.absentIfNull(title),
        color: Value.absentIfNull(color),
        defaultBackground: Value.absentIfNull(defaultBackground),
        updatedAt: Value(DateTime.now()),
      ));

  Future<void> setFavorite(int id, bool favorite) =>
      (update(notebooks)..where((n) => n.id.equals(id)))
          .write(NotebooksCompanion(favorite: Value(favorite)));

  Future<void> moveNotebook(int id, int? folderId) =>
      (update(notebooks)..where((n) => n.id.equals(id)))
          .write(NotebooksCompanion(folderId: Value(folderId)));

  Future<void> deleteNotebook(int id) =>
      (delete(notebooks)..where((n) => n.id.equals(id))).go();

  Future<void> _touchNotebook(int id) =>
      (update(notebooks)..where((n) => n.id.equals(id)))
          .write(NotebooksCompanion(updatedAt: Value(DateTime.now())));

  // Pages

  Stream<List<NotePage>> watchPages(int notebookId) => (select(notePages)
        ..where((p) => p.notebookId.equals(notebookId))
        ..orderBy([(p) => OrderingTerm.asc(p.position)]))
      .watch();

  Future<List<NotePage>> getPages(int notebookId) =>
      watchPages(notebookId).first;

  /// Page count of every notebook, keyed by notebook id.
  Stream<Map<int, int>> watchPageCounts() {
    final count = notePages.id.count();
    final query = selectOnly(notePages)
      ..addColumns([notePages.notebookId, count])
      ..groupBy([notePages.notebookId]);
    return query.watch().map((rows) => {
          for (final r in rows) r.read(notePages.notebookId)!: r.read(count)!,
        });
  }

  Future<NotePage> getPage(int id) =>
      (select(notePages)..where((p) => p.id.equals(id))).getSingle();

  Future<int> _nextPosition(int notebookId) async {
    final maxPos = notePages.position.max();
    final row = await (selectOnly(notePages)
          ..addColumns([maxPos])
          ..where(notePages.notebookId.equals(notebookId)))
        .getSingle();
    return (row.read(maxPos) ?? -1) + 1;
  }

  /// Appends a page, or inserts it right after [afterPosition].
  Future<int> addPage(
    int notebookId,
    PageKind kind, {
    PageBackground? background,
    int? afterPosition,
  }) {
    return transaction(() async {
      final notebook = await (select(notebooks)
            ..where((n) => n.id.equals(notebookId)))
          .getSingle();
      int position;
      if (afterPosition == null) {
        position = await _nextPosition(notebookId);
      } else {
        position = afterPosition + 1;
        await customUpdate(
          'UPDATE note_pages SET position = position + 1 '
          'WHERE notebook_id = ? AND position >= ?',
          variables: [Variable(notebookId), Variable(position)],
          updates: {notePages},
        );
      }
      final id = await into(notePages).insert(NotePagesCompanion.insert(
        notebookId: notebookId,
        position: position,
        kind: kind,
        background: Value(background ?? notebook.defaultBackground),
      ));
      await _touchNotebook(notebookId);
      return id;
    });
  }

  Future<int> duplicatePage(int pageId) => transaction(() async {
        final page = await getPage(pageId);
        final id = await addPage(
          page.notebookId,
          page.kind,
          background: page.background,
          afterPosition: page.position,
        );
        await (update(notePages)..where((p) => p.id.equals(id))).write(
            NotePagesCompanion(ink: Value(page.ink), body: Value(page.body)));
        return id;
      });

  Future<void> deletePage(NotePage page) => transaction(() async {
        await (delete(notePages)..where((p) => p.id.equals(page.id))).go();
        await _renumber(page.notebookId);
        await _touchNotebook(page.notebookId);
      });

  /// Stores pages in the order of [pageIds].
  Future<void> reorderPages(int notebookId, List<int> pageIds) =>
      transaction(() async {
        for (var i = 0; i < pageIds.length; i++) {
          await (update(notePages)
                ..where((p) =>
                    p.id.equals(pageIds[i]) & p.notebookId.equals(notebookId)))
              .write(NotePagesCompanion(position: Value(i)));
        }
        await _touchNotebook(notebookId);
      });

  /// Moves a page to the end of another notebook.
  Future<void> movePage(int pageId, int targetNotebookId) =>
      transaction(() async {
        final page = await getPage(pageId);
        if (page.notebookId == targetNotebookId) return;
        await (update(notePages)..where((p) => p.id.equals(pageId))).write(
          NotePagesCompanion(
            notebookId: Value(targetNotebookId),
            position: Value(await _nextPosition(targetNotebookId)),
          ),
        );
        await _renumber(page.notebookId);
        await _touchNotebook(page.notebookId);
        await _touchNotebook(targetNotebookId);
      });

  Future<void> _renumber(int notebookId) async {
    final pages = await getPages(notebookId);
    for (var i = 0; i < pages.length; i++) {
      if (pages[i].position != i) {
        await (update(notePages)..where((p) => p.id.equals(pages[i].id)))
            .write(NotePagesCompanion(position: Value(i)));
      }
    }
  }

  Future<void> _updatePage(int id, NotePagesCompanion changes) =>
      transaction(() async {
        final page = await getPage(id);
        await (update(notePages)..where((p) => p.id.equals(id)))
            .write(changes.copyWith(updatedAt: Value(DateTime.now())));
        await _touchNotebook(page.notebookId);
      });

  Future<void> saveInk(int pageId, String ink) =>
      _updatePage(pageId, NotePagesCompanion(ink: Value(ink)));

  Future<void> saveBody(int pageId, String body) =>
      _updatePage(pageId, NotePagesCompanion(body: Value(body)));

  Future<void> setBackground(int pageId, PageBackground background) =>
      _updatePage(pageId, NotePagesCompanion(background: Value(background)));
}
