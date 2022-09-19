import 'package:flutter/material.dart';


class EmptyData extends StatelessWidget {
  final TextStyle? textStyle;

  const EmptyData({
    this.textStyle,
    Key? key,
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('داده ای یافت نشد',
            style: textStyle?? const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
