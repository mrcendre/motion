import 'dart:async';
import 'dart:developer' as developer;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:web/web.dart' as web;
import 'web_sensors_interop.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:motion_platform_interface/motion_platform_interface.dart';

import 'scripts.dart';

@JS()
external bool get evaluatePermission;

/// The Web implementation of [MotionPlatform].
class WebMotion extends MotionPlatform {
  /// Factory method that initializes the Motion plugin platform with an instance
  /// of the plugin for the web.
  static void registerWith(Registrar registrar) {
    MotionPlatform.instance = WebMotion();
  }

  static bool _isSafariMobile = false;

  @override
  bool get isSafariMobile => _isSafariMobile;

  static bool _isGyroscopeApiAvailable = false;
  static bool _isDeviceMotionApiAvailable = false;

  static bool _isGyroscopeAvailable = false;

  @override
  bool get isGyroscopeAvailable => _isGyroscopeAvailable;

  static bool _isPermissionRequired = false;

  @override
  bool get isPermissionRequired => _isPermissionRequired;

  static bool _isPermissionGranted = false;

  @override
  bool get isPermissionGranted => _isPermissionGranted;

  /// The rate of updates for the sensors, in microseconds (μs).
  ///
  /// Also used to throttle events when too frequent events are emitted from sensors whose
  /// update interval cannot be set.
  FramesPerSecond _updateInterval = defaultUpdateInterval;

  /// A convenience getter for the 'frequency' option of sensors constructors, expressed in 'updates per second'.
  int get _frequency => _updateInterval.inMicroseconds ~/ const Duration(seconds: 1).inMicroseconds;

  void _featureDetected(
    Function initSensor, {
    String? apiName,
    String? permissionName,
    Function? onError,
  }) {
    try {
      initSensor();
    } catch (error) {
      if (onError != null) {
        onError();
      }

      /// Handle construction errors.
      ///
      /// If a feature policy blocks use of a feature it is because your code
      /// is inconsistent with the policies set on your server.
      /// This is not something that would ever be shown to a user.
      /// See Feature-Policy for implementation instructions in the browsers.
      if (error.toString().contains('SecurityError')) {
        /// See the note above about feature policy.
        developer.log('$apiName construction was blocked by a feature policy.', error: error);

        /// if this feature is not supported or Flag is not enabled yet!
      } else if (error.toString().contains('ReferenceError')) {
        developer.log('$apiName is not supported by the User Agent.', error: error);

        /// if this is unknown error, rethrow it
      } else {
        developer.log('Unknown error happened, rethrowing.');
        rethrow;
      }
    }
  }

  DateTime lastDeviceMotionEvent = DateTime.now();

  StreamController<MotionEvent>? _gyroscopeStreamController;
  Stream<MotionEvent>? _gyroscopeStream;

  void onDeviceMotion(JSObject e) {
    final event = e.dartify() as dynamic;
    final now = DateTime.now();
    if (now.difference(lastDeviceMotionEvent) < _updateInterval.duration) {
      /// Drop events more frequent than [_updateInterval]
      return;
    }

    lastDeviceMotionEvent = now;

    var interval = event.interval ?? 1;
    _gyroscopeStreamController!.add(
      MotionEvent(
        type: MotionType.gyroscope,
        x: (event.rotationRate?.alpha as double? ?? 0) * interval,
        y: (event.rotationRate?.beta as double? ?? 0) * interval,
        z: (event.rotationRate?.gamma as double? ?? 0) * interval,
      ),
    );
  }

  @override
  Stream<MotionEvent>? get gyroscopeStream {
    if (_gyroscopeStreamController == null) {
      _gyroscopeStreamController = StreamController();

      if (_isGyroscopeApiAvailable) {
        _featureDetected(
          () {
            final gyroscope = Gyroscope(SensorOptions(frequency: _frequency));

            gyroscope.onreading = (Event event) {
              _gyroscopeStreamController!.add(
                MotionEvent(
                  type: MotionType.gyroscope,
                  x: gyroscope.x as double,
                  y: gyroscope.y as double,
                  z: gyroscope.z as double,
                ),
              );
            }.toJS;

            gyroscope.start();

            gyroscope.onerror = (Event e) {
              developer.log('The gyroscope API is supported but something is wrong!', error: e);
            }.toJS;
          },
          apiName: 'Gyroscope()',
          permissionName: 'gyroscope',
          onError: () {
            web.console.warn('Error: Gyroscope() is not supported by the User Agent.'.toJS);
            _gyroscopeStreamController!.add(const MotionEvent.zero(type: MotionType.gyroscope));
          },
        );
      } else if (_isDeviceMotionApiAvailable) {
        /// If unavailable, fallback on the [DeviceMotionEvent] API.
        _featureDetected(
            () {
              web.window.addEventListener('ondevicemotion', onDeviceMotion.toJS);
            },
            apiName: 'DeviceMotionEvent()',
            permissionName: 'DeviceMotionEvent',
            onError: () {
              web.console.warn('The DeviceMotionEvent API is not available either.'.toJS);
              web.window.removeEventListener('ondevicemotion', onDeviceMotion.toJS);
              _gyroscopeStreamController!.add(const MotionEvent.zero(type: MotionType.gyroscope));
            });
      }
      _gyroscopeStream = _gyroscopeStreamController!.stream.asBroadcastStream();
    }

    return _gyroscopeStream;
  }

  @override
  Future<void> initialize() async {
    Scripts.load();

    _isSafariMobile = web.window.callMethod('isSafariMobile'.toJS) as bool? ?? false;

    _isGyroscopeApiAvailable = web.window.callMethod('isGyroscopeApiAvailable'.toJS) as bool? ?? false;
    _isDeviceMotionApiAvailable = web.window.callMethod('isDeviceMotionApiAvailable'.toJS) as bool? ?? false;

    if (_isDeviceMotionApiAvailable) {
      // If a permission is required to access the DeviceMotionEvents, we are sure there is a gyroscope on the device.
      _isPermissionRequired = web.window.callMethod('requiresDeviceMotionEventPermission'.toJS) as bool? ?? false;

      if (_isPermissionRequired) {
        final isGranted = evaluatePermission;
        _isPermissionGranted = await isGranted;
      }
    }

    _isGyroscopeAvailable = _isGyroscopeApiAvailable || _isDeviceMotionApiAvailable || _isPermissionRequired;

    return;
  }

  @override
  Future<bool> requestPermission() async {
    _isPermissionGranted = web.window.callMethod('requestDeviceMotionEventPermission'.toJS) as bool? ?? false;

    return _isPermissionGranted;
  }

  @override
  void setUpdateInterval(FramesPerSecond updateInterval) {
    _updateInterval = updateInterval;
  }
}
