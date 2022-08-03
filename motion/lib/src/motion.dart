import 'package:flutter/widgets.dart' hide Shadow;
import 'package:motion_platform_interface/motion_platform_interface.dart';

import 'model/configurations.dart';
import 'model/controller.dart';
import 'motion_builder.dart';
import 'input_stream.dart';

class Motion extends StatefulWidget {
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

  static bool _isInitialized = false;

  /// A hybrid method that uses the MotionPlatform instance to get information about the device's platform.
  ///
  /// On Safari iOS, issues have been noted when rendering [LinearGradient]s, covering the widget
  /// with a black color. The glare effect is thus disabled internally when Safari iOS is detected.
  static bool get isGradientOverlayAvailable =>
      !MotionPlatform.instance.isSafariMobile;

  /// A boolean indicating whether the gyroscope is available on the current platform.
  static bool get isGyroscopeAvailable =>
      MotionPlatform.instance.isGyroscopeAvailable;

  /// A boolean indicating whether the gyroscope is available on the current platform.
  static Stream<MotionEvent> get gyroscopeStream =>
      MotionPlatform.instance.gyroscopeStream;

  /// Whether the motion sensor requires a permission to be accessed.
  static bool get requiresPermission =>
      MotionPlatform.instance.requiresPermission;

  /// Whether the user has granted the app permission to use the motion sensor.
  static bool get isPermissionGranted =>
      MotionPlatform.instance.isGyroscopeAvailable == false ||
      MotionPlatform.instance.isPermissionGranted;

  static FramesPerSecond _updateInterval = defaultUpdateInterval;

  static FramesPerSecond get updateInterval => _updateInterval;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    _isInitialized = true;
    await MotionPlatform.instance.initialize();
  }

  /// Attempts to present the DeviceMotionEvent permission dialog if the platform requires it.
  ///
  /// Note: this must always be called after an user input or gesture, otherwise it will fail.
  /// For example, you can show a dialog that informs the user that this permission is needed,
  /// and then call this method.
  static Future<bool> requestPermission() async {
    return MotionPlatform.instance.requestPermission();
  }

  /// A method to set the interval at which the motion widget will update.
  ///
  /// Higher values will result in more accurate motion data and thus smoother motion of the widgets,
  /// but will also have an increased impact on performances.
  ///
  /// The ideal sampling rate matches Flutter's recommended 60 FPS (frames per seconds).
  /// However, a performance compromise may be required on certain older devices.
  /// In that case, you could use the standard 30 FPS or 24 FPS, the latter being the lowest
  /// frame rate required to make motion appear natural to the human eye.
  ///
  /// The best practice for setting the sensor rate is to do it once, when initializing your app.
  static void setUpdateInterval(FramesPerSecond updateInterval) {
    _updateInterval = updateInterval;
    MotionPlatform.instance.setUpdateInterval(updateInterval);
  }

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
