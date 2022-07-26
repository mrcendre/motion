import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:motion/src/model/constants.dart';

import 'package:sensors_plus/sensors_plus.dart';

import 'motion_provider.dart';
import 'model/motion_event.dart';
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
  bool hasGyroscope = Platform.isIOS || Platform.isAndroid;

  /// The duration between two events
  Duration? sampleRate;

  DateTime? lastEventTime;
  MotionEvent? lastEvent;

  late Stream<MotionEvent> inputStream;

  Stream<MotionEvent> getGyroscopeEventsStream() => gyroscopeEvents.transform(
        StreamTransformer<GyroscopeEvent, MotionEvent>.fromHandlers(
          handleData:
              (GyroscopeEvent event, EventSink<MotionEvent> sink) async {
            final now = DateTime.now();

            MotionEvent? motionEvent = MotionEvent(
                type: MotionType.gyroscope, x: event.x, y: event.y, z: event.z);

            // If a last event is available, we can compute the sample rate.
            if (lastEvent != null) {
              sampleRate = now.difference(lastEventTime ?? now);
              if (sampleRate == Duration.zero) {
                sampleRate = const Duration(seconds: 1);
              }
            }

            // Determine if interstitial frames are actually useful.
            bool needsInterstitialFrames = (sampleRate?.inMilliseconds ?? 0) >
                    minFrameDuration.inMilliseconds &&
                Platform.isAndroid;

            // Fire as many events as needed to achieve a smooth animation, by lerping from [lastEvent] towards this event.
            if (lastEvent != null &&
                sampleRate != null &&
                needsInterstitialFrames) {
              // The total number of interstitial frames to generate.
              final interstitialFramesCount =
                  (sampleRate!.inMilliseconds / minFrameDuration.inMilliseconds)
                      .ceil();

              // The current interstitial frame's index.
              int i = 0;

              while (i < interstitialFramesCount) {
                // Delay the next frame.
                await Future.delayed(Duration(
                    milliseconds: ((sampleRate?.inMilliseconds ?? 0) /
                                interstitialFramesCount -
                            1)
                        .ceil()));

                // Calculate the current interstitial frame's lerped values.
                final progress = i / interstitialFramesCount,
                    interstitialEvent = MotionEvent(
                        type: MotionType.gyroscope,
                        x: lerpDouble(lastEvent?.x, event.x, progress) ?? 0,
                        y: lerpDouble(lastEvent?.y, event.y, progress) ?? 0,
                        z: lerpDouble(lastEvent?.z, event.z, progress) ?? 0);

                sink.add(interstitialEvent);

                i++;
              }

              sink.add(motionEvent);
            } else {
              // If the sample rate is high enough, add the event right away.
              sink.add(motionEvent);
            }

            lastEventTime = DateTime.now();
            lastEvent = motionEvent;

            return;
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
