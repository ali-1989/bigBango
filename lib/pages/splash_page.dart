import 'dart:async';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/pages/layout_page.dart';
import 'package:app/pages/phone_number_page.dart';
import 'package:app/pages/register_form_page.dart';
import 'package:app/pages/select_language_level_page.dart';
import 'package:app/services/login_service.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/views/components/splashScreen.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/system.dart';

import 'package:app/managers/settingsManager.dart';
import 'package:app/managers/versionManager.dart';
import 'package:app/system/applicationInitialize.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';


bool _isInit = false;
bool _isInLoadingSettings = true;
bool _isConnectToServer = false;
bool isInSplashTimer = true;
int splashWaitingMil = 2000;

class SplashPage extends StatefulWidget {
  final Widget? firstPage;

  SplashPage({this.firstPage, super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}
///======================================================================================================
class SplashScreenState extends StateBase<SplashPage> {

  @override
  void initState() {
    super.initState();
  }

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
    return Builder(
      builder: (ctx){
        if(Session.hasAnyLogin()){
          System.showBothStatusBar();

          final user = Session.getLastLoginUser()!;

          if(user.courseLevelId == null){
            return SelectLanguageLevelPage();
          }

          return LayoutPage(key: AppBroadcast.layoutPageKey);
        }

        final pNumber = AppDB.fetchKv(Keys.setting$registerPhoneNumber);

        if(pNumber != null){
          final ts = AppDB.fetchKv(Keys.setting$registerPhoneNumberTs);

          if(ts != null && !DateHelper.isPastOf(DateHelper.tsToSystemDate(ts), Duration(minutes: 10))) {
            return RegisterFormPage(phoneNumber: pNumber);
          }
        }

        return PhoneNumberPage();
      },
    );
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
    await ApplicationInitial.inSplashInitWithContext(AppRoute.getLastContext()!);
    final settingsLoad = SettingsManager.loadSettings();

    if (settingsLoad) {
      await Session.fetchLoginUsers();
      await VersionManager.checkInstallVersion();
      connectToServer();

      ApplicationInitial.appLazyInit();
      _isInLoadingSettings = false;

      AppBroadcast.reBuildMaterialBySetTheme();
    }
  }

  void connectToServer() async {
    final serverData = await LoginService.requestOnSplash();

    if(serverData == null){
      AppSheet.showSheetOneAction(
        AppRoute.materialContext!,
        AppMessages.errorCommunicatingServer, (){
        AppBroadcast.gotoSplash(2000);
        connectToServer();
      },
          buttonText: AppMessages.tryAgain,
          isDismissible: false,
      );
    }
    else {
      _isConnectToServer = true;
      callState();
    }
  }
}
