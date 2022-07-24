import 'package:flutter/widgets.dart';

import 'constants.dart';

extension _SingleValueOffset on Offset {
  static Offset fromDimension(double value) => Offset(value, value);
}

class GlareConfiguration {
  /// The opacity of the gradient's visible color stop when tilted upwards.
  final double minOpacity;

  /// The opacity of the gradient's visible color stop when tilted downwards.
  final double maxOpacity;

  /// The glare's tint color.
  final Color color;

  /// A set of values that define the glare effect's behavior.
  const GlareConfiguration(
      {this.minOpacity = 0,
      this.maxOpacity = minGlareOpacity,
      this.color = defaultGlareColor});

  /// A constructor that creates a [GlareConfiguration] from an [elevation].
  factory GlareConfiguration.fromElevation(int elevation) =>
      const GlareConfiguration();
}

class ShadowConfiguration {
  // The shadow's blur radius.
  final double blurRadius;

  /// The shadow's opacity. From 0 to 1.
  final double opacity;

  /// The shadow's color. Opacity is not taken into account as it is controlled by the [opacity] property.
  final Color color;

  /// The maximum extent that the shadow can reach.
  final Offset maxOffset;

  /// An additional offset to apply to the top of the shadow.
  final double topOffset;

  /// A [bool] indicating whether the shadow's configuration values mean that the shadow is visible or not.
  bool get isVisible => blurRadius > 0 && opacity > 0 && color.opacity > 0;

  /// A set of values that define the shadow effect's behavior.
  const ShadowConfiguration(
      {this.blurRadius = minBlurRadius,
      this.opacity = minShadowOpacity,
      this.color = defaultShadowColor,
      this.maxOffset = const Offset(maxShadowOffset, maxShadowOffset),
      this.topOffset = minShadowTopOffset});

  /// A constructor that creates a [ShadowConfiguration] from an [elevation].
  factory ShadowConfiguration.fromElevation(int elevation) =>
      ShadowConfiguration(
        blurRadius: minBlurRadius +
            (elevation / maxElevation) * (maxBlurRadius - minBlurRadius),
      );
}

class TranslationConfiguration {
  /// The maximum X and Y distances by which the widget may move when rotating.
  final Offset maxOffset;

  /// A set of values that define the translation effect's behavior.
  const TranslationConfiguration(
      {this.maxOffset = const Offset(maxDistance, maxDistance)});

  /// A constructor that creates a [TranslationConfiguration] from an [elevation].
  factory TranslationConfiguration.fromElevation(int elevation) =>
      TranslationConfiguration(
          maxOffset: _SingleValueOffset.fromDimension(
              elevation / maxElevation * maxDistance));
}
