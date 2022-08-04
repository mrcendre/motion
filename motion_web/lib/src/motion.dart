import 'dart:async';
import 'dart:developer' as developer;
import 'dart:html' as html;
import 'dart:js';
import 'dart:js_util';

import 'package:js/js.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:motion_platform_interface/motion_platform_interface.dart';

import 'scripts.dart';

@JS()
external dynamic get evaluatePermission;

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

  static bool _requiresPermission = false;

  @override
  bool get requiresPermission => _requiresPermission;

  static bool _isPermissionGranted = false;

  @override
  bool get isPermissionGranted => _isPermissionGranted;

  /// The rate of updates for the sensors, in microseconds (μs).
  ///
  /// Also used to throttle events when too frequent events are emitted from sensors whose
  /// update interval cannot be set.
  FramesPerSecond _updateInterval = defaultUpdateInterval;

  /// A convenience getter for the 'frequency' option of sensors constructors, expressed in 'updates per second'.
  int get _frequency =>
      _updateInterval.inMicroseconds ~/
      const Duration(seconds: 1).inMicroseconds;

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
        developer.log('$apiName construction was blocked by a feature policy.',
            error: error);

        /// if this feature is not supported or Flag is not enabled yet!
      } else if (error.toString().contains('ReferenceError')) {
        developer.log('$apiName is not supported by the User Agent.',
            error: error);

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

  @override
  Stream<MotionEvent>? get gyroscopeStream {
    if (_gyroscopeStreamController == null) {
      _gyroscopeStreamController = StreamController();

      if (_isGyroscopeApiAvailable) {
        _featureDetected(
          () {
            final gyroscope = html.Gyroscope({
              'frequency': _frequency,
            });

            setProperty(
              gyroscope,
              'onreading',
              allowInterop(
                (_) {
                  _gyroscopeStreamController!.add(
                    MotionEvent(
                      type: MotionType.gyroscope,
                      x: gyroscope.x as double,
                      y: gyroscope.y as double,
                      z: gyroscope.z as double,
                    ),
                  );
                },
              ),
            );

            gyroscope.start();

            gyroscope.onError.forEach(
              (e) => developer.log(
                  'The gyroscope API is supported but something is wrong!',
                  error: e),
            );
          },
          apiName: 'Gyroscope()',
          permissionName: 'gyroscope',
          onError: () {
            html.window.console
                .warn('Error: Gyroscope() is not supported by the User Agent.');
            _gyroscopeStreamController!
                .add(const MotionEvent.zero(type: MotionType.gyroscope));
          },
        );
      } else if (_isDeviceMotionApiAvailable) {
        StreamSubscription? onDeviceMotionSubscription;

        /// If unavailable, fallback on the [DeviceMotionEvent] API.
        _featureDetected(
            () {
              onDeviceMotionSubscription = html.window.onDeviceMotion.listen(
                (event) {
                  final now = DateTime.now();
                  if (now.difference(lastDeviceMotionEvent) <
                      _updateInterval.duration) {
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
                },
              );
            },
            apiName: 'DeviceMotionEvent()',
            permissionName: 'DeviceMotionEvent',
            onError: () {
              html.window.console
                  .warn('The DeviceMotionEvent API is not available either.');
              onDeviceMotionSubscription?.cancel();
              _gyroscopeStreamController!
                  .add(const MotionEvent.zero(type: MotionType.gyroscope));
            });
      }
      _gyroscopeStream = _gyroscopeStreamController!.stream.asBroadcastStream();
    }

    return _gyroscopeStream;
  }

  @override
  Future<void> initialize() async {
    Scripts.load();

    _isSafariMobile = context.callMethod('isSafariMobile');

    _isGyroscopeApiAvailable = context.callMethod('isGyroscopeApiAvailable');
    _isDeviceMotionApiAvailable =
        context.callMethod('isDeviceMotionApiAvailable');

    if (_isDeviceMotionApiAvailable) {
      // If a permission is required to access the DeviceMotionEvents, we are sure there is a gyroscope on the device.
      _requiresPermission =
          context.callMethod('requiresDeviceMotionEventPermission');

      if (_requiresPermission) {
        final isGranted = promiseToFuture(evaluatePermission());
        _isPermissionGranted = await isGranted;
      }
    }

    _isGyroscopeAvailable = _isGyroscopeApiAvailable ||
        _isDeviceMotionApiAvailable ||
        _requiresPermission;

    return;
  }

  @override
  Future<bool> requestPermission() async {
    _isPermissionGranted =
        context.callMethod('requestDeviceMotionEventPermission');

    return _isPermissionGranted;
  }

  @override
  void setUpdateInterval(FramesPerSecond updateInterval) {
    _updateInterval = updateInterval;
  }
}
