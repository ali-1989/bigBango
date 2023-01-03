import 'package:flutter/material.dart';

import 'package:app/tools/app/appImages.dart';

class EmptyData extends StatelessWidget {
  final TextStyle? textStyle;
  final String? message;

  const EmptyData({
    this.textStyle,
    this.message,
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
          const SizedBox(height: 40),

          Flexible(
            flex: 2,
              child: AspectRatio(
                  aspectRatio: 3/5,
                  child: Image.asset(AppImages.notFound)
              )
          ),

          Flexible(
            flex: 1,
            child: Center(
              child: Text(message?? 'داده ای یافت نشد',
                style: textStyle?? const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
