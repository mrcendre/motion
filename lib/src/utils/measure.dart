import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef OnWidgetSizeChange = void Function(Size size);

class MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  final OnWidgetSizeChange onChange;

  MeasureSizeRenderObject(this.onChange);

  /// Temporarily used to remove null safety warning about [WidgetsBinding.instance] across Flutter 2 and 3.
  T? _ambiguate<T>(T? value) => value;

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;

    _ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class Measure extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const Measure({
    Key? key,
    required this.onChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }
}
