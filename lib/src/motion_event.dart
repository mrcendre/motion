enum MotionType { pointer, gyroscope }

class MotionEvent {
  final double x, y, z;

  /// The type of the motion event.
  ///
  /// Used to decide whether the event's coordinates describe a relative motion (gyroscope) or the absolute coordinate
  /// inside the widget (pointer) events.
  final MotionType type;

  const MotionEvent({required this.type, this.x = 0, this.y = 0, this.z = 0});
}
