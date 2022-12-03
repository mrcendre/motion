import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:motion_platform_interface/motion_platform_interface.dart';

import 'motion.dart';
import 'motion_provider.dart';
import 'pointer_listener.dart';

bool isListening = false;

final StreamController<MotionEvent> _pointerStreamController =
    StreamController<MotionEvent>.broadcast(onListen: () {
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
  Stream<MotionEvent>? inputStream;

  DateTime? lastPointerEventTime;

  @override
  void initState() {
    super.initState();
    initialiseInputStream();
  }

  void initialiseInputStream() async {
    await Motion.instance.initialize();
    Motion.instance.setUpdateInterval(60.fps);
    inputStream = Motion.instance.isGyroscopeAvailable &&
            Motion.instance.gyroscopeStream != null
        ? Motion.instance.gyroscopeStream!
        : _pointerStreamController.stream;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => inputStream == null
      ? widget.child
      : MotionProvider(
          stream: inputStream,
          child: Motion.instance.isGyroscopeAvailable
              ? widget.child
              : PointerListener(
                  child: widget.child,
                  onPositionChange: (newOffset) {
                    if (!isListening) return;

                    final now = DateTime.now();
                    if (lastPointerEventTime == null) {
                      lastPointerEventTime = now;
                    } else if (now.difference(lastPointerEventTime!) <
                        Motion.instance.updateInterval.duration) {
                      /// Drop events more frequent than [_updateInterval]
                      return;
                    }

                    lastPointerEventTime = now;

                    _pointerStreamController.add(MotionEvent(
                        type: MotionType.pointer,
                        x: newOffset.dx,
                        y: newOffset.dy));
                  }),
        );
}
