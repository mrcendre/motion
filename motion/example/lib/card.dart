import 'package:flutter/widgets.dart';

class Card extends StatelessWidget {
  final int width, height;
  final BorderRadius borderRadius;

  const Card(
      {Key? key,
      required this.width,
      required this.height,
      required this.borderRadius})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
      width: width.toDouble(),
      height: height.toDouble(),
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          borderRadius: borderRadius,
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
