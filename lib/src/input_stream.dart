import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';

import 'package:sensors_plus/sensors_plus.dart';

import 'motion_provider.dart';
import 'model/motion_event.dart';
import 'pointer_listener.dart';

bool isListening = false;

final StreamController<MotionEvent> _pointerStreamController =
    StreamController<MotionEvent>.broadcast(/*sync: true,*/ onListen: () {
  isListening = true;
}, onCancel: () {
  isListening = false;
});

class InputStream extends StatefulWidget {
  final Widget child;

  const InputStream({Key? key, required this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => InputStreamState();
}

class InputStreamState extends State<InputStream> {
  bool hasGyroscope = Platform.isIOS || Platform.isAndroid;

  late Stream<MotionEvent> inputStream;

  Stream<MotionEvent> getGyroscopeEventsStream() => gyroscopeEvents.transform(
        StreamTransformer<GyroscopeEvent, MotionEvent>.fromHandlers(
          handleData: (GyroscopeEvent event, EventSink<MotionEvent> sink) {
            sink.add(MotionEvent(
                type: MotionType.gyroscope,
                x: event.x,
                y: event.y,
                z: event.z));
          },
        ),
      );

  @override
  void initState() {
    super.initState();
    inputStream = hasGyroscope
        ? getGyroscopeEventsStream()
        : _pointerStreamController.stream;
  }

  @override
  Widget build(BuildContext context) => MotionProvider(
        stream: inputStream,
        child: hasGyroscope
            ? widget.child
            : PointerListener(
                child: widget.child,
                onPositionChange: (newOffset) {
                  if (!isListening) return;
                  _pointerStreamController.add(MotionEvent(
                      type: MotionType.pointer,
                      x: newOffset.dx,
                      y: newOffset.dy));
                }),
      );
}
