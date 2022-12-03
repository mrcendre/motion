import 'package:flutter/material.dart' hide Card;
import 'package:motion/motion.dart';
import 'package:motion_example/card.dart';

const cardBorderRadius = BorderRadius.all(Radius.circular(25));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize the plugin to determine gyroscope availability.
  await Motion.instance.initialize();

  /// Globally set Motion's update interval to 60 frames per second.
  Motion.instance.setUpdateInterval(60.fps);

  /// ... and run the sample app.
  runApp(const MotionDemoApp());
}

class MotionDemoApp extends StatelessWidget {
  const MotionDemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: 'Motion Demo',
        debugShowCheckedModeBanner: false,
        home: MotionDemoPage(),
      );
}

class MotionDemoPage extends StatefulWidget {
  const MotionDemoPage({Key? key}) : super(key: key);

  @override
  State<MotionDemoPage> createState() => _MotionDemoPageState();
}

class _MotionDemoPageState extends State<MotionDemoPage> {
  @override
  Widget build(BuildContext context) {
    if (Motion.instance.requiresPermission &&
        !Motion.instance.isPermissionGranted) {
      showPermissionRequestDialog(
        context,
        onDone: () {
          setState(() {});
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(80.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Text(
                    'Motion example',
                    style: Theme.of(context).textTheme.headline4?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color.fromARGB(255, 0, 0, 0)),
                  )),
              const Card(
                  width: 280, height: 170, borderRadius: cardBorderRadius),
              Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 30),
                  child: Text(
                    'without Motion',
                    style: Theme.of(context).textTheme.bodyText1,
                  )),
              SizedBox(
                width: 280,
                height: 170,
                child: Motion.elevated(
                  elevation: 70,
                  borderRadius: cardBorderRadius,
                  child: const Card(
                      width: 280, height: 170, borderRadius: cardBorderRadius),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Text(
                    'with Motion',
                    style: Theme.of(context).textTheme.bodyText1,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showPermissionRequestDialog(BuildContext context,
      {required Function() onDone}) async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Permission required'),
              content: const Text(
                  'On iOS 13+, you need to grant access to the gyroscope. A permission will be requested to proceed.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Motion.instance.requestPermission();
                  },
                  child: const Text('OK'),
                ),
              ],
            ));
  }
}
