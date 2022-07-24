import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:motion/src/model/constants.dart';

class PointerListener extends StatefulWidget {
  final Widget child;

  final Function(Offset newOffset) onPositionChange;

  const PointerListener(
      {Key? key, required this.child, required this.onPositionChange})
      : super(key: key);

  @override
  State<PointerListener> createState() => _PointerListenerState();
}

class _PointerListenerState extends State<PointerListener> {
  // A track of the latest size returned by the widget's layout builder.
  Size? childSize;

  // Values used for deltas and throttling
  Offset lastOffset = Offset.zero;
  DateTime lastPointerEvent = DateTime.now();

  // When idle, the intensity factor is 0. When the pointer enters, it progressively animates to 1.
  double intensityFactor = 0;

  double get width => childSize?.width ?? 1;
  double get height => childSize?.height ?? 1;

  // A timer that progressively increases or decreases the intensity factor.
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
                onPointerMove(position: details.localPosition);
              },
              onPointerMove: (details) {
                onPointerMove(position: details.localPosition);
              },
              behavior: HitTestBehavior.translucent,
              child: MouseRegion(
                  onExit: (details) {
                    onPointerExit();
                  },
                  onEnter: (details) {
                    onPointerEnter();
                  },
                  hitTestBehavior: HitTestBehavior.translucent,
                  child: Container()));
        }))
      ]);

  void onPointerMove({required Offset position /*, bool isVelocity = false*/}) {
    if (DateTime.now().difference(lastPointerEvent) < minFrameDuration) {
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
  void onPointerEnter() async {
    cancelVelocityTimer();

    velocityTimer = Timer.periodic(
        Duration(milliseconds: 1 + minFrameDuration.inMilliseconds), (timer) {
      if (intensityFactor < 1) {
        if (intensityFactor <= 0.05) {
          intensityFactor = 0.05;
        }
        intensityFactor = min(1, intensityFactor * 1.2);
        onPointerMove(position: lastOffset /*, isVelocity: true*/);
      } else {
        cancelVelocityTimer();
      }
    });
  }

  /// Animate the intensity factor to 0, to smoothly get back to the initial position.
  void onPointerExit() async {
    cancelVelocityTimer();

    velocityTimer = Timer.periodic(
        Duration(milliseconds: 1 + minFrameDuration.inMilliseconds), (timer) {
      if (intensityFactor > 0.05) {
        intensityFactor = max(0, intensityFactor * 0.95);
        onPointerMove(position: lastOffset /*, isVelocity: true*/);
      } else {
        cancelVelocityTimer();
      }
    });
  }

  /// Cancels the velocity timer.
  void cancelVelocityTimer() {
    velocityTimer?.cancel();
    velocityTimer = null;
  }
}
