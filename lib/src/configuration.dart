import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:motion/src/motion_event.dart';

class MotionConfiguration extends InheritedWidget {
  bool get hasGyroscope => Platform.isIOS || Platform.isAndroid;

  /// The motion events stream, either gyroscope or pointer, depending on the platform.
  final Stream<MotionEvent> stream;

  const MotionConfiguration(
      {Key? key, required Widget child, required this.stream})
      : super(key: key, child: child);

  static MotionConfiguration? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MotionConfiguration>();

  @override
  bool updateShouldNotify(MotionConfiguration oldWidget) {
    return true;
  }
}
