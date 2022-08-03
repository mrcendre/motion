/// The type of motion event.
enum MotionType { pointer, gyroscope }

class MotionEvent {
  /// The event's [x], [y] and [z] values.
  ///
  /// [MotionType.gyroscope] events : the [x], [y] and [z] values represent the rotation rate angle in radians, each event
  /// being relative to the previous one.
  ///
  /// [MotionType.pointer] events : the [x] and [y] values represent the pointer's position in logical pixels, each event
  /// being an absolute value. [z] always equals zero.
  final double x, y, z;

  /// The [type] of motion described by this event.
  ///
  /// Indicates whether the event's coordinates describe a relative motion (gyroscope) or the absolute coordinate
  /// inside the widget (pointer) events.
  final MotionType type;

  /// Convenience getter to detect empty motion events.
  bool get isZero => x == 0 && y == 0 && z == 0;

  const MotionEvent({required this.type, this.x = 0, this.y = 0, this.z = 0});

  const MotionEvent.zero({required this.type})
      : x = 0,
        y = 0,
        z = 0;
}
