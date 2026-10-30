import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../core/theme.dart';
import '../ink/ink_painter.dart';

const coverColors = KaghazColors.covers;

const paperLabels = {
  PageBackground.blank: 'ساده',
  PageBackground.lined: 'خط‌دار',
  PageBackground.grid: 'شطرنجی',
  PageBackground.dotted: 'نقطه‌ای',
};

class NotebookSettings {
  const NotebookSettings(this.title, this.color, this.paper);
  final String title;
  final Color color;
  final PageBackground paper;
}

/// Creates a notebook, or edits one when [initial] is given.
Future<NotebookSettings?> showNotebookDialog(
  BuildContext context, {
  NotebookSettings? initial,
  int seed = 0,
}) {
  return showDialog<NotebookSettings>(
    context: context,
    builder: (_) => _NotebookDialog(
      initial: initial ??
          NotebookSettings(
            '',
            coverColors[seed % coverColors.length],
            PageBackground.lined,
          ),
      editing: initial != null,
    ),
  );
}

class _NotebookDialog extends StatefulWidget {
  const _NotebookDialog({required this.initial, required this.editing});

  final NotebookSettings initial;
  final bool editing;

  @override
  State<_NotebookDialog> createState() => _NotebookDialogState();
}

class _NotebookDialogState extends State<_NotebookDialog> {
  late final _title = TextEditingController(text: widget.initial.title);
  late Color _color = widget.initial.color;
  late PageBackground _paper = widget.initial.paper;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _title.text.trim();
    Navigator.pop(
      context,
      NotebookSettings(title.isEmpty ? 'دفترچه‌ی بی‌نام' : title, _color, _paper),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(widget.editing ? 'ویرایش دفترچه' : 'دفترچه‌ی جدید'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  NotebookCoverArt(color: _color, title: _title.text, width: 72),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _title,
                      autofocus: !widget.editing,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(hintText: 'نام دفترچه'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('رنگ جلد', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in coverColors)
                    InkResponse(
                      onTap: () => setState(() => _color = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 3,
                            color: c == _color
                                ? theme.colorScheme.onSurface
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                widget.editing ? 'کاغذ صفحه‌های جدید' : 'نوع کاغذ',
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final paper in PageBackground.values)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: PaperOption(
                          paper: paper,
                          selected: paper == _paper,
                          onTap: () => setState(() => _paper = paper),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('انصراف'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.editing ? 'ذخیره' : 'ساختن'),
        ),
      ],
    );
  }
}

class PaperOption extends StatelessWidget {
  const PaperOption({
    super.key,
    required this.paper,
    required this.selected,
    required this.onTap,
  });

  final PageBackground paper;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 0.72,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  width: selected ? 2.5 : 1,
                  color: selected ? scheme.primary : scheme.outlineVariant,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: 400,
                  height: 560,
                  child: CustomPaint(
                    painter: PaperPainter(
                      paper,
                      lineColor: scheme.primary.withValues(alpha: 0.25),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(paperLabels[paper]!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// A notebook cover: coloured board with a darker binding strip, a subtle
/// diagonal pattern, and the title printed near the bottom.
class NotebookCoverArt extends StatelessWidget {
  const NotebookCoverArt({
    super.key,
    required this.color,
    required this.title,
    this.width,
    this.lifted = false,
  });

  final Color color;
  final String title;
  final double? width;
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(color);
    final binding =
        hsl.withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0)).toColor();
    final light = ThemeData.estimateBrightnessForColor(color) == Brightness.light;
    final ink = light ? const Color(0xE61F2024) : Colors.white;
    final small = (width ?? 200) < 100;
    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: lifted
                ? floatingShadow
                : const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _StripePainter(Colors.white.withValues(alpha: 0.07))),
              PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                child: Container(width: small ? 4 : 7, color: binding),
              ),
              if (!small && title.isNotEmpty)
                PositionedDirectional(
                  start: 18,
                  end: 12,
                  bottom: 12,
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  _StripePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 8;
    for (var x = -size.height; x < size.width; x += 22) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(_StripePainter old) => old.color != color;
}
