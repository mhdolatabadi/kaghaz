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

/// Paints the gesture in progress and the selection, so committed ink is
/// not repainted on every pointer move.
class LivePainter extends CustomPainter {
  LivePainter({
    required this.strokes,
    this.lasso,
    this.selectionBounds,
    required this.accent,
  });

  final List<Stroke> strokes;
  final List<Offset>? lasso;
  final Rect? selectionBounds;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      paintStroke(canvas, s);
    }
    final outline = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    if (lasso case final points? when points.length > 1) {
      canvas.drawPath(
        _dashed(Path()..addPolygon(points, false)),
        outline,
      );
    }
    if (selectionBounds case final rect?) {
      final r = RRect.fromRectAndRadius(rect.inflate(10), const Radius.circular(8));
      canvas.drawRRect(r, Paint()..color = accent.withValues(alpha: 0.06));
      canvas.drawPath(_dashed(Path()..addRRect(r)), outline);
      // Resize handle at the bottom-right corner.
      final handle = r.outerRect.bottomRight;
      canvas.drawCircle(handle, 11, Paint()..color = const Color(0xFFFFFFFF));
      canvas.drawCircle(handle, 11, outline..strokeWidth = 2.5);
      canvas.drawCircle(handle, 4, Paint()..color = accent);
    }
  }

  @override
  bool shouldRepaint(LivePainter old) => true;
}

Path _dashed(Path source, {double dash = 10, double gap = 6}) {
  final out = Path();
  for (final metric in source.computeMetrics()) {
    for (var d = 0.0; d < metric.length; d += dash + gap) {
      out.addPath(metric.extractPath(d, d + dash), Offset.zero);
    }
  }
  return out;
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

  if (!stroke.pressure) {
    paint.strokeWidth = stroke.width;
    final path = stroke.straight
        ? (Path()..addPolygon([for (final p in points) p.offset], false))
        : _smoothPath(points);
    canvas.drawPath(path, paint);
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
