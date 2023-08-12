import 'package:flutter/material.dart';

class CustomSlider extends SliderComponentShape {

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(4, 16);
  }

  @override
  void paint(PaintingContext context, Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow}) {

    final canvas = context.canvas;
    final paint = Paint()..color = sliderTheme.thumbColor?? Colors.pink;

    canvas.drawRect(Rect.fromLTWH(center.dx-2, center.dy-8, 4, 16), paint);
  }
}