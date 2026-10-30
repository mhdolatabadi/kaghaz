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
}
