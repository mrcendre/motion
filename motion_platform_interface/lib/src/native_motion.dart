// Copyright 2022 Guillaume Cendre. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:motion_platform_interface/motion_platform_interface.dart';

/// The native implementation of the [MotionPlatform] interface that uses a [MethodChannel] and an [EventChannel].
class NativeMotion extends MotionPlatform {
  static const EventChannel _gyroscopeEventChannel =
      EventChannel('me.cendre.motion/gyroscope');

  static const MethodChannel _methodChannel = MethodChannel('me.cendre.motion');

  static Stream<MotionEvent>? _gyroscopeStream;

  @override
  bool get isSafariMobile => false;

  static bool _isGyroscopeAvailable = true;

  @override
  bool get isGyroscopeAvailable => _isGyroscopeAvailable;

  @override
  bool get isPermissionGranted => false;

  @override
  bool get requiresPermission => false;

  FramesPerSecond _updateInterval = defaultUpdateInterval;

  @override
  Stream<MotionEvent> get gyroscopeStream {
    _gyroscopeStream ??=
        _gyroscopeEventChannel.receiveBroadcastStream().map((dynamic event) {
      final list = event.cast<double>();
      return MotionEvent(
          type: MotionType.gyroscope, x: list[0]!, y: list[1]!, z: list[2]!);
    });
    return _gyroscopeStream!;
  }

  @override
  Future<void> initialize() async {
    final isEmpty = await gyroscopeStream.isEmpty;

    // If the stream does not exist or is empty.
    _isGyroscopeAvailable = !isEmpty;

    return;
  }

  @override
  Future<bool> requestPermission() async => true;

  @override
  void setUpdateInterval(FramesPerSecond updateInterval) {
    _updateInterval = updateInterval;
    _methodChannel.invokeMethod(
        'setUpdateInterval', _updateInterval.inMicroseconds);
  }
}
