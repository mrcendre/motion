import 'package:flutter/widgets.dart';

import 'package:motion_platform_interface/motion_platform_interface.dart';

class MotionProvider extends InheritedWidget {
  /// The motion events stream, either gyroscope or pointer, depending on the platform.
  final Stream<MotionEvent>? stream;

  bool get hasMotion => stream != null;

  const MotionProvider({Key? key, required Widget child, required this.stream})
      : super(key: key, child: child);

  static MotionProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MotionProvider>();

  @override
  bool updateShouldNotify(MotionProvider oldWidget) {
    return oldWidget.stream != stream;
  }
}
