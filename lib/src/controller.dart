import 'dart:math';

import 'utils/constants.dart';

class MotionController {
  /// The speed at which the widget is attracted to its initial position. The higher the value, the faster the widget
  /// will be rotate back to its initial position. From 0 to 1.
  double damping;

  double get dampingFactor =>
      1 -
      (minDampingFactor + (damping * (maxDampingFactor - minDampingFactor)));

  /// The maximum angle at which the widget will be allowed to turn in every axis, in radians.
  double maxAngle;

  /// The current tilt state for each axises.
  ///
  /// Updated each time the client widget is rebuilt by the [StreamBuilder], itself triggered by events sent by the
  /// [gyroscopeEvents] stream.
  double x = 0, y = 0;

  MotionController({this.damping = 0.2, this.maxAngle = pi / 8});

  // A default controller for initializing the widgets.
  static final defaultController = MotionController();

  /// Clamps the values to the maximum angle allowed.
  void normalize() {
    x = min(maxAngle / 2, max(-maxAngle / 2, x));
    y = min(maxAngle / 2, max(-maxAngle / 2, y));
  }
}
