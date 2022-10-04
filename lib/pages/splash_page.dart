import 'dart:async';

import 'package:app/managers/fontManager.dart';
import 'package:app/models/abstract/stateBase.dart';
import 'package:app/pages/layout_page.dart';
import 'package:app/pages/phone_number_page.dart';
import 'package:app/pages/register_form_page.dart';
import 'package:app/pages/select_language_level_page.dart';
import 'package:app/services/login_service.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/system.dart';

import 'package:app/constants.dart';
import 'package:app/managers/settingsManager.dart';
import 'package:app/managers/versionManager.dart';
import 'package:app/system/initialize.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

bool _isInit = false;
bool _isInLoadingSettings = true;
bool _isConnectToServer = false;
bool isInSplashTimer = true;
int splashWaitingMil = 2000;

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

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
      System.hideBothStatusBar();
      return getSplashView();
    }
    else {
      System.showBothStatusBar();
      return getFirstPage();
    }
  }
  ///==================================================================================================
  Widget getSplashView() {
    if (kIsWeb) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Material(
      child: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFFF0A17D), Color(0xFFFFFFFF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                )
            ),
            child: SizedBox.expand(),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            //child: SvgPicture.asset('assets/images/splash.svg', fit: BoxFit.fill, allowDrawingOutsideViewBox: true)
            child: SizedBox(height: sh * 0.75, child: Image.asset(AppImages.logoSplash, fit: BoxFit.fill)
            ),
          ),

          Positioned(
            bottom: 40,
            left: 43,
            right: 43,
            child: Image.asset(AppImages.keyboard, fit: BoxFit.scaleDown),
          ),

          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ColoredBox(
                color: Colors.white,
                child: SizedBox(
                    height: 30,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: Text(' نسخه ی ${Constants.appVersionName}',
                          style: TextStyle(fontFamily: FontManager.instance.defaultFontFor('fa', FontUsage.bold).family)
                      ),
                    )
                ),
              )),
        ],
      ),
    );
  }
  ///==================================================================================================
  Widget getFirstPage(){
    return Builder(
      builder: (ctx){
        if(Session.hasAnyLogin()){
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

        AppBroadcast.reBuildMaterial();
      });

      splashWaitingMil = 0;
    }
  }

  void init() async {
    if (_isInit) {
      return;
    }

    _isInit = true;

    await AppDB.init();
    AppThemes.initial();
    final settingsLoad = SettingsManager.loadSettings();

    if (settingsLoad) {
      await Session.fetchLoginUsers();
      await VersionManager.checkInstallVersion();
      await InitialApplication.launchUpInit();
      connectToServer();

      InitialApplication.appLazyInit();
      _isInLoadingSettings = false;

      AppBroadcast.reBuildMaterialBySetTheme();
    }
  }

  void connectToServer() async {
    final serverData = await LoginService.requestOnSplash();

    if(serverData == null){
      AppSheet.showSheetOneAction(
        AppRoute.materialContext,
        AppMessages.errorCommunicatingServer, (){
        AppBroadcast.gotoSplash(2);
        connectToServer();
      },
          buttonText: AppMessages.tryAgain,
          isDismissible: false,
      );
    }
    else {
      _isConnectToServer = true;
      AppBroadcast.reBuildMaterial();
    }
  }
}
