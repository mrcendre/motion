import 'package:motion/motion.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize the plugin to determine gyroscope availability.
  await Motion.initialize();

  /// Globally set Motion's update interval to 60 frames per second.
  Motion.setUpdateInterval(60.fps);

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
  final controller = MotionController();

  final cardBorderRadius = BorderRadius.circular(25);

  @override
  Widget build(BuildContext context) {
    if (Motion.requiresPermission && !Motion.isPermissionGranted) {
      showPermissionRequestDialog(
        context,
        onDone: () {
          setState(() {});
        },
      );
    }

    return Scaffold(
        body: Stack(children: [
      Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Text(
              'Motion example',
              style: Theme.of(context).textTheme.headline4?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color.fromARGB(255, 0, 0, 0)),
            )),
        _buildCard(width: 280, height: 170),
        Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 30),
            child: Text(
              'without Motion',
              style: Theme.of(context).textTheme.bodyText1,
            )),
        Motion.elevated(
          elevation: 100,
          borderRadius: cardBorderRadius,
          controller: controller,
          child: _buildCard(width: 280, height: 170),
        ),
        Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Text(
              'with Motion',
              style: Theme.of(context).textTheme.bodyText1,
            )),
      ]))
    ]));
  }

  Widget _buildCard({required int width, required int height}) => Container(
      width: width.toDouble(),
      height: height.toDouble(),
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          borderRadius: cardBorderRadius,
          color: const Color.fromARGB(255, 45, 45, 45)),
      child: _buildShortDummyParagraph());

  Widget _buildShortDummyParagraph() => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDummyLine(1),
            const SizedBox(height: 5),
            _buildDummyLine(0.98),
            const SizedBox(height: 5),
            _buildDummyLine(0.95),
            const SizedBox(height: 5),
            _buildDummyLine(0.6),
          ]);

  Widget _buildDummyLine(double widthFactor) => FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
          height: 20, color: const Color.fromARGB(100, 255, 255, 255)));

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
                    Motion.requestPermission();
                  },
                  child: const Text('OK'),
                ),
              ],
            ));
  }
}
