import 'dart:math';

import 'package:motion_platform_interface/motion_platform_interface.dart';

class MotionController {
  /// The speed at which the widget returns to its initial position (only for Gyroscope input type).
  ///
  /// The higher the value, the faster the widget will rotate back to its initial position.
  /// From 0 to 1.
  double damping;

  /// The actual damping factor used by the widget.
  ///
  /// Computed from the [damping] value which lerps from 0 to 1 between [minDampingFactor] and [maxDampingFactor].
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

  /// A controller that holds the [Motion] widget's X and Y angles.
  MotionController({this.damping = 0.2, this.maxAngle = defaultMaxAngle});

  /// A default controller for initializing the widgets with the default [damping] and [maxAngle] values.
  ///
  /// Note : when the [defaultController] is used by multiple simultaneously visible widgets, the X and Y values
  /// will be shared by all of these widgets. If the pointer input is used, this can make other widgets move when
  /// hovering a single widget, which is a design fault.
  ///
  /// You may use individual instances of [MotionController] to avoid this behavior.
  static final defaultController = MotionController();

  /// Clamps the values to the maximum angle allowed.
  void normalize() {
    x = min(maxAngle / 2, max(-maxAngle / 2, x));
    y = min(maxAngle / 2, max(-maxAngle / 2, y));
  }
}
