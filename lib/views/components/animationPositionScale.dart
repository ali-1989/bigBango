import 'package:flutter/material.dart';

class AnimationPositionScale extends StatefulWidget {
  final Widget child;
  final double x;
  final double y;

  const AnimationPositionScale({
    required this.child,
    required this.x,
    required this.y,
    Key? key
  }) : super(key: key);

  @override
  State createState() => AnimationPositionScaleState();
}
///====================================================================================================
class AnimationPositionScaleState extends State<AnimationPositionScale> with TickerProviderStateMixin {
  late final AnimationController animCtr;
  late final Animation<double> moveAmin;
  late final Animation<double> scaleAmin;

  @override
  void initState() {
    super.initState();

    animCtr = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    moveAmin = Tween(begin:widget.y-100, end: 0.0).animate(animCtr);
    scaleAmin = Tween(begin:0.05, end: 1.0).animate(animCtr);
    animCtr.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: moveAmin,
      builder: (context, child) {

        return Transform.scale(
          scaleX: scaleAmin.value,
          alignment: Alignment.centerLeft,
          origin: Offset(widget.x, 0),
          child: Transform.translate(
            offset: Offset(0, moveAmin.value),
            child: widget.child,
          ),
        );
      },
    );
  }
}