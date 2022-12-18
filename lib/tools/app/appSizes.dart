import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef OnResizeScreen = Function(double oldW, double oldH, double newW, double newH);
///--------------------------------------------------------------------------------------
class AppSizes {
  AppSizes._();

  static final _instance = AppSizes._();
  static bool _initialState = false;

  static double sizeOfBigScreen = 700;
  static double webMaxDialogSize = 700;

  double? realPixelWidth;
  double? realPixelHeight;
  double? pixelRatio;
  double appWidth = 0;    //Tecno: 360.0  Web: 1200
  double appHeight = 0;  //Tecno: 640.0  Web: 620
  double textMultiplier = 6; // Tecno: ~6.4
  double imageMultiplier = 1;
  double heightMultiplier = 1;
  ui.WindowPadding? rootPadding;
  List<Function> onMetricListeners = [];
  Function? _systemMetricFunc;

  static AppSizes get instance {
    if(!_initialState){
      _initialState = true;
      _instance._systemMetricFunc = ui.window.onMetricsChanged;

      _instance._initial();
    }

    return _instance;
  }

  void _initial() {
    _prepareSizes();

    //----------------- onMetricsChanged -----------------
    void onMetricsChanged(){
      final oldW = realPixelWidth;
      final oldH = realPixelHeight;
      _prepareSizes();

      /// Note: if below listener be comment, auto orientation reBuilding not work {OrientationBuilder()}
      _systemMetricFunc?.call();

      for(final f in onMetricListeners){
        try{
          f.call(oldW, oldH, realPixelWidth, realPixelHeight);
        }
        catch (e){/**/}
      }
    }

    //----------------- onLocalChanged -----------------
    //void onLocalChanged(){}

    //ui.window.onLocaleChanged = onLocalChanged;
    ui.window.onMetricsChanged = onMetricsChanged;
  }

  void _prepareSizes() {
    realPixelWidth = ui.window.physicalSize.width;
    realPixelHeight = ui.window.physicalSize.height;
    pixelRatio = ui.window.devicePixelRatio;
    rootPadding = ui.window.padding;
    final isLandscape = realPixelWidth! > realPixelHeight!;

    if(kIsWeb) {
      appWidth = realPixelWidth! / pixelRatio!;
      appHeight = realPixelHeight! / pixelRatio!;
      imageMultiplier = 3.6;
      textMultiplier = 6.2;
      heightMultiplier = 6.2;
    }
    else {
      appWidth = (isLandscape ? realPixelHeight : realPixelWidth)! / pixelRatio!;
      appHeight = (isLandscape ? realPixelWidth : realPixelHeight)! / pixelRatio!;
      imageMultiplier = appWidth / 100;
      textMultiplier = appHeight / 100; // ~6.3
      heightMultiplier = appHeight / 100;
    }
  }

  void addMetricListener(OnResizeScreen lis){
    onMetricListeners.add(lis);
  }

  void removeMetricListener(OnResizeScreen lis){
    onMetricListeners.remove(lis);
  }
  ///●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●
  static double? getPixelRatio(){
    return instance.pixelRatio;
  }

  static double multiplierSize(double size){
    return size * instance.heightMultiplier; // ~6.4
  }

  static ui.FlutterWindow getWindow(){
    return ui.window;
  }

  static Size getWindowSize(){
    return ui.window.physicalSize;
  }

  static bool isBigWidth(){
    return instance.appWidth > sizeOfBigScreen;
  }

  static double getWebPadding(){
    final over = instance.appWidth - webMaxDialogSize;

    if(over < 1){
      return 0;
    }

    return over / 2;
  }

  static double webSize(double s){
    if(kIsWeb) {
      return s * 1.3;
    }
    return s;
  }

  static double webTextFactor(double fact){
    if(kIsWeb) {
      return fact * 1.4;
    }
    return fact;
  }

  static double webFontSize(double size){
    if(kIsWeb) {
      return size * 1.3;
    }
    return size;
  }

  static double getPixelRatioBy(BuildContext context){
    return MediaQuery.of(context).devicePixelRatio;
  }

  static Size getScreenRealSize(BuildContext context){
    final r = MediaQuery.of(context).devicePixelRatio;
    final s = MediaQuery.of(context).size;

    return Size(s.width * r, s.height * r);
  }

  static double getTextScaleFactorBy(BuildContext context){
    return MediaQuery.of(context).textScaleFactor;
  }

  /// is include statusBarHeight
  static Size getScreenSizeBy(BuildContext context){
    return MediaQuery.of(context).size;
  }

  /// same of appWidth.  Tecno: 360.0   ,Web: deferToWindow [1200]
  static double getScreenWidth(BuildContext context){
    return MediaQuery.of(context).size.width;
  }

  /// is include statusBarHeight
  /// same of appHeight.   Tecno: 640.0   ,Web: deferToWindow [620]
  static double getScreenHeight(BuildContext context){
    return MediaQuery.of(context).size.height;
  }

  static double getMaxSheetHeight(BuildContext context){
    return (MediaQuery.of(context).size.height / 2) -30;
  }
  ///-----------------------------------------------------------------------------------------
  static double getStatusBarHeight(BuildContext context){
    return MediaQuery.of(context).padding.top;
  }

  static double getAppbarHeight(){
    return kToolbarHeight;
  }

  static double getViewPortHeight(BuildContext context){
    final full = MediaQuery.of(context).size.height;
    final status = MediaQuery.of(context).padding.top;
    const appBar = kToolbarHeight;

    return full - (status + appBar);
  }
}
