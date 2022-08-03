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

  /// Platform's features declaration

  bool get isSafariMobile => true;

  bool get isGyroscopeAvailable => false;

  bool get isPermissionGranted => false;

  bool get requiresPermission => false;

  Stream<MotionEvent> get gyroscopeStream => const Stream.empty();

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
