import 'dart:math';

import 'package:flutter/widgets.dart';

import 'fps.dart';

/// Constants used to define the [Motion] widget's behavior.

/// The default update interval of 60 frames per second.
final defaultUpdateInterval = 60.fps;

/// Color constants
const defaultGlareColor = Color(0xffffffff),
    defaultShadowColor = Color(0xff000000);

/// Default filter quality
const defaultFilterQuality = FilterQuality.high;

/// Numeric constants
const double maxElevation = 100,

    /// Defaults
    defaultMaxAngle = pi / 10,

    /// Damping constants
    maxDampingFactor = 0.05,
    minDampingFactor = 0.01,

    /// Glare-specific constants
    minGlareOpacity = 0.1,
    maxGlareOpacity = 0.4,

    /// Shadow-specific values
    minShadowOffset = 0,
    maxShadowOffset = 40,
    minShadowTopOffset = 5,
    maxShadowTopOffset = 45,
    minBlurRadius = 10,
    maxBlurRadius = 30,
    minShadowOpacity = 0.3,
    maxShadowOpacity = 0.2,

    /// Translation-specific values
    maxDistance = 75.0;
