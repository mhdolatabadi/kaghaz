import 'package:flutter/material.dart';

/// Asks for a line of text; returns null when cancelled or left empty.
Future<String?> promptText(
  BuildContext context, {
  required String title,
  String initial = '',
  String confirm = 'ذخیره',
}) async {
  final controller = TextEditingController(text: initial);
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('انصراف'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text(confirm),
        ),
      ],
    ),
  );
  controller.dispose();
  final text = result?.trim();
  return (text == null || text.isEmpty) ? null : text;
}

Future<bool> confirmDelete(BuildContext context, String message) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('حذف شود؟'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('انصراف'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('حذف'),
        ),
      ],
    ),
  );
  return ok ?? false;
}
