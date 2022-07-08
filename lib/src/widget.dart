import 'dart:math';

import 'package:flutter/widgets.dart' hide Shadow;
import 'package:sensors_plus/sensors_plus.dart';

import 'controller.dart';

const double _maxElevation = 100,
    _minGlareOpacity = 0.1,
    _maxGlareOpacity = 0.4,
    _minShadowOffset = 0,
    _maxShadowOffset = 40,
    _minShadowTopOffset = 5,
    _maxShadowTopOffset = 45,
    _minBlurRadius = 10,
    _maxBlurRadius = 40,
    _minBlurOpacity = 0.3,
    _maxBlurOpacity = 0.2;

class Motion extends StatefulWidget {
  /// The controller that holds the widget's motion data.
  final MotionController controller;

  /// The target widget.
  final Widget child;

  /// The elevation of the widget. This will influence the shadow's movement and offset, if greater than 0.
  /// From 0 to 100.
  final int elevation;

  /// Whether to apply a dynamic glare effect to the widget.
  final bool glare;

  /// Whether to apply a dynamic shadow to the widget.
  final bool shadow;

  /// An optional border radius to apply to the widget.
  final BorderRadius? borderRadius;

  const Motion({
    Key? key,
    required this.controller,
    required this.child,
    this.elevation = 10,
    this.glare = true,
    this.shadow = true,
    this.borderRadius,
  })  : assert(elevation > 0 && elevation <= 100),
        super(key: key);

  @override
  State<Motion> createState() => _MotionState();
}

class _MotionState extends State<Motion> with SingleTickerProviderStateMixin {
  /// The intensity of the glare effect. Used as the gradient's opacity.
  double get glareOpacity => max(
      0,
      min(
        _maxGlareOpacity,
        _minGlareOpacity +
            (controller.x / controller.maxAngle) *
                (_maxGlareOpacity - _minGlareOpacity),
      ));

  /// The rotation of the glare effect's gradient.
  double get glareRotation =>
      controller.y / (controller.maxAngle * 2) * (2 * pi);

  /// The base top shadow offset.
  double get topShadowOffset =>
      _minShadowTopOffset +
      (widget.elevation / _maxElevation) *
          (_maxShadowTopOffset - _minShadowTopOffset);

  /// The shadow's offset on the horizontal axis.
  double get horizontalShadowOffset =>
      _minShadowOffset +
      (controller.y / controller.maxAngle) *
          (_maxShadowOffset - _minShadowOffset);

  /// The shadow's offset on the vertical axis.
  double get verticalShadowOffset =>
      _minShadowOffset +
      (controller.x / controller.maxAngle) *
          (_maxShadowOffset - _minShadowOffset);

  /// The shadow's maximum offset on all axises.
  double get maxShadowOffset =>
      _minShadowOffset +
      ((elevation / _maxElevation) * (_maxShadowOffset - _minShadowOffset));

  /// The shadow's blur radius.
  double get shadowBlurRadius =>
      _minBlurRadius +
      ((elevation / _maxElevation) * (_maxBlurRadius - _minBlurRadius));

  /// The shadow's blur opacity.
  double get shadowBlurOpacity =>
      _minBlurOpacity +
      ((elevation / _maxElevation) * (_maxBlurOpacity - _minBlurOpacity));

  /// The clamped elevation value.
  int get elevation => min(_maxElevation.toInt(), widget.elevation);

  /// The widget's controller.
  MotionController get controller => widget.controller;

  Orientation? orientation;

  /// Computes the new rotation for each axis from the given [event], and updates the .
  Matrix4 computeTransformForEvent(GyroscopeEvent? event) {
    final matrix = Matrix4.identity()..setEntry(3, 2, 0.0015);

    if (event != null) {
      // Apply the event's rotation based on the device orientation.
      controller.x +=
          (orientation == Orientation.landscape ? -event.y : event.x) * 0.01;
      controller.y -=
          (orientation == Orientation.landscape ? event.x : event.y) * 0.01;

      // Normalize the values.
      controller.normalize();

      // Apply the damping factor.
      controller.x *= controller.dampingFactor;
      controller.y *= controller.dampingFactor;

      // Rotate the matrix by the resulting x and y values.
      matrix.rotateX(controller.x);
      matrix.rotateY(controller.y);
    }

    return matrix;
  }

  @override
  void didChangeDependencies() {
    orientation = MediaQuery.of(context).orientation;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<GyroscopeEvent>(
      stream: gyroscopeEvents,
      builder: (ctx, snapshot) => Stack(clipBehavior: Clip.none, children: [
            if (widget.elevation != 0 && widget.shadow)
              Positioned(
                  left: horizontalShadowOffset,
                  right: -horizontalShadowOffset,
                  top: -verticalShadowOffset + topShadowOffset,
                  bottom: verticalShadowOffset - topShadowOffset,
                  child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                          borderRadius: widget.borderRadius,
                          boxShadow: [
                            BoxShadow(
                                blurRadius: shadowBlurRadius,
                                color: Color.fromARGB(
                                    (shadowBlurOpacity * 255).toInt(), 0, 0, 0))
                          ]))),
            Transform(
                transform: computeTransformForEvent(snapshot.data),
                alignment: FractionalOffset.center,
                child: widget.glare
                    ? Stack(clipBehavior: Clip.none, children: [
                        widget.child,
                        Positioned.fill(
                            child: Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                    borderRadius: widget.borderRadius,
                                    gradient: LinearGradient(
                                        colors: [
                                          const Color.fromARGB(
                                              0, 255, 255, 255),
                                          Color.fromARGB(
                                              (glareOpacity * 255).toInt(),
                                              255,
                                              255,
                                              255)
                                        ],
                                        transform:
                                            GradientRotation(glareRotation)))))
                      ])
                    : widget.child),
          ]));
}
