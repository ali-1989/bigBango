import 'package:flutter/material.dart';

class FilteringBuilderOptions {
  EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4);
  BoxBorder? mainBorder;
  BorderRadius? mainBorderRadius;
  ThemeData? theme;
  Widget? filterIcon;
  Color? filterTextColor;
  Color? titleTextColor;
  Color? infoTextColor;
  Color? dividerColor;
  String filterText = 'فیلتر';
  String applyText = 'اعمال';
  String removeAllText = 'حذف همه';
  String select = 'انتخاب';
  String item = 'مورد';
  String? titleText = 'فیلتر';
  TextDirection? textDirection;
}