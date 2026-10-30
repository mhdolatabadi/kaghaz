import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../core/theme.dart';
import '../ink/ink_controller.dart';
import '../ink/ink_model.dart';
import '../ink/ink_painter.dart';
import '../library/notebook_dialog.dart';

/// Floating pill with the drawing tools.
///
/// Tap a tool to select it; tap the selected tool again for its options.
class InkToolbar extends StatelessWidget {
  const InkToolbar({
    super.key,
    required this.controller,
    required this.background,
    required this.onBackgroundChanged,
  });

  final InkController controller;
  final PageBackground background;
  final ValueChanged<PageBackground> onBackgroundChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final c = controller;
        // Always five swatches so the pill keeps its width and tools don't
        // shift. Picking a pen colour from another tool switches to the pen.
        final swatches = c.tool == InkTool.highlighter
            ? KaghazColors.highlighters
            : KaghazColors.pens.take(5).toList();
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: scheme.outlineVariant),
            boxShadow: floatingShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ToolButton(c, InkTool.pen, Icons.edit_outlined, 'قلم',
                      options: (_) => _PenOptions(c)),
                  _ToolButton(c, InkTool.highlighter, Icons.border_color_outlined, 'هایلایتر',
                      options: (_) => _HighlighterOptions(c)),
                  _ToolButton(c, InkTool.eraser, Icons.cleaning_services_outlined, 'پاک‌کن',
                      options: (close) => _EraserOptions(c, close)),
                  _ToolButton(c, InkTool.lasso, Icons.gesture, 'انتخاب کمندی'),
                  _ToolButton(c, InkTool.shape, _shapeIcon(c.shapeKind), 'شکل',
                      options: (_) => _ShapeOptions(c)),
                  _ToolButton(c, InkTool.hand, Icons.pan_tool_outlined, 'جابه‌جایی صفحه'),
                  const _Divider(),
                  for (final color in swatches)
                    _Swatch(
                      color: color,
                      selected: color == c.activeColor &&
                          {InkTool.pen, InkTool.highlighter, InkTool.shape}
                              .contains(c.tool),
                      onTap: () => c.setColor(color),
                    ),
                  const _Divider(),
                  IconButton(
                    tooltip: 'واگرد',
                    onPressed: c.canUndo ? c.undo : null,
                    icon: const Icon(Icons.undo),
                  ),
                  IconButton(
                    tooltip: 'ازنو',
                    onPressed: c.canRedo ? c.redo : null,
                    icon: const Icon(Icons.redo),
                  ),
                  PopupMenuButton<PageBackground>(
                    tooltip: 'کاغذ صفحه',
                    icon: const Icon(Icons.grid_4x4),
                    initialValue: background,
                    onSelected: onBackgroundChanged,
                    itemBuilder: (_) => [
                      for (final e in paperLabels.entries)
                        PopupMenuItem(value: e.key, child: Text(e.value)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

IconData _shapeIcon(ShapeKind kind) => switch (kind) {
      ShapeKind.line => Icons.horizontal_rule,
      ShapeKind.arrow => Icons.north_east,
      ShapeKind.rectangle => Icons.crop_square,
      ShapeKind.ellipse => Icons.circle_outlined,
    };

class _ToolButton extends StatefulWidget {
  const _ToolButton(this.controller, this.tool, this.icon, this.label, {this.options});

  final InkController controller;
  final InkTool tool;
  final IconData icon;
  final String label;

  /// Builds the options popover, given a callback that closes it.
  final Widget Function(VoidCallback close)? options;

  @override
  State<_ToolButton> createState() => _ToolButtonState();
}

class _ToolButtonState extends State<_ToolButton> {
  final _menu = MenuController();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = widget.controller.tool == widget.tool;
    final button = IconButton(
      tooltip: widget.label,
      isSelected: selected,
      onPressed: () {
        if (selected && widget.options != null) {
          _menu.isOpen ? _menu.close() : _menu.open();
        } else {
          widget.controller.setTool(widget.tool);
        }
      },
      icon: Icon(widget.icon),
      style: IconButton.styleFrom(
        minimumSize: const Size(44, 44),
        foregroundColor: scheme.onSurface,
        backgroundColor: selected ? scheme.primaryContainer : null,
      ).copyWith(
        foregroundColor: WidgetStatePropertyAll(
          selected ? scheme.primary : scheme.onSurface,
        ),
      ),
    );
    if (widget.options == null) return button;
    return MenuAnchor(
      controller: _menu,
      alignmentOffset: const Offset(0, 8),
      style: MenuStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.all(16)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant),
        )),
      ),
      menuChildren: [
        SizedBox(width: 260, child: widget.options!(_menu.close)),
      ],
      child: button,
    );
  }
}

class _PenOptions extends StatelessWidget {
  const _PenOptions(this.c);

  final InkController c;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _OptionTitle('نوع قلم'),
          SegmentedButton<PenStyle>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: PenStyle.ballpoint, label: Text('خودکار')),
              ButtonSegment(value: PenStyle.fountain, label: Text('خودنویس')),
            ],
            selected: {c.penStyle},
            onSelectionChanged: (s) => c.setPenStyle(s.single),
          ),
          const SizedBox(height: 16),
          _WidthControl(c, min: 1, max: 16),
          const SizedBox(height: 12),
          const _OptionTitle('رنگ'),
          _ColorGrid(c, KaghazColors.pens),
        ],
      ),
    );
  }
}

class _HighlighterOptions extends StatelessWidget {
  const _HighlighterOptions(this.c);

  final InkController c;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WidthControl(c, min: 8, max: 40),
          const SizedBox(height: 12),
          const _OptionTitle('رنگ'),
          _ColorGrid(c, KaghazColors.highlighters),
        ],
      ),
    );
  }
}

class _ShapeOptions extends StatelessWidget {
  const _ShapeOptions(this.c);

  final InkController c;

  static const _labels = {
    ShapeKind.line: 'خط',
    ShapeKind.arrow: 'فلش',
    ShapeKind.rectangle: 'مستطیل',
    ShapeKind.ellipse: 'بیضی',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _OptionTitle('شکل'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final kind in ShapeKind.values)
                Tooltip(
                  message: _labels[kind]!,
                  child: IconButton(
                    isSelected: c.shapeKind == kind,
                    onPressed: () => c.setShape(kind),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          c.shapeKind == kind ? scheme.primaryContainer : null,
                    ),
                    icon: Icon(
                      _shapeIcon(kind),
                      color: c.shapeKind == kind ? scheme.primary : null,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _WidthControl(c, min: 1, max: 16),
          const SizedBox(height: 12),
          const _OptionTitle('رنگ'),
          _ColorGrid(c, KaghazColors.pens),
        ],
      ),
    );
  }
}

class _EraserOptions extends StatelessWidget {
  const _EraserOptions(this.c, this.close);

  final InkController c;
  final VoidCallback close;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'پاک‌کن هر خطی را که لمس کند کامل پاک می‌کند. سر پاک‌کن قلم نوری هم کار می‌کند.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              c.clear();
              close();
            },
            icon: const Icon(Icons.delete_sweep_outlined),
            label: const Text('پاک کردن کل صفحه'),
          ),
        ),
      ],
    );
  }
}

class _OptionTitle extends StatelessWidget {
  const _OptionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.labelLarge),
      );
}

/// Width slider with a live preview stroke in the current colour.
class _WidthControl extends StatelessWidget {
  const _WidthControl(this.c, {required this.min, required this.max});

  final InkController c;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    final highlighter = c.tool == InkTool.highlighter;
    final preview = Stroke(
      points: [
        for (var i = 0; i <= 24; i++)
          InkPoint(10 + i * 9.5, 18 + 8 * _wave(i / 24), 0.3 + 0.5 * (i / 24)),
      ],
      color: c.activeColor,
      width: c.activeWidth,
      highlighter: highlighter,
      pressure: !highlighter &&
          c.tool == InkTool.pen &&
          c.penStyle == PenStyle.fountain,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _OptionTitle('ضخامت'),
        SizedBox(
          height: 36,
          width: double.infinity,
          child: CustomPaint(painter: StrokesPainter([preview])),
        ),
        Slider(
          value: c.activeWidth.clamp(min, max),
          min: min,
          max: max,
          onChanged: c.setWidth,
        ),
      ],
    );
  }

  static double _wave(double t) => -((t * 2 - 1) * (t * 2 - 1)) + 0.5 - 0.5 * (t - 0.5);
}

class _ColorGrid extends StatelessWidget {
  const _ColorGrid(this.c, this.colors);

  final InkController c;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final color in colors)
          _Swatch(
            color: color,
            selected: color == c.activeColor,
            onTap: () => c.setColor(color),
          ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkResponse(
        onTap: onTap,
        radius: 20,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 30,
          height: 30,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              width: 2,
              color: selected ? scheme.primary : Colors.transparent,
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: 28, child: VerticalDivider(width: 16));
}

/// Actions for strokes picked with the lasso.
class SelectionBar extends StatelessWidget {
  const SelectionBar({super.key, required this.controller});

  final InkController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final c = controller;
        final visible = c.hasSelection && !c.isDraggingSelection;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: !visible
              ? const SizedBox.shrink()
              : Material(
                  key: const ValueKey('selection'),
                  color: KaghazColors.textPrimary,
                  borderRadius: BorderRadius.circular(14),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: IconTheme(
                      data: const IconThemeData(color: Colors.white, size: 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '${fa(c.selection.length)} خط انتخاب شد',
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                          IconButton(
                            tooltip: 'کپی',
                            onPressed: c.duplicateSelection,
                            icon: const Icon(Icons.copy_outlined),
                          ),
                          MenuAnchor(
                            menuChildren: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 220,
                                  child: Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      for (final color in KaghazColors.pens)
                                        _Swatch(
                                          color: color,
                                          selected: false,
                                          onTap: () => c.recolorSelection(color),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            builder: (context, menu, _) => IconButton(
                              tooltip: 'تغییر رنگ',
                              onPressed: () => menu.isOpen ? menu.close() : menu.open(),
                              icon: const Icon(Icons.palette_outlined),
                            ),
                          ),
                          IconButton(
                            tooltip: 'حذف',
                            onPressed: c.deleteSelection,
                            icon: const Icon(Icons.delete_outline),
                          ),
                          IconButton(
                            tooltip: 'لغو انتخاب',
                            onPressed: c.clearSelection,
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
