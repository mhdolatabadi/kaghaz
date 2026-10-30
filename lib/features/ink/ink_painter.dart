import 'dart:ui' show PointMode;

import 'package:flutter/rendering.dart';

import '../../core/db/database.dart';
import 'ink_model.dart';

/// Paints a list of strokes in page coordinates.
class StrokesPainter extends CustomPainter {
  StrokesPainter(this.strokes, {this.revision = 0});

  final List<Stroke> strokes;
  final int revision;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      paintStroke(canvas, stroke);
    }
  }

  @override
  bool shouldRepaint(StrokesPainter old) =>
      old.revision != revision || !identical(old.strokes, strokes);
}

/// Paints only the stroke being drawn, so committed ink is not repainted.
class LiveStrokePainter extends CustomPainter {
  LiveStrokePainter(this.stroke);

  final Stroke? stroke;

  @override
  void paint(Canvas canvas, Size size) {
    if (stroke case final s?) paintStroke(canvas, s);
  }

  @override
  bool shouldRepaint(LiveStrokePainter old) => true;
}

void paintStroke(Canvas canvas, Stroke stroke) {
  final points = stroke.points;
  if (points.isEmpty) return;

  final paint = Paint()
    ..color = stroke.color
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true;

  if (stroke.highlighter) {
    // Constant width and translucent so ink underneath stays readable.
    paint
      ..color = stroke.color.withValues(alpha: 0.4)
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.square;
    canvas.drawPath(_smoothPath(points), paint);
    return;
  }

  if (points.length == 1) {
    canvas.drawCircle(
      points.first.offset,
      _widthAt(stroke, points.first) / 2,
      paint..style = PaintingStyle.fill,
    );
    return;
  }

  // Pressure varies the width, so draw short segments between midpoints.
  var from = points.first.offset;
  for (var i = 1; i < points.length; i++) {
    final p = points[i];
    final to = i == points.length - 1
        ? p.offset
        : Offset.lerp(p.offset, points[i + 1].offset, 0.5)!;
    paint.strokeWidth = _widthAt(stroke, p);
    canvas.drawPath(
      Path()
        ..moveTo(from.dx, from.dy)
        ..quadraticBezierTo(p.x, p.y, to.dx, to.dy),
      paint,
    );
    from = to;
  }
}

double _widthAt(Stroke stroke, InkPoint point) =>
    stroke.width * (0.4 + 0.9 * point.pressure);

Path _smoothPath(List<InkPoint> points) {
  final path = Path()..moveTo(points.first.x, points.first.y);
  if (points.length == 1) return path..lineTo(points.first.x + 0.1, points.first.y);
  for (var i = 1; i < points.length - 1; i++) {
    final mid = Offset.lerp(points[i].offset, points[i + 1].offset, 0.5)!;
    path.quadraticBezierTo(points[i].x, points[i].y, mid.dx, mid.dy);
  }
  return path..lineTo(points.last.x, points.last.y);
}

/// Draws the paper pattern behind a page.
class PaperPainter extends CustomPainter {
  PaperPainter(this.background, {required this.lineColor});

  final PageBackground background;
  final Color lineColor;

  static const spacing = 40.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    switch (background) {
      case PageBackground.blank:
        return;
      case PageBackground.lined:
        for (var y = spacing * 2; y < size.height; y += spacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
      case PageBackground.grid:
        for (var y = spacing; y < size.height; y += spacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
        for (var x = spacing; x < size.width; x += spacing) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
        }
      case PageBackground.dotted:
        paint.strokeWidth = 3;
        paint.strokeCap = StrokeCap.round;
        final dots = <Offset>[
          for (var y = spacing; y < size.height; y += spacing)
            for (var x = spacing; x < size.width; x += spacing) Offset(x, y),
        ];
        canvas.drawPoints(PointMode.points, dots, paint);
    }
  }

  @override
  bool shouldRepaint(PaperPainter old) =>
      old.background != background || old.lineColor != lineColor;
}
