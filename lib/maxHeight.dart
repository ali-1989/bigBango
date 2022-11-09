import 'package:flutter/widgets.dart';

class MaxHeight extends StatelessWidget {
  final Widget child;
  final double maxHeight;
  final double? widthFactor;
  final double? heightFactor;
  final AlignmentGeometry alignment;

  MaxHeight({
    Key? key,
    required this.maxHeight,
    required this.child,
    this.alignment = Alignment.center,
    this.widthFactor,
    this.heightFactor,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: ConstrainedBox(
        constraints: BoxConstraints.loose(Size(double.infinity, maxHeight)),
        child: child,
      ),
    );
  }
}