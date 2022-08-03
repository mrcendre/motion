/// A convenience extension for code style such as:
///
/// final framerate = 25.fps;
///
/// print(framerate.inMicroseconds); // 40
extension FPS on int {
  /// Returns the given integer as [FramesPerSecond].
  FramesPerSecond get fps => FramesPerSecond(this);
}

/// An abstraction of the number of frames per second, with helper methods.
class FramesPerSecond {
  /// The number of frames per second.
  final int fps;

  /// The duration of one frame, in microseconds.
  int get inMicroseconds => const Duration(seconds: 1).inMicroseconds ~/ fps;

  /// The [Duration] of one frame.
  Duration get duration => Duration(microseconds: inMicroseconds);

  const FramesPerSecond(this.fps);
}
