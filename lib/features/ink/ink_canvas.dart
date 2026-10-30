import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import 'ink_controller.dart';
import 'ink_model.dart';
import 'ink_painter.dart';

/// Logical size of every page, roughly A4 proportions.
const pageSize = Size(1240, 1754);

/// A zoomable page that turns pointer input into strokes.
///
/// Drawing uses one pointer. A second touch cancels the stroke and the
/// gesture becomes a pinch/pan. Once a stylus is seen, touches only pan and
/// zoom so a resting palm does not draw.
class InkCanvas extends StatefulWidget {
  const InkCanvas({
    super.key,
    required this.controller,
    required this.background,
    this.topInset = 12,
  });

  final InkController controller;
  final PageBackground background;

  /// Space above the page at the initial fit, e.g. for a floating toolbar.
  final double topInset;

  @override
  State<InkCanvas> createState() => _InkCanvasState();
}

class _InkCanvasState extends State<InkCanvas> {
  final _transform = TransformationController();
  final _touches = <int>{};
  int? _drawingPointer;
  bool _stylusSeen = false;
  Size? _fittedTo;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  bool _draws(PointerEvent e) {
    if (widget.controller.tool == InkTool.hand) return false;
    return switch (e.kind) {
      PointerDeviceKind.stylus || PointerDeviceKind.invertedStylus => true,
      PointerDeviceKind.mouse => e.buttons == kPrimaryButton,
      PointerDeviceKind.touch => !_stylusSeen && _touches.length <= 1,
      _ => false,
    };
  }

  InkPoint _point(PointerEvent e) {
    final range = e.pressureMax - e.pressureMin;
    final pressure = range > 0 ? ((e.pressure - e.pressureMin) / range) : 0.5;
    return InkPoint(e.localPosition.dx, e.localPosition.dy, pressure.clamp(0.0, 1.0));
  }

  void _onDown(PointerDownEvent e) {
    if (e.kind == PointerDeviceKind.stylus ||
        e.kind == PointerDeviceKind.invertedStylus) {
      if (!_stylusSeen) setState(() => _stylusSeen = true);
    }
    if (e.kind == PointerDeviceKind.touch) {
      _touches.add(e.pointer);
      if (_touches.length > 1 && _drawingPointer != null) {
        widget.controller.cancel();
        _drawingPointer = null;
      }
    }
    if (_drawingPointer == null && _draws(e)) {
      _drawingPointer = e.pointer;
      final c = widget.controller;
      // The stylus eraser end erases regardless of the selected tool.
      if (e.kind == PointerDeviceKind.invertedStylus && c.tool != InkTool.eraser) {
        final previous = c.tool;
        c.tool = InkTool.eraser;
        c.begin(_point(e));
        c.tool = previous;
      } else {
        c.begin(_point(e));
      }
    }
  }

  void _onMove(PointerMoveEvent e) {
    if (e.pointer == _drawingPointer) widget.controller.extend(_point(e));
  }

  void _onUp(PointerEvent e) {
    _touches.remove(e.pointer);
    if (e.pointer == _drawingPointer) {
      _drawingPointer = null;
      if (e is PointerCancelEvent) {
        widget.controller.cancel();
      } else {
        widget.controller.end();
      }
    }
  }

  void _fit(Size viewport) {
    if (_fittedTo == viewport) return;
    _fittedTo = viewport;
    final scale = (viewport.width - 24) / pageSize.width;
    final dx = (viewport.width - pageSize.width * scale) / 2;
    _transform.value = Matrix4.identity()
      ..translateByDouble(dx, widget.topInset, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(builder: (context, constraints) {
      _fit(constraints.biggest);
      return ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final c = widget.controller;
          final panWithOneFinger = c.tool == InkTool.hand || _stylusSeen;
          return InteractiveViewer(
            transformationController: _transform,
            constrained: false,
            minScale: 0.2,
            maxScale: 6,
            boundaryMargin: const EdgeInsets.all(400),
            panEnabled: panWithOneFinger,
            child: Listener(
              onPointerDown: _onDown,
              onPointerMove: _onMove,
              onPointerUp: _onUp,
              onPointerCancel: _onUp,
              child: Container(
                width: pageSize.width,
                height: pageSize.height,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(blurRadius: 12, color: Color(0x33000000))],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: PaperPainter(
                        widget.background,
                        lineColor: scheme.primary.withValues(alpha: 0.18),
                      ),
                    ),
                    RepaintBoundary(
                      child: CustomPaint(
                        painter: StrokesPainter(
                          c.restingStrokes,
                          revision: c.revision,
                        ),
                      ),
                    ),
                    CustomPaint(
                      painter: LivePainter(
                        strokes: c.liveStrokes,
                        lasso: c.lassoPath,
                        selectionBounds: c.selectionBounds,
                        accent: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
