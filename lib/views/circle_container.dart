import 'package:flutter/material.dart';

class CircleContainer extends StatelessWidget {
  final Widget child;
  final Border? border;
  final Color? backColor;
  final double size;

  const CircleContainer({
    Key? key,
    required this.child,
    this.backColor = Colors.transparent,
    this.size = 25,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mBorder = border?? Border.all(color: Colors.black, width: 0.7, style: BorderStyle.solid);

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: mBorder,
            color: backColor
        ),

        child: child,
      ),
    );
  }
}


/*
CustomCard(
    color: Colors.cyan,
    padding: EdgeInsets.symmetric(horizontal:10, vertical: 2),
    radius: 40,
    child: Text('1'),
  ),
 */