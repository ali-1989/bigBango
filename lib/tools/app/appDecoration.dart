import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AppDecoration {
  AppDecoration._();

  static const mainColor = Color(0xFFF95959);
  static const secondColor = Color(0xFFF0A17D);
  static const differentColor = Color(0xFFF7C8B3);
  static Color red = Color(0xfff95959);
  static Color green = Color(0xFF0ECF73);
  static Color blue = Color(0xFF278EE3);
  static Color purple = Color(0xFF7A40EF);
  static Color greenTint = Colors.greenAccent.withAlpha(40);
  static Color redTint = Color(0xfff95959).withAlpha(40);
  static Color blueTint = Color(0xFF278EE3).withAlpha(40);
  static Color purpleTint = Color(0xFF7A40EF).withAlpha(40);
  static Color orange = Color(0xffffe5d8);

  static ClassicFooter classicFooter = const ClassicFooter(
    loadingText: '',
    idleText: '',
    noDataText: '',
    failedText: '',
    loadStyle: LoadStyle.ShowWhenLoading,
  );
}