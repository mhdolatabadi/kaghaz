import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../../core/widgets/dialogs.dart';
import 'notebook_screen.dart';

const notebookColors = [
  Color(0xFF3D5A80),
  Color(0xFF98C1D9),
  Color(0xFFEE6C4D),
  Color(0xFF2A9D8F),
  Color(0xFFE9C46A),
  Color(0xFF8E7DBE),
];

class NotebooksScreen extends ConsumerWidget {
  const NotebooksScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref, int count) async {
    final title = await promptText(
      context,
      title: 'دفترچه‌ی جدید',
      confirm: 'ساختن',
    );
    if (title == null) return;
    final color = notebookColors[count % notebookColors.length];
    await ref.read(databaseProvider).createNotebook(title, color: color.toARGB32());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notebooks = ref.watch(notebooksProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('کاغذ')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context, ref, notebooks.value?.length ?? 0),
        icon: const Icon(Icons.add),
        label: const Text('دفترچه‌ی جدید'),
      ),
      body: notebooks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('هنوز دفترچه‌ای نساخته‌اید.'));
          }
          return LayoutBuilder(builder: (context, constraints) {
            final columns = math.max(2, constraints.maxWidth ~/ 180);
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio: 0.75,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: list.length,
              itemBuilder: (context, i) => _NotebookCover(notebook: list[i]),
            );
          });
        },
      ),
    );
  }
}

class _NotebookCover extends ConsumerWidget {
  const _NotebookCover({required this.notebook});

  final Notebook notebook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Color(notebook.color);
    final onColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : Colors.black87;
    final db = ref.read(databaseProvider);
    return Material(
      color: color,
      elevation: 2,
      borderRadius: const BorderRadiusDirectional.horizontal(
        start: Radius.circular(4),
        end: Radius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotebookScreen(notebookId: notebook.id),
          ),
        ),
        child: Stack(
          children: [
            PositionedDirectional(
              start: 10,
              top: 0,
              bottom: 0,
              child: Container(width: 3, color: onColor.withValues(alpha: 0.25)),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 8, 8),
              child: Text(
                notebook.title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: onColor, fontWeight: FontWeight.bold),
              ),
            ),
            PositionedDirectional(
              end: 0,
              bottom: 0,
              child: PopupMenuButton<String>(
                iconColor: onColor,
                onSelected: (action) async {
                  if (action == 'rename') {
                    final title = await promptText(
                      context,
                      title: 'تغییر نام',
                      initial: notebook.title,
                    );
                    if (title != null) await db.renameNotebook(notebook.id, title);
                  } else if (action == 'delete' &&
                      await confirmDelete(
                        context,
                        '«${notebook.title}» و همه‌ی صفحه‌هایش حذف می‌شوند.',
                      )) {
                    await db.deleteNotebook(notebook.id);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'rename', child: Text('تغییر نام')),
                  PopupMenuItem(value: 'delete', child: Text('حذف')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
