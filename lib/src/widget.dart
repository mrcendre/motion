import 'dart:math';

import 'package:flutter/widgets.dart' hide Shadow;
import 'configuration.dart';
import 'input_stream.dart';
import 'motion_event.dart';
import 'utils/constants.dart';

import 'controller.dart';

class Motion extends StatefulWidget {
  /// The controller that holds the widget's motion data.
  final MotionController? controller;

  /// The target widget.
  final Widget child;

  /// The elevation of the widget. This will influence the shadow's movement and offset, if greater than 0.
  /// From 0 to 100.
  final int elevation;

  /// Whether to apply a dynamic glare effect to the widget.
  final bool glare;

  /// Whether to apply a dynamic shadow to the widget.
  final bool shadow;

  /// Whether to apply a dynamic translation effect on the widget's X and Y positions.
  final bool translation;

  /// An optional border radius to apply to the widget.
  final BorderRadius? borderRadius;

  /// Creates a [Motion] widget with the given [child] and [controller], applying all of the effects.
  const Motion({
    Key? key,
    this.controller,
    required this.child,
    this.elevation = 10,
    this.glare = true,
    this.shadow = true,
    this.translation = true,
    this.borderRadius,
  })  : assert(elevation > 0 && elevation <= 100),
        super(key: key);

  /// Creates a [Motion] widget with the given [child] and [controller], but only applying the motion effect.
  const Motion.only({
    Key? key,
    this.controller,
    required this.child,
    this.elevation = 10,
    this.glare = false,
    this.shadow = false,
    this.translation = false,
    this.borderRadius,
  })  : assert(elevation > 0 && elevation <= 100),
        super(key: key);

  @override
  State<Motion> createState() => _MotionState();
}

class _MotionState extends State<Motion> with SingleTickerProviderStateMixin {
  /// The controller to use.
  MotionController get controller =>
      widget.controller ?? MotionController.defaultController;

  /// The intensity of the glare effect. Used as the gradient's opacity.
  double get glareOpacity => max(
      0,
      min(
        maxGlareOpacity,
        minGlareOpacity +
            (controller.x / controller.maxAngle) *
                (maxGlareOpacity - minGlareOpacity),
      ));

  /// The rotation of the glare effect's gradient.
  double get glareRotation =>
      pi / 2 + (controller.y / (controller.maxAngle * 2) * (2 * pi));

  /// The base top shadow offset.
  double get topShadowOffset =>
      minShadowTopOffset +
      (widget.elevation / maxElevation) *
          (maxShadowTopOffset - minShadowTopOffset);

  /// The shadow's offset on the horizontal axis.
  double get horizontalShadowOffset =>
      minShadowOffset +
      (controller.y / controller.maxAngle) *
          (maxShadowOffset - minShadowOffset);

  /// The shadow's offset on the vertical axis.
  double get verticalShadowOffset =>
      minShadowOffset +
      (controller.x / controller.maxAngle) *
          (maxShadowOffset - minShadowOffset);

  /// The shadow's blur radius.
  double get shadowBlurRadius =>
      minBlurRadius +
      ((elevation / maxElevation) * (maxBlurRadius - minBlurRadius));

  /// The shadow's blur opacity.
  double get shadowBlurOpacity =>
      minBlurOpacity +
      ((elevation / maxElevation) * (maxBlurOpacity - minBlurOpacity));

  /// The distance value.
  double get distance => (elevation / maxElevation) * maxDistance;

  /// The clamped elevation value.
  int get elevation => min(maxElevation.toInt(), widget.elevation);

  /// The device's orientation.
  Orientation? orientation;

  /// Computes the new rotation for each axis from the given [event], and updates the .
  Matrix4 computeTransformForEvent(MotionEvent? event) {
    final matrix = Matrix4.identity()..setEntry(3, 2, 0.0015);

    if (event != null) {
      // In case of relative events...
      if (event.type == MotionType.gyroscope) {
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
      } else {
        controller.x = event.x * (controller.maxAngle / 2);
        controller.y = event.y * (controller.maxAngle / 2);
      }

      // Rotate the matrix by the resulting x and y values.
      matrix.rotateX(controller.x);
      matrix.rotateY(controller.y);

      if (widget.translation) {
        matrix.translate(
            controller.y * -(distance * 2.0), controller.x * distance);
      }
    }

    return matrix;
  }

  @override
  void didChangeDependencies() {
    orientation = MediaQuery.of(context).orientation;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => InputStream(
      child: Builder(
          builder: (ctx) => StreamBuilder<MotionEvent>(
              stream: MotionConfiguration.of(ctx)?.stream,
              builder: (ctx, snapshot) =>
                  Stack(clipBehavior: Clip.none, children: [
                    if (widget.elevation != 0 && widget.shadow)
                      Positioned(
                          left: horizontalShadowOffset,
                          right: -horizontalShadowOffset,
                          top: -verticalShadowOffset + topShadowOffset,
                          bottom: verticalShadowOffset - topShadowOffset,
                          child: IgnorePointer(
                              child: Container(
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                      borderRadius: widget.borderRadius,
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: shadowBlurRadius,
                                            color: Color.fromARGB(
                                                (shadowBlurOpacity * 255)
                                                    .toInt(),
                                                0,
                                                0,
                                                0))
                                      ])))),
                    Transform(
                        transform: computeTransformForEvent(snapshot.data),
                        alignment: FractionalOffset.center,
                        child: widget.glare
                            ? Stack(clipBehavior: Clip.none, children: [
                                widget.child,
                                Positioned.fill(
                                    child: IgnorePointer(
                                        child: Container(
                                            clipBehavior: Clip.hardEdge,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    widget.borderRadius,
                                                gradient: LinearGradient(
                                                    colors: [
                                                      const Color.fromARGB(
                                                          0, 255, 255, 255),
                                                      Color.fromARGB(
                                                          (glareOpacity * 255)
                                                              .toInt(),
                                                          255,
                                                          255,
                                                          255)
                                                    ],
                                                    transform: GradientRotation(
                                                        glareRotation))))))
                              ])
                            : widget.child),
                  ]))));
}
