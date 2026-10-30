import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaghaz/core/db/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() => db.close());

  test('a new notebook starts with one ink page', () async {
    final id = await db.createNotebook('ریاضی');
    final pages = await db.watchPages(id).first;
    expect(pages, hasLength(1));
    expect(pages.single.kind, PageKind.ink);
    expect(pages.single.background, PageBackground.lined);
  });

  test('pages are appended in order and content is saved', () async {
    final id = await db.createNotebook('درس');
    final textId = await db.addPage(id, PageKind.text);
    await db.saveBody(textId, 'سلام دنیا');
    await db.setBackground(textId, PageBackground.grid);

    final pages = await db.watchPages(id).first;
    expect([for (final p in pages) p.position], [0, 1]);
    expect(pages.last.body, 'سلام دنیا');
    expect(pages.last.background, PageBackground.grid);
  });

  test('deleting a notebook deletes its pages', () async {
    final id = await db.createNotebook('موقت');
    await db.addPage(id, PageKind.text);
    await db.deleteNotebook(id);
    expect(await db.select(db.notePages).get(), isEmpty);
  });

  test('folders nest, refuse cycles, and give their contents up on delete', () async {
    final school = await db.createFolder('مدرسه');
    final math = await db.createFolder('ریاضی', parentId: school);
    final nb = await db.createNotebook('جبر', folderId: math);

    expect(await db.moveFolder(school, math), isFalse);
    expect([for (final f in await db.folderPath(math)) f.name], ['مدرسه', 'ریاضی']);

    await db.deleteFolder(math);
    final notebook = await db.watchNotebook(nb).first;
    expect(notebook!.folderId, school);
    expect(await db.watchFolders(school).first, isEmpty);
  });

  test('notebooks can move between folders and be filtered', () async {
    final f = await db.createFolder('کار');
    final a = await db.createNotebook('الف');
    await db.createNotebook('ب');
    await db.moveNotebook(a, f);
    await db.setFavorite(a, true);

    expect([for (final n in await db.watchNotebooks(folderId: f).first) n.title], ['الف']);
    expect([for (final n in await db.watchNotebooks().first) n.title], ['ب']);
    expect(await db.watchNotebooks(favoritesOnly: true).first, hasLength(1));
    expect(await db.watchNotebooks(allFolders: true).first, hasLength(2));
  });

  test('pages reorder, insert after, duplicate, and move between notebooks', () async {
    final a = await db.createNotebook('الف', background: PageBackground.grid);
    final b = await db.createNotebook('ب');
    final p0 = (await db.getPages(a)).single.id;
    final p1 = await db.addPage(a, PageKind.text);
    await db.saveBody(p1, 'متن');
    final mid = await db.addPage(a, PageKind.ink, afterPosition: 0);

    List<int> ids(List<NotePage> pages) => [for (final p in pages) p.id];
    expect(ids(await db.getPages(a)), [p0, mid, p1]);
    expect((await db.getPage(mid)).background, PageBackground.grid);

    await db.reorderPages(a, [p1, p0, mid]);
    expect(ids(await db.getPages(a)), [p1, p0, mid]);

    final copy = await db.duplicatePage(p1);
    expect((await db.getPage(copy)).body, 'متن');
    expect(ids(await db.getPages(a)), [p1, copy, p0, mid]);

    await db.movePage(p0, b);
    expect(ids(await db.getPages(a)), [p1, copy, mid]);
    expect([for (final p in await db.getPages(a)) p.position], [0, 1, 2]);
    expect(ids(await db.getPages(b)).last, p0);
    expect((await db.watchPageCounts().first)[b], 2);
  });
}
