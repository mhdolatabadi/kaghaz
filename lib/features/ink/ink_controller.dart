import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'ink_model.dart';

enum InkTool { pen, highlighter, eraser, lasso, shape, hand }

enum PenStyle { fountain, ballpoint }

/// Holds a page's strokes, the gesture in progress, selection, and undo history.
class InkController extends ChangeNotifier {
  InkController({List<Stroke> strokes = const []}) : _strokes = List.of(strokes);

  static const eraserRadius = 12.0;

  List<Stroke> _strokes;
  final _undo = <List<Stroke>>[];
  final _redo = <List<Stroke>>[];

  // Gesture state. At most one of these is active.
  List<InkPoint>? _livePoints;
  List<Stroke>? _beforeErase;
  List<Offset>? _lassoPoints;
  Offset? _shapeStart, _shapeEnd;
  Offset? _dragStart;
  Offset _dragDelta = Offset.zero;

  Set<Stroke> _selection = {};

  InkTool tool = InkTool.pen;
  PenStyle penStyle = PenStyle.fountain;
  Color penColor = const Color(0xFF1F2024);
  double penWidth = 3;
  Color highlighterColor = const Color(0xFFFFE066);
  double highlighterWidth = 18;
  ShapeKind shapeKind = ShapeKind.rectangle;

  /// Bumped when committed strokes change, so painters can skip repaints.
  int revision = 0;

  List<Stroke> get strokes => List.unmodifiable(_strokes);
  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;
  bool get hasSelection => _selection.isNotEmpty;
  bool get isDraggingSelection => _dragStart != null;
  Set<Stroke> get selection => Set.unmodifiable(_selection);
  List<Offset>? get lassoPath => _lassoPoints;

  /// Committed strokes to paint; selected strokes are left out while dragged.
  List<Stroke> get restingStrokes => isDraggingSelection
      ? _strokes.where((s) => !_selection.contains(s)).toList()
      : _strokes;

  /// Strokes painted on the live layer: the one being drawn, or the dragged selection.
  List<Stroke> get liveStrokes {
    if (_livePoints case final points?) return [_strokeFrom(points)];
    if (_shapeStart case final a?) {
      return [_shapeFrom(a, _shapeEnd ?? a)];
    }
    if (isDraggingSelection) {
      return [for (final s in _selection) s.translate(_dragDelta)];
    }
    return const [];
  }

  Rect? get selectionBounds {
    if (_selection.isEmpty) return null;
    return _selection
        .map((s) => s.bounds)
        .reduce((a, b) => a.expandToInclude(b))
        .shift(_dragDelta);
  }

  Color get activeColor =>
      tool == InkTool.highlighter ? highlighterColor : penColor;

  double get activeWidth =>
      tool == InkTool.highlighter ? highlighterWidth : penWidth;

  void setTool(InkTool value) {
    if (value != InkTool.lasso) _selection = {};
    tool = value;
    notifyListeners();
  }

  void setPenStyle(PenStyle style) {
    penStyle = style;
    notifyListeners();
  }

  void setShape(ShapeKind kind) {
    shapeKind = kind;
    tool = InkTool.shape;
    notifyListeners();
  }

  void setColor(Color color) {
    if (tool == InkTool.highlighter) {
      highlighterColor = color;
    } else {
      penColor = color;
      if (tool != InkTool.shape) tool = InkTool.pen;
    }
    notifyListeners();
  }

  void setWidth(double width) {
    if (tool == InkTool.highlighter) {
      highlighterWidth = width;
    } else {
      penWidth = width;
    }
    notifyListeners();
  }

  void begin(InkPoint point) {
    switch (tool) {
      case InkTool.pen || InkTool.highlighter:
        _livePoints = [point];
      case InkTool.eraser:
        _beforeErase = _strokes;
        _eraseAt(point.offset);
      case InkTool.shape:
        _shapeStart = point.offset;
      case InkTool.lasso:
        final bounds = selectionBounds;
        if (bounds != null && bounds.inflate(16).contains(point.offset)) {
          _dragStart = point.offset;
          _dragDelta = Offset.zero;
        } else {
          _selection = {};
          _lassoPoints = [point.offset];
        }
      case InkTool.hand:
        return;
    }
    notifyListeners();
  }

  void extend(InkPoint point) {
    if (_livePoints case final points?) {
      // Skip samples too close to the last one to matter.
      if ((points.last.offset - point.offset).distanceSquared < 0.5) return;
      points.add(point);
    } else if (_beforeErase != null) {
      _eraseAt(point.offset);
      return;
    } else if (_shapeStart != null) {
      _shapeEnd = point.offset;
    } else if (_lassoPoints case final lasso?) {
      lasso.add(point.offset);
    } else if (_dragStart case final start?) {
      _dragDelta = point.offset - start;
    } else {
      return;
    }
    notifyListeners();
  }

  void end() {
    if (_livePoints case final points?) {
      _livePoints = null;
      _commit([..._strokes, _strokeFrom(points)]);
    } else if (_beforeErase case final before?) {
      _beforeErase = null;
      if (!identical(before, _strokes)) {
        _undo.add(before);
        _redo.clear();
        notifyListeners();
      }
    } else if (_shapeStart case final a?) {
      final b = _shapeEnd ?? a;
      _shapeStart = _shapeEnd = null;
      if ((b - a).distance > 4) {
        _commit([..._strokes, _shapeFrom(a, b)]);
      } else {
        notifyListeners();
      }
    } else if (_lassoPoints case final lasso?) {
      _lassoPoints = null;
      _selection = _strokesInside(lasso);
      notifyListeners();
    } else if (_dragStart != null) {
      final delta = _dragDelta;
      _dragStart = null;
      _dragDelta = Offset.zero;
      if (delta.distance > 0.5) {
        _replaceSelection((s) => s.translate(delta));
      } else {
        notifyListeners();
      }
    }
  }

  /// Drops the gesture in progress, e.g. when a second finger starts a pinch.
  void cancel() {
    if (_beforeErase case final before?) {
      _strokes = before;
      revision++;
    }
    _livePoints = null;
    _beforeErase = null;
    _shapeStart = _shapeEnd = null;
    _lassoPoints = null;
    _dragStart = null;
    _dragDelta = Offset.zero;
    notifyListeners();
  }

  void undo() {
    if (_undo.isEmpty) return;
    _redo.add(_strokes);
    _strokes = _undo.removeLast();
    _selection = {};
    revision++;
    notifyListeners();
  }

  void redo() {
    if (_redo.isEmpty) return;
    _undo.add(_strokes);
    _strokes = _redo.removeLast();
    _selection = {};
    revision++;
    notifyListeners();
  }

  void clear() {
    if (_strokes.isEmpty) return;
    _selection = {};
    _commit(const []);
  }

  // Selection actions

  void clearSelection() {
    _selection = {};
    notifyListeners();
  }

  void deleteSelection() {
    if (_selection.isEmpty) return;
    final next = _strokes.where((s) => !_selection.contains(s)).toList();
    _selection = {};
    _commit(next);
  }

  void recolorSelection(Color color) =>
      _replaceSelection((s) => s.highlighter ? s : s.copyWith(color: color));

  void duplicateSelection() {
    if (_selection.isEmpty) return;
    final copies = [
      for (final s in _strokes)
        if (_selection.contains(s)) s.translate(const Offset(24, 24)),
    ];
    _selection = copies.toSet();
    _commit([..._strokes, ...copies]);
  }

  /// Applies [change] to each selected stroke as one undoable step.
  void _replaceSelection(Stroke Function(Stroke) change) {
    if (_selection.isEmpty) return;
    final replaced = <Stroke>{};
    final next = <Stroke>[];
    for (final s in _strokes) {
      if (_selection.contains(s)) {
        final changed = change(s);
        replaced.add(changed);
        next.add(changed);
      } else {
        next.add(s);
      }
    }
    _selection = replaced;
    _commit(next);
  }

  Set<Stroke> _strokesInside(List<Offset> lasso) {
    if (lasso.length < 3) return {};
    final path = Path()..addPolygon(lasso, true);
    final area = path.getBounds();
    return {
      for (final s in _strokes)
        if (area.overlaps(s.bounds) && _mostlyInside(s, path)) s,
    };
  }

  static bool _mostlyInside(Stroke s, Path path) {
    var inside = 0;
    for (final p in s.points) {
      if (path.contains(p.offset)) inside++;
    }
    return inside >= s.points.length * 0.6;
  }

  void _commit(List<Stroke> next) {
    _undo.add(_strokes);
    _redo.clear();
    _strokes = next;
    revision++;
    notifyListeners();
  }

  void _eraseAt(Offset point) {
    final kept = _strokes.where((s) => !s.hitTest(point, eraserRadius)).toList();
    if (kept.length != _strokes.length) {
      _strokes = kept;
      revision++;
      notifyListeners();
    }
  }

  Stroke _strokeFrom(List<InkPoint> points) {
    final highlighter = tool == InkTool.highlighter;
    return Stroke(
      points: List.of(points),
      color: highlighter ? highlighterColor : penColor,
      width: highlighter ? highlighterWidth : penWidth,
      highlighter: highlighter,
      pressure: !highlighter && penStyle == PenStyle.fountain,
    );
  }

  Stroke _shapeFrom(Offset a, Offset b) => Stroke(
        points: shapePoints(shapeKind, a, b),
        color: penColor,
        width: penWidth,
        pressure: false,
        straight: shapeKind != ShapeKind.ellipse,
      );
}
