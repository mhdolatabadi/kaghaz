import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

/// A sampled pen position with normalized pressure in [0, 1].
class InkPoint {
  const InkPoint(this.x, this.y, [this.pressure = 0.5]);

  final double x;
  final double y;
  final double pressure;

  Offset get offset => Offset(x, y);

  List<double> toJson() => [_round(x), _round(y), _round(pressure)];

  factory InkPoint.fromJson(List<dynamic> json) => InkPoint(
        (json[0] as num).toDouble(),
        (json[1] as num).toDouble(),
        json.length > 2 ? (json[2] as num).toDouble() : 0.5,
      );

  static double _round(double v) => (v * 100).roundToDouble() / 100;
}

class Stroke {
  const Stroke({
    required this.points,
    required this.color,
    required this.width,
    this.highlighter = false,
    this.pressure = true,
    this.straight = false,
  });

  final List<InkPoint> points;
  final Color color;
  final double width;
  final bool highlighter;

  /// Whether pen pressure varies the width (fountain pen) or not (ballpoint).
  final bool pressure;

  /// Drawn with straight segments, for shapes with corners.
  final bool straight;

  Stroke copyWith({List<InkPoint>? points, Color? color}) => Stroke(
        points: points ?? this.points,
        color: color ?? this.color,
        width: width,
        highlighter: highlighter,
        pressure: pressure,
        straight: straight,
      );

  Stroke translate(Offset delta) => copyWith(points: [
        for (final p in points) InkPoint(p.x + delta.dx, p.y + delta.dy, p.pressure),
      ]);

  Rect get bounds {
    var left = double.infinity, top = double.infinity;
    var right = -double.infinity, bottom = -double.infinity;
    for (final p in points) {
      left = math.min(left, p.x);
      top = math.min(top, p.y);
      right = math.max(right, p.x);
      bottom = math.max(bottom, p.y);
    }
    return Rect.fromLTRB(left, top, right, bottom).inflate(width);
  }

  /// Whether a circle of [radius] around [point] touches this stroke.
  bool hitTest(Offset point, double radius) {
    final reach = radius + width / 2;
    if (!bounds.inflate(radius).contains(point)) return false;
    if (points.length == 1) return (points.first.offset - point).distance <= reach;
    for (var i = 1; i < points.length; i++) {
      if (_distanceToSegment(point, points[i - 1].offset, points[i].offset) <= reach) {
        return true;
      }
    }
    return false;
  }

  Map<String, dynamic> toJson() => {
        'c': color.toARGB32(),
        'w': width,
        if (highlighter) 'h': true,
        if (!pressure) 'f': false,
        if (straight) 's': true,
        'p': [for (final p in points) p.toJson()],
      };

  factory Stroke.fromJson(Map<String, dynamic> json) => Stroke(
        color: Color(json['c'] as int),
        width: (json['w'] as num).toDouble(),
        highlighter: json['h'] == true,
        pressure: json['f'] != false,
        straight: json['s'] == true,
        points: [
          for (final p in json['p'] as List) InkPoint.fromJson(p as List),
        ],
      );

  static double _distanceToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final lengthSq = ab.dx * ab.dx + ab.dy * ab.dy;
    if (lengthSq == 0) return (p - a).distance;
    final ap = p - a;
    final t = ((ap.dx * ab.dx + ap.dy * ab.dy) / lengthSq).clamp(0.0, 1.0);
    return (p - (a + ab * t)).distance;
  }
}

/// Serialization for a page's strokes.
abstract final class InkDocument {
  static String encode(List<Stroke> strokes) =>
      jsonEncode([for (final s in strokes) s.toJson()]);

  static List<Stroke> decode(String source) {
    if (source.isEmpty) return const [];
    return [
      for (final s in jsonDecode(source) as List)
        Stroke.fromJson(s as Map<String, dynamic>),
    ];
  }
}

enum ShapeKind { line, arrow, rectangle, ellipse }

/// Points outlining [kind] between two corners of a drag.
List<InkPoint> shapePoints(ShapeKind kind, Offset a, Offset b) {
  InkPoint p(Offset o) => InkPoint(o.dx, o.dy);
  switch (kind) {
    case ShapeKind.line:
      return [p(a), p(b)];
    case ShapeKind.arrow:
      final d = b - a;
      if (d.distance < 1) return [p(a), p(b)];
      final dir = d / d.distance;
      final head = math.min(36.0, d.distance / 3);
      Offset wing(double angle) {
        final c = math.cos(angle), s = math.sin(angle);
        return b - Offset(dir.dx * c - dir.dy * s, dir.dx * s + dir.dy * c) * head;
      }
      return [p(a), p(b), p(wing(0.5)), p(b), p(wing(-0.5))];
    case ShapeKind.rectangle:
      return [p(a), p(Offset(b.dx, a.dy)), p(b), p(Offset(a.dx, b.dy)), p(a)];
    case ShapeKind.ellipse:
      final rect = Rect.fromPoints(a, b);
      const steps = 64;
      return [
        for (var i = 0; i <= steps; i++)
          p(rect.center +
              Offset(
                math.cos(2 * math.pi * i / steps) * rect.width / 2,
                math.sin(2 * math.pi * i / steps) * rect.height / 2,
              )),
      ];
  }
}
