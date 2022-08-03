import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart' hide MouseRegion;
import 'motion.dart';
import 'mouse_region.dart';

class PointerListener extends StatefulWidget {
  final Widget child;

  /// A callback that will be called when a pointer event is received.
  ///
  /// [newOffset] is a fractional [Offset], meaning that its [dx] and [dy] values range from -1 to 1.
  final Function(Offset newOffset) onPositionChange;

  /// A widget that provides updates on the pointer events occuring on a [child]'s surface.
  ///
  /// It also tracks when the pointer is entering and exiting the [child], to smoothly reset the position
  /// by exponentially animating an intensity factor from 0 when the pointer is outside to 1 when inside.
  ///
  /// Consequently, when the pointer leaves the [child], "fake" pointer events are simulated towards
  /// the widget's center. When it enters, the widget progressively animates to the pointer's position.
  const PointerListener(
      {Key? key, required this.child, required this.onPositionChange})
      : super(key: key);

  @override
  State<PointerListener> createState() => _PointerListenerState();
}

class _PointerListenerState extends State<PointerListener> {
  final mouseRegionKey = GlobalKey();

  /// A track of the latest size returned by the widget's layout builder.
  Size? childSize;

  /// Values used for deltas and throttling
  Offset lastOffset = Offset.zero;
  DateTime lastPointerEvent = DateTime.now();

  /// When idle, the intensity factor is 0. When the pointer enters, it progressively animates to 1.
  double intensityFactor = 0;

  double get width => childSize?.width ?? 1;
  double get height => childSize?.height ?? 1;

  /// A timer that progressively increases or decreases the intensity factor.
  Timer? velocityTimer;

  @override
  void dispose() {
    velocityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(children: [
        widget.child,
        Positioned.fill(child: LayoutBuilder(builder: (ctx, constraints) {
          childSize = Size(constraints.maxWidth, constraints.maxHeight);
          return Listener(
              onPointerHover: (details) {
                _onPointerMove(position: details.localPosition);
              },
              onPointerMove: (details) {
                _onPointerMove(position: details.localPosition);
              },
              behavior: HitTestBehavior.translucent,
              child: TranslucentMouseRegion(
                  key: mouseRegionKey,
                  onExit: (details) {
                    _onPointerExit();
                  },
                  onEnter: (details) {
                    _onPointerEnter();
                  },
                  child: Container()));
        }))
      ]);

  void _onPointerMove({required Offset position}) {
    if (DateTime.now().difference(lastPointerEvent) <
        Motion.updateInterval.duration) {
      /// Drop event since it occurs too early.
      return;
    }

    double x, y;

    // Compute the fractional offset.
    x = (position.dy - (height / 2)) / height;
    y = -(position.dx - (width / 2)) / width;

    // Apply the intensity factor.
    x *= intensityFactor;
    y *= intensityFactor;

    // Notify the position change.
    widget.onPositionChange(Offset(x, y));

    // Store the pass informations.
    lastPointerEvent = DateTime.now();
    lastOffset = Offset(position.dx, position.dy);
  }

  /// Animate the intensity factor to 1, to smoothly get to the pointer's position.
  void _onPointerEnter() async {
    _cancelVelocityTimer();

    velocityTimer = Timer.periodic(
        Duration(microseconds: 1 + Motion.updateInterval.inMicroseconds),
        (timer) {
      if (intensityFactor < 1) {
        if (intensityFactor <= 0.05) {
          intensityFactor = 0.05;
        }
        intensityFactor = min(1, intensityFactor * 1.2);
        _onPointerMove(position: lastOffset);
      } else {
        _cancelVelocityTimer();
      }
    });
  }

  /// Animate the intensity factor to 0, to smoothly get back to the initial position.
  void _onPointerExit() async {
    _cancelVelocityTimer();

    velocityTimer = Timer.periodic(
        Duration(microseconds: 1 + Motion.updateInterval.inMicroseconds),
        (timer) {
      if (intensityFactor > 0.05) {
        intensityFactor = max(0, intensityFactor * 0.95);
        _onPointerMove(position: lastOffset /*, isVelocity: true*/);
      } else {
        _cancelVelocityTimer();
      }
    });
  }

  /// Cancels the velocity timer.
  void _cancelVelocityTimer() {
    velocityTimer?.cancel();
    velocityTimer = null;
  }
}
