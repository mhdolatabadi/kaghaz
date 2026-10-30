import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../db/providers.dart';

/// Result of [pickFolder]: wraps the choice so "library root" (null id) is
/// distinguishable from "cancelled".
class FolderChoice {
  const FolderChoice(this.folderId);
  final int? folderId;
}

/// Lets the user choose a destination folder. [excluding] hides a folder and
/// everything under it, for moving a folder.
Future<FolderChoice?> pickFolder(
  BuildContext context, {
  required String title,
  int? excluding,
}) {
  return showDialog<FolderChoice>(
    context: context,
    builder: (context) => Consumer(builder: (context, ref, _) {
      final folders = ref.watch(allFoldersProvider).value ?? const [];
      final tree = folderTree(folders, excluding: excluding);
      return AlertDialog(
        title: Text(title),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        content: SizedBox(
          width: 360,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('کتابخانه (بدون پوشه)'),
                onTap: () => Navigator.pop(context, const FolderChoice(null)),
              ),
              for (final (folder, depth) in tree)
                ListTile(
                  contentPadding:
                      EdgeInsetsDirectional.only(start: 16.0 + depth * 20, end: 16),
                  leading: Icon(Icons.folder, color: Color(folder.color)),
                  title: Text(folder.name),
                  onTap: () => Navigator.pop(context, FolderChoice(folder.id)),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
        ],
      );
    }),
  );
}

/// Flattens folders into display order with their nesting depth.
List<(Folder, int)> folderTree(List<Folder> folders, {int? excluding}) {
  final byParent = <int?, List<Folder>>{};
  for (final f in folders) {
    byParent.putIfAbsent(f.parentId, () => []).add(f);
  }
  final out = <(Folder, int)>[];
  void walk(int? parent, int depth) {
    for (final f in byParent[parent] ?? const <Folder>[]) {
      if (f.id == excluding) continue;
      out.add((f, depth));
      walk(f.id, depth + 1);
    }
  }

  walk(null, 0);
  return out;
}

/// Lets the user choose another notebook, e.g. to move a page into.
Future<Notebook?> pickNotebook(
  BuildContext context, {
  required String title,
  int? excluding,
}) {
  return showDialog<Notebook>(
    context: context,
    builder: (context) => Consumer(builder: (context, ref, _) {
      final notebooks = [
        for (final n in ref.watch(allNotebooksProvider).value ?? const <Notebook>[])
          if (n.id != excluding) n,
      ];
      return AlertDialog(
        title: Text(title),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        content: SizedBox(
          width: 360,
          child: notebooks.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('دفترچه‌ی دیگری وجود ندارد.'),
                )
              : ListView(
                  shrinkWrap: true,
                  children: [
                    for (final n in notebooks)
                      ListTile(
                        leading: Icon(Icons.book, color: Color(n.color)),
                        title: Text(n.title),
                        onTap: () => Navigator.pop(context, n),
                      ),
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
        ],
      );
    }),
  );
}
