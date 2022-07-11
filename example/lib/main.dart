import 'package:motion/motion.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: 'Motion Demo',
        debugShowCheckedModeBanner: false,
        home: MyHomePage(),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = MotionController();

  final cardBorderRadius = BorderRadius.circular(25);

  int demoIndex = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
          body: Stack(children: [
        Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Text(
                'Motion example',
                style: Theme.of(context).textTheme.headline4?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 0, 0, 0)),
              )),
          _buildCard(width: 280, height: 170),
          Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 30),
              child: Text(
                'without Motion',
                style: Theme.of(context).textTheme.bodyText1,
              )),
          Motion(
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

  Widget _buildCard({
    required int width,
    required int height,
  }) =>
      Container(
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
}
