import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:motion/src/model/motion_event.dart';

class MotionProvider extends InheritedWidget {
  /// A [bool] indicating whether the gyroscope is available or not.
  bool get hasGyroscope => Platform.isIOS || Platform.isAndroid;

  /// The motion events stream, either gyroscope or pointer, depending on the platform.
  final Stream<MotionEvent> stream;

  const MotionProvider({Key? key, required Widget child, required this.stream})
      : super(key: key, child: child);

  static MotionProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MotionProvider>();

  @override
  bool updateShouldNotify(MotionProvider oldWidget) {
    return oldWidget.stream != stream;
  }
}
