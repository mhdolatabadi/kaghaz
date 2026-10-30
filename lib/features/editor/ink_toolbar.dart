import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../ink/ink_controller.dart';

const _penColors = [
  Color(0xFF1B1B1F),
  Color(0xFF1E5AA8),
  Color(0xFFC62828),
  Color(0xFF2E7D32),
  Color(0xFF6A1B9A),
];

const _highlighterColors = [
  Color(0xFFFFD54F),
  Color(0xFF81C784),
  Color(0xFF4FC3F7),
  Color(0xFFF48FB1),
];

const _backgroundLabels = {
  PageBackground.blank: 'ساده',
  PageBackground.lined: 'خط‌دار',
  PageBackground.grid: 'شطرنجی',
  PageBackground.dotted: 'نقطه‌ای',
};

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
    return Material(
      elevation: 3,
      child: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final c = controller;
            final highlighter = c.tool == InkTool.highlighter;
            final colors = highlighter ? _highlighterColors : _penColors;
            final selected = highlighter ? c.highlighterColor : c.penColor;
            final showStyle = c.tool == InkTool.pen || highlighter;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  _ToolButton(c, InkTool.pen, Icons.edit, 'قلم'),
                  _ToolButton(c, InkTool.highlighter, Icons.highlight, 'هایلایتر'),
                  _ToolButton(c, InkTool.eraser, Icons.auto_fix_normal, 'پاک‌کن'),
                  _ToolButton(c, InkTool.hand, Icons.pan_tool_outlined, 'جابه‌جایی'),
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
                  if (showStyle) ...[
                    const _Divider(),
                    for (final color in colors)
                      _ColorDot(
                        color: color,
                        selected: color == selected,
                        onTap: () => c.setColor(color),
                      ),
                    SizedBox(
                      width: 140,
                      child: Slider(
                        value: highlighter ? c.highlighterWidth : c.penWidth,
                        min: highlighter ? 8 : 1,
                        max: highlighter ? 40 : 16,
                        onChanged: c.setWidth,
                      ),
                    ),
                  ],
                  const _Divider(),
                  PopupMenuButton<PageBackground>(
                    tooltip: 'زمینه‌ی صفحه',
                    icon: const Icon(Icons.grid_on),
                    initialValue: background,
                    onSelected: onBackgroundChanged,
                    itemBuilder: (_) => [
                      for (final entry in _backgroundLabels.entries)
                        PopupMenuItem(value: entry.key, child: Text(entry.value)),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton(this.controller, this.tool, this.icon, this.label);

  final InkController controller;
  final InkTool tool;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: label,
      isSelected: controller.tool == tool,
      onPressed: () => controller.setTool(tool),
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: controller.tool == tool
            ? Theme.of(context).colorScheme.secondaryContainer
            : null,
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkResponse(
        onTap: onTap,
        radius: 20,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              width: selected ? 3 : 1,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black26,
            ),
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
