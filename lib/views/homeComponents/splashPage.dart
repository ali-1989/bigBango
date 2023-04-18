import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/system.dart';

import 'package:app/managers/settingsManager.dart';
import 'package:app/managers/systemParameterManager.dart';
import 'package:app/managers/versionManager.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/system/applicationInitialize.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/homeComponents/routeDispatcher.dart';
import 'package:app/views/homeComponents/splashScreen.dart';
import 'package:app/views/states/waitToLoad.dart';

bool _isInit = false;
bool _isInLoadingSettings = true;
bool _isConnectToServer = false;
bool isInSplashTimer = true;
int splashWaitingMil = 2000;

class SplashPage extends StatefulWidget {

  SplashPage({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}
///======================================================================================================
class SplashScreenState extends StateBase<SplashPage> {

  @override
  Widget build(BuildContext context) {
    splashWaitTimer();
    init();

    if (waitInSplash()) {
      System.hideBothStatusBarOnce();
      return getSplashView();
    }
    else {
      return getFirstPage();
    }
  }
  ///==================================================================================================
  Widget getSplashView() {
    if(kIsWeb){
      return const WaitToLoad();
    }

    return SplashScreen();
  }
  ///==================================================================================================
  Widget getFirstPage(){
    if(kIsWeb && !ApplicationInitial.isInit()){
      return SizedBox();
    }

    return RouteDispatcher.dispatch();
  }

  bool waitInSplash(){
    return !kIsWeb && (isInSplashTimer || _isInLoadingSettings || !_isConnectToServer);
  }

  void splashWaitTimer() async {
    if(splashWaitingMil > 0){
      Timer(Duration(milliseconds: splashWaitingMil), (){
        isInSplashTimer = false;
        callState();
      });

      splashWaitingMil = 0;
    }
  }

  void init() async {
    if (_isInit) {
      return;
    }

    _isInit = true;

    await ApplicationInitial.inSplashInit();
    await ApplicationInitial.inSplashInitWithContext(context);
    final settingsLoad = SettingsManager.loadSettings();

    if (settingsLoad) {
      await VersionManager.checkInstallVersion();
      connectToServer();

      ApplicationInitial.appLazyInit();
      _isInLoadingSettings = false;

      AppBroadcast.reBuildMaterialBySetTheme();
    }
  }

  void connectToServer() async {
    final serverData = await SystemParameterManager.requestParameters();

    if(serverData == null){
      AppSheet.showSheetOneAction(
        RouteTools.materialContext!,
        AppMessages.errorCommunicatingServer,
         (){
          AppBroadcast.gotoSplash(2000);

          connectToServer();
        },
        buttonText: AppMessages.tryAgain,
        isDismissible: false,
      );
    }
    else {
      _isConnectToServer = true;
      Session.fetchLoginUsers();
      callState();
    }
  }
}
