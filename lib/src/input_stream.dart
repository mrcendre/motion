import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';

import 'package:sensors_plus/sensors_plus.dart';

import 'configuration.dart';
import 'utils/measure.dart';
import 'motion_event.dart';

final StreamController<MotionEvent> _pointerStreamController =
    StreamController<MotionEvent>.broadcast(/*sync: true*/);

class InputStream extends StatefulWidget {
  final Widget child;

  const InputStream({Key? key, required this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => InputStreamState();
}

class InputStreamState extends State<InputStream> {
  DateTime lastPointerEvent = DateTime.now();

  bool get hasGyroscope => Platform.isIOS || Platform.isAndroid;

  bool isResetting = false;

  Size? childSize;

  Offset lastOffset = Offset.zero;

  double get width => childSize?.width ?? 0;
  double get height => childSize?.height ?? 0;

  Offset get centerOffset =>
      Offset(lastOffset.dx - (width / 2), lastOffset.dy - (height / 2));
  Offset get fractionalCenterOffset =>
      Offset(centerOffset.dx / (width / 2), centerOffset.dy / (height / 2));

  Stream<MotionEvent> get inputStream {
    return hasGyroscope
        ? getGyroscopeEventsStream()
        : _pointerStreamController.stream;
  }

  Stream<MotionEvent> getGyroscopeEventsStream() => gyroscopeEvents.transform(
        StreamTransformer<GyroscopeEvent, MotionEvent>.fromHandlers(
          handleData: (GyroscopeEvent event, EventSink<MotionEvent> sink) {
            sink.add(MotionEvent(
                type: MotionType.gyroscope,
                x: event.x,
                y: event.y,
                z: event.z));
          },
        ),
      );

  @override
  Widget build(BuildContext context) => MotionConfiguration(
        stream: inputStream,
        child: hasGyroscope
            ? widget.child
            : _buildPointerListener(child: widget.child),
      );

  Widget _buildPointerListener({required Widget child}) => Listener(
      onPointerHover: (details) {
        cancelReset();
        onPointerMove(position: details.localPosition);
      },
      onPointerMove: (details) {
        cancelReset();
        onPointerMove(position: details.localPosition);
      },
      child: MouseRegion(
          onExit: (details) {
            onPointerExit();
          },
          onEnter: (details) {
            onPointerEnter();
          },
          child: Measure(
              onChange: (Size size) {
                childSize = size;
              },
              child: child)));

  void onPointerMove({required Offset position}) {
    if (DateTime.now().difference(lastPointerEvent) <
        const Duration(milliseconds: 16 /*aka 60 FPS*/)) {
      /// Drop event.
      return;
    }

    double x, y;

    if (childSize != null) {
      x = (position.dy - (childSize!.height / 2)) / childSize!.height;
      y = -(position.dx - (childSize!.width / 2)) / childSize!.width;

      x *= intensityFactor;
      y *= intensityFactor;
    } else {
      x = y = 0;
    }

    _pointerStreamController
        .add(MotionEvent(type: MotionType.pointer, x: x, y: y));

    lastPointerEvent = DateTime.now();
    lastOffset = Offset(position.dx, position.dy);
  }

  double intensityFactor = 1;

  /// Animate the intensity factor to 1, to smoothly get to the pointer's position.
  void onPointerEnter() async {
    if (isResetting) cancelReset();

    intensityFactor = 0.05;

    while (!isResetting && intensityFactor < 1) {
      intensityFactor *= 1.2;

      if (intensityFactor > 1) intensityFactor = 1;

      await Future.delayed(const Duration(milliseconds: 16));
    }
  }

  /// Animate the intensity factor to 0, to smoothly get back to the initial position.
  void onPointerExit() async {
    isResetting = true;

    /// Progressively reset the position.
    while (isResetting &&
        (fractionalCenterOffset.dx < -0.001 ||
            fractionalCenterOffset.dx > 0.001 ||
            fractionalCenterOffset.dy < -0.001 ||
            fractionalCenterOffset.dy > 0.001)) {
      final newOffset = Offset(
          (width / 2) + ((lastOffset.dx - (width / 2))) * 0.95,
          (height / 2) + ((lastOffset.dy - (height / 2))) * 0.95);

      onPointerMove(position: newOffset);

      await Future.delayed(const Duration(milliseconds: 30));
    }

    if (isResetting) {
      onPointerMove(
          position: Offset(
              (childSize?.width ?? 0) / 2, (childSize?.height ?? 0) / 2));
    }

    isResetting = false;
  }

  /// Cancels the animation to reset the widget position.
  void cancelReset() {
    isResetting = false;
  }
}
