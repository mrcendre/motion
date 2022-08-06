import 'package:flutter/widgets.dart' hide Shadow;
import 'package:motion_platform_interface/motion_platform_interface.dart';

import 'model/configurations.dart';
import 'model/controller.dart';
import 'motion_builder.dart';
import 'input_stream.dart';

/// A fancy widget that adds a gyroscope-based motion effect to its [child].
///
/// Platform-specific operations are performed using the static [instance].
class Motion extends StatefulWidget {
  /// The MotionPlatform instance to perform platform-specific operations.
  ///
  /// You may use it to initialize the platform, to detect feature availability and permission requirements,
  /// to request permissions, and to set the update interval.
  static final instance = MotionPlatform.instance;

  /// The controller that holds the widget's motion data.
  final MotionController? controller;

  /// The target widget.
  final Widget child;

  /// Whether to apply a dynamic glare effect to the widget.
  final GlareConfiguration? glare;

  /// Whether to apply a dynamic shadow to the widget.
  final ShadowConfiguration? shadow;

  /// Whether to apply a dynamic translation effect on the widget's X and Y positions.
  final TranslationConfiguration? translation;

  /// An optional border radius to apply to the widget.
  final BorderRadius? borderRadius;

  /// Creates a [Motion] widget with the given [child] and [controller], applying all of the default effects.
  ///
  /// The [controller] can be used to create a unique controller for each widget.
  ///
  /// When omitted, the default controller is used. It is a shared instance that will apply the same rotation
  /// to all widgets. If multiple [Motion] widgets are displayed at the same time, they should have unique controllers.
  ///
  /// You may provide a custom [glare], [shadow] and [translation] configuration to override the default effects.
  /// An optional [borderRadius] can be provided to apply a border radius to the widget.
  const Motion({
    Key? key,
    this.controller,
    required this.child,
    this.glare = const GlareConfiguration(),
    this.shadow = const ShadowConfiguration(),
    this.translation = const TranslationConfiguration(),
    this.borderRadius,
  }) : super(key: key);

  /// Creates a [Motion] widget with the given [child] and [controller], but only applying the rotation effect by default.
  ///
  /// A shorthand for initializing a [Motion] widget with no other effect than the rotation.
  const Motion.only({
    Key? key,
    this.controller,
    required this.child,
    this.glare,
    this.shadow,
    this.translation,
    this.borderRadius,
  }) : super(key: key);

  /// Creates a [Motion] widget by setting configurations according to the elevation of the widget.
  ///
  /// This will influence the shadow's movement and offset, if greater than 0.
  ///
  /// Higher [elevation] values allows to :
  ///
  ///   - Blur and lower the shadow from behind your widget, as if it was floating higher
  ///   - Increase the distance by which the widget will be translated on the X and Y axises
  ///
  /// [elevation] may range from 0 to 100, allowing you to easily stay consistent accross your design.
  factory Motion.elevated({
    Key? key,
    required int elevation,
    required Widget child,
    MotionController? controller,
    BorderRadius? borderRadius,
    bool glare = true,
    bool shadow = true,
    bool translation = true,
  }) =>
      Motion(
        key: key,
        child: child,
        controller: controller,
        glare: glare ? GlareConfiguration.fromElevation(elevation) : null,
        shadow: shadow ? ShadowConfiguration.fromElevation(elevation) : null,
        translation: translation
            ? TranslationConfiguration.fromElevation(elevation)
            : null,
        borderRadius: borderRadius,
      );

  @override
  State<Motion> createState() => _MotionState();
}

class _MotionState extends State<Motion> {
  @override
  Widget build(BuildContext context) => InputStream(
          child: MotionStreamBuilder(
        controller: widget.controller,
        child: widget.child,
        glare: widget.glare,
        shadow: widget.shadow,
        translation: widget.translation,
        borderRadius: widget.borderRadius,
      ));
}
