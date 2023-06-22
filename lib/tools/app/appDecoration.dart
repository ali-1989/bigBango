import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AppDecoration {
  AppDecoration._();

  static const mainColor = Color(0xFFF95959);
  static const secondColor = Color(0xFFF0A17D);
  static const differentColor = Color(0xFFF7C8B3);
  static const red = Color(0xfff0134d);
  static const green = Color(0xFF00cc6a);
  static const blue = Color(0xFF79dae8);
  static const orange = Color(0xfffbb454);
  static const purple = Color(0xFF7A40EF);
  static Color greenTint = green.withAlpha(40);
  static Color redTint = red.withAlpha(40);
  static Color blueTint = blue.withAlpha(100);
  static Color purpleTint = purple.withAlpha(40);

  
  static ClassicFooter classicFooter = const ClassicFooter(
    loadingText: '',
    idleText: '',
    noDataText: '',
    failedText: '',
    loadStyle: LoadStyle.ShowWhenLoading,
  );
}