import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'ink_model.dart';

enum InkTool { pen, highlighter, eraser, hand }

/// Holds a page's strokes, the stroke being drawn, and undo history.
class InkController extends ChangeNotifier {
  InkController({List<Stroke> strokes = const []}) : _strokes = List.of(strokes);

  static const eraserRadius = 12.0;

  List<Stroke> _strokes;
  final _undo = <List<Stroke>>[];
  final _redo = <List<Stroke>>[];

  List<InkPoint>? _livePoints;
  List<Stroke>? _beforeErase;

  InkTool tool = InkTool.pen;
  Color penColor = const Color(0xFF1B1B1F);
  double penWidth = 3;
  Color highlighterColor = const Color(0xFFFFD54F);
  double highlighterWidth = 18;

  List<Stroke> get strokes => List.unmodifiable(_strokes);
  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  /// The stroke under the pen, not yet committed.
  Stroke? get liveStroke {
    final points = _livePoints;
    if (points == null) return null;
    return _strokeFrom(points);
  }

  /// Bumped when committed strokes change, so painters can skip repaints.
  int revision = 0;

  void setTool(InkTool value) {
    tool = value;
    notifyListeners();
  }

  void setColor(Color color) {
    if (tool == InkTool.highlighter) {
      highlighterColor = color;
    } else {
      penColor = color;
      if (tool != InkTool.pen) tool = InkTool.pen;
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
      case InkTool.hand:
        return;
    }
    notifyListeners();
  }

  void extend(InkPoint point) {
    final points = _livePoints;
    if (points != null) {
      // Skip samples too close to the last one to matter.
      if ((points.last.offset - point.offset).distanceSquared < 0.5) return;
      points.add(point);
      notifyListeners();
    } else if (_beforeErase != null) {
      _eraseAt(point.offset);
    }
  }

  void end() {
    final points = _livePoints;
    if (points != null) {
      _livePoints = null;
      _commit([..._strokes, _strokeFrom(points)]);
    } else if (_beforeErase case final before?) {
      _beforeErase = null;
      if (!identical(before, _strokes)) {
        _undo.add(before);
        _redo.clear();
        notifyListeners();
      }
    }
  }

  /// Drops the stroke in progress, e.g. when a second finger starts a pinch.
  void cancel() {
    if (_livePoints != null) {
      _livePoints = null;
      notifyListeners();
    } else if (_beforeErase case final before?) {
      _beforeErase = null;
      _strokes = before;
      revision++;
      notifyListeners();
    }
  }

  void undo() {
    if (_undo.isEmpty) return;
    _redo.add(_strokes);
    _strokes = _undo.removeLast();
    revision++;
    notifyListeners();
  }

  void redo() {
    if (_redo.isEmpty) return;
    _undo.add(_strokes);
    _strokes = _redo.removeLast();
    revision++;
    notifyListeners();
  }

  void clear() {
    if (_strokes.isEmpty) return;
    _commit(const []);
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
    );
  }
}
