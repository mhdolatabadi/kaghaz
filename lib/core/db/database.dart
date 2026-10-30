import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// What a page holds: freehand ink or typed text.
enum PageKind { ink, text }

/// The paper pattern drawn behind a page.
enum PageBackground { blank, lined, grid, dotted }

class Notebooks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  IntColumn get color => integer().withDefault(const Constant(0xFF3D5A80))();
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

@DriftDatabase(tables: [Notebooks, NotePages])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openDefault());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
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

  // Notebooks

  Stream<List<Notebook>> watchNotebooks() => (select(notebooks)
        ..orderBy([(n) => OrderingTerm.desc(n.updatedAt)]))
      .watch();

  Stream<Notebook?> watchNotebook(int id) =>
      (select(notebooks)..where((n) => n.id.equals(id))).watchSingleOrNull();

  /// Creates a notebook with one empty handwriting page.
  Future<int> createNotebook(String title, {int? color}) {
    return transaction(() async {
      final id = await into(notebooks).insert(NotebooksCompanion.insert(
        title: title,
        color: Value.absentIfNull(color),
      ));
      await addPage(id, PageKind.ink);
      return id;
    });
  }

  Future<void> renameNotebook(int id, String title) =>
      (update(notebooks)..where((n) => n.id.equals(id))).write(
          NotebooksCompanion(title: Value(title), updatedAt: Value(DateTime.now())));

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

  Future<NotePage> getPage(int id) =>
      (select(notePages)..where((p) => p.id.equals(id))).getSingle();

  Future<int> addPage(
    int notebookId,
    PageKind kind, {
    PageBackground background = PageBackground.lined,
  }) {
    return transaction(() async {
      final maxPos = notePages.position.max();
      final row = await (selectOnly(notePages)
            ..addColumns([maxPos])
            ..where(notePages.notebookId.equals(notebookId)))
          .getSingle();
      final id = await into(notePages).insert(NotePagesCompanion.insert(
        notebookId: notebookId,
        position: (row.read(maxPos) ?? -1) + 1,
        kind: kind,
        background: Value(background),
      ));
      await _touchNotebook(notebookId);
      return id;
    });
  }

  Future<void> deletePage(NotePage page) => transaction(() async {
        await (delete(notePages)..where((p) => p.id.equals(page.id))).go();
        await _touchNotebook(page.notebookId);
      });

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
