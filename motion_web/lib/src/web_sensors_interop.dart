import 'dart:js_interop';

/// Gyroscope API
/// https://developer.mozilla.org/en-US/docs/Web/API/Gyroscope
@JS('Gyroscope')
extension type Gyroscope._(JSObject _) implements JSObject {
  external factory Gyroscope([
    SensorOptions options,
  ]);

  external double get x;
  external double get y;
  external double get z;

  external set onreading(JSFunction callback);
  external set onerror(JSFunction callback);

  external void start();
}

extension type SensorOptions._(JSObject _) implements JSObject {
  external factory SensorOptions({
    int frequency,
  });
}

/// Event
/// https://developer.mozilla.org/en-US/docs/Web/API/Event
extension type Event(JSObject _) implements JSObject {}

/// SensorErrorEvent
/// https://developer.mozilla.org/en-US/docs/Web/API/SensorErrorEvent
extension type SensorErrorEvent(JSObject _) implements JSObject {
  external DOMException get error;
}

/// DOMException
/// https://developer.mozilla.org/en-US/docs/Web/API/DOMException
extension type DOMException(JSObject _) implements JSObject {
  external String? get name;
  external String? get message;
}
