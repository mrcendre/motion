// Copyright 2022 Guillaume Cendre. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library motion_platform_interface;

import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'src/model/fps.dart';
import 'src/model/motion_event.dart';
import 'src/native_motion.dart';

export 'src/model/motion_event.dart';

export 'src/model/constants.dart';
export 'src/model/fps.dart';
export 'src/model/motion_event.dart';

/// The common platform interface for the [Motion] plugin.
abstract class MotionPlatform extends PlatformInterface {
  /// Constructs a [MotionPlatform].
  MotionPlatform() : super(token: _token);

  static final Object _token = Object();

  static MotionPlatform _instance = NativeMotion();

  /// The default instance of [MotionPlatform] to use.
  ///
  /// Defaults to [NativeMotion].
  static MotionPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [MotionPlatform] when they register themselves.
  static set instance(MotionPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Platform features declaration

  /// Detects if the platform is Safari Mobile (iOS or iPad).
  bool get isSafariMobile => false;

  /// Indicates whether the gradient is available.
  bool get isGradientOverlayAvailable => !isSafariMobile;

  /// Indicates whether the gyroscope is available.
  bool get isGyroscopeAvailable => false;

  /// Indicates whether a permission is required to access gyroscope data.
  bool get requiresPermission => false;

  /// Indicates whether the permission is granted.
  bool get isPermissionGranted => false;

  /// The interval at which the gyroscope stream is updated.
  FramesPerSecond get updateInterval => 60.fps;

  /// The gyroscope stream, if available.
  Stream<MotionEvent>? get gyroscopeStream => null;

  Future<void> initialize() async {
    throw UnimplementedError();
  }

  Future<bool> requestPermission() async {
    throw UnimplementedError();
  }

  void setUpdateInterval(FramesPerSecond updateInterval) {
    throw UnimplementedError();
  }
}
