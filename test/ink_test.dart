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
    expect(c.liveStroke, isNull);

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
}
