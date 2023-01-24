import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import 'package:iris_tools/features/overlayDialog.dart';

class AppInfoDisplay {
  AppInfoDisplay._();

  static void showMiniInfo(BuildContext context, Widget info, {
    double top = 0,
    double bottom = 0,
    double start = 0,
    double end = 0,
    bool center = true,
    String routeName = 'showMiniInfo'
  }){
    final Widget v = Bounce(
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: info,
            ),
          )
      ),
    );

    OverlayDialog().showMiniInfo(
      context, v,
      routeName,
      top: top,
      bottom: bottom,
      start: start,
      end: end,
      center: center,
    );
  }
}