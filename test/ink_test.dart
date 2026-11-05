import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kaghaz/features/ink/ink_controller.dart';
import 'package:kaghaz/features/ink/ink_model.dart';

void main() {
  void drawLine(InkController c, Offset from, Offset to) {
    c.begin(InkPoint(from.dx, from.dy));
    for (var t = 0.1; t <= 1.0; t += 0.1) {
      final p = Offset.lerp(from, to, t)!;
      c.extend(InkPoint(p.dx, p.dy, 0.8));
    }
    c.end();
  }

  test('strokes survive encode/decode', () {
    final stroke = Stroke(
      points: const [InkPoint(1, 2, 0.3), InkPoint(4.5, 6.25, 1)],
      color: const Color(0xFF112233),
      width: 3,
      highlighter: true,
    );
    final decoded = InkDocument.decode(InkDocument.encode([stroke])).single;
    expect(decoded.color, stroke.color);
    expect(decoded.width, 3);
    expect(decoded.highlighter, isTrue);
    expect(decoded.points[1].x, 4.5);
    expect(decoded.points[1].pressure, 1);
  });

  test('drawing commits a stroke and undo/redo restore it', () {
    final c = InkController();
    drawLine(c, Offset.zero, const Offset(100, 0));
    expect(c.strokes, hasLength(1));
    expect(c.liveStrokes, isEmpty);

    c.undo();
    expect(c.strokes, isEmpty);
    c.redo();
    expect(c.strokes, hasLength(1));
  });

  test('eraser removes touched strokes as one undoable step', () {
    final c = InkController();
    drawLine(c, Offset.zero, const Offset(100, 0));
    drawLine(c, const Offset(0, 200), const Offset(100, 200));

    c.setTool(InkTool.eraser);
    c.begin(const InkPoint(50, 3));
    c.extend(const InkPoint(52, 3));
    c.end();
    expect(c.strokes, hasLength(1));
    expect(c.strokes.single.points.first.y, 200);

    c.undo();
    expect(c.strokes, hasLength(2));
  });

  test('cancel drops the stroke in progress', () {
    final c = InkController();
    c.begin(const InkPoint(0, 0));
    c.extend(const InkPoint(10, 10));
    c.cancel();
    expect(c.strokes, isEmpty);
    expect(c.canUndo, isFalse);
  });

  test('highlighter uses its own color and width', () {
    final c = InkController()..setTool(InkTool.highlighter);
    drawLine(c, Offset.zero, const Offset(50, 0));
    final s = c.strokes.single;
    expect(s.highlighter, isTrue);
    expect(s.color, c.highlighterColor);
    expect(s.width, c.highlighterWidth);
  });

  test('shapes commit as straight, uniform strokes', () {
    final c = InkController()..setShape(ShapeKind.rectangle);
    c.begin(const InkPoint(10, 10));
    c.extend(const InkPoint(110, 60));
    c.end();
    final s = c.strokes.single;
    expect(s.straight, isTrue);
    expect(s.pressure, isFalse);
    expect(s.points, hasLength(5));
    expect(s.bounds.contains(const Offset(110, 60)), isTrue);
  });

  test('a tap with the shape tool adds nothing', () {
    final c = InkController()..setShape(ShapeKind.line);
    c.begin(const InkPoint(10, 10));
    c.end();
    expect(c.strokes, isEmpty);
  });

  test('ballpoint strokes ignore pressure', () {
    final c = InkController()..setPenStyle(PenStyle.ballpoint);
    drawLine(c, Offset.zero, const Offset(50, 0));
    expect(c.strokes.single.pressure, isFalse);
    final decoded = InkDocument.decode(InkDocument.encode(c.strokes)).single;
    expect(decoded.pressure, isFalse);
  });

  group('lasso', () {
    InkController withTwoLines() {
      final c = InkController();
      drawLine(c, const Offset(10, 10), const Offset(60, 10));
      drawLine(c, const Offset(10, 300), const Offset(60, 300));
      c.setTool(InkTool.lasso);
      // Loop around the first line only.
      for (final p in const [
        Offset(0, 0), Offset(80, 0), Offset(80, 30), Offset(0, 30),
      ]) {
        if (p == Offset.zero) {
          c.begin(InkPoint(p.dx, p.dy));
        } else {
          c.extend(InkPoint(p.dx, p.dy));
        }
      }
      c.end();
      return c;
    }

    test('selects only enclosed strokes', () {
      final c = withTwoLines();
      expect(c.selection, hasLength(1));
      expect(c.selection.single.points.first.y, 10);
    });

    test('dragging moves the selection as one undoable step', () {
      final c = withTwoLines();
      c.begin(const InkPoint(30, 10));
      c.extend(const InkPoint(30, 110));
      expect(c.isDraggingSelection, isTrue);
      c.end();
      final moved = c.strokes.firstWhere((s) => s.points.first.y > 100 && s.points.first.y < 200);
      expect(moved.points.first.y, closeTo(110, 0.01));
      expect(c.selection.single, same(moved));
      c.undo();
      expect(c.strokes.first.points.first.y, 10);
    });

    test('dragging the corner handle scales the selection', () {
      final c = withTwoLines();
      final before = c.selection.single.bounds;
      final handle = c.selectionHandle!;
      c.begin(InkPoint(handle.dx, handle.dy));
      final target = before.topLeft + (handle - before.topLeft) * 2;
      c.extend(InkPoint(target.dx, target.dy));
      c.end();
      final after = c.selection.single.bounds;
      // Bounds include the line width (3 per side), which does not scale.
      expect(after.width, closeTo((before.width - 6) * 2 + 6, 0.5));
      expect(c.selection.single.width, 3);
      c.undo();
      expect(c.strokes.first.bounds.width, closeTo(before.width, 0.01));
    });

    test('line width of the selection can change', () {
      final c = withTwoLines();
      c.setSelectionWidth(9);
      expect(c.selection.single.width, 9);
      expect(c.strokes.last.width, 3);
    });

    test('delete, duplicate and recolor act on the selection', () {
      final c = withTwoLines();
      c.duplicateSelection();
      expect(c.strokes, hasLength(3));
      c.recolorSelection(const Color(0xFFFF0000));
      expect(c.selection.single.color, const Color(0xFFFF0000));
      c.deleteSelection();
      expect(c.strokes, hasLength(2));
      expect(c.hasSelection, isFalse);
    });
  });
}
