import 'dart:async';

import 'package:app/managers/leitnerManager.dart';
import 'package:app/managers/messageManager.dart';
import 'package:app/managers/storeManager.dart';
import 'package:app/services/audio_player_service.dart';
import 'package:app/services/jwt_service.dart';
import 'package:app/services/review_service.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/views/baseComponents/splashView.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/net/trustSsl.dart';

import 'package:app/managers/settings_manager.dart';
import 'package:app/managers/version_manager.dart';
import 'package:app/services/firebase_service.dart';
import 'package:app/services/login_service.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/system/applicationSignal.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appLocale.dart';
import 'package:app/tools/app/appNotification.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/deviceInfoTools.dart';
import 'package:app/tools/log_tools.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/baseComponents/routeDispatcher.dart';
import 'package:app/views/states/waitToLoad.dart';

bool isInitialOk = false;
bool mustWaitToSplashTimer = true;

class SplashPage extends StatefulWidget {

  SplashPage({super.key});

  @override
  SplashPageState createState() => SplashPageState();
}
///======================================================================================================
class SplashPageState extends StateBase<SplashPage> {
  static bool _callInSplashInit = false;
  static bool _callLazyInit = false;
  static bool _isInit = false;
  static bool _isInLoadingSettings = true;
  bool _isConnectToServer = false;
  int splashWaitingMil = 3000;

  @override
  Widget build(BuildContext context) {
    splashWaitTimer();
    startInit();

    if (mustWaitInSplash()) {
      //System.hideBothStatusBarOnce();
      return getSplashView();
    }
    else {
      return getFirstPage();
    }
  }

  Widget getSplashView() {
    if(kIsWeb){
      return const WaitToLoad();
    }

    return const SplashView();
  }

  Widget getFirstPage(){
    if(kIsWeb && !isInitialOk){
      return const SizedBox();
    }

    return RouteDispatcher.dispatch();
  }

  bool mustWaitInSplash(){
    return !kIsWeb && (mustWaitToSplashTimer || _isInLoadingSettings || !_isConnectToServer);
  }

  void splashWaitTimer() async {
    if(mustWaitToSplashTimer){
      mustWaitToSplashTimer = false;

      Timer(Duration(milliseconds: splashWaitingMil), (){
        callState();
      });
    }
  }

  void startInit() async {
    if (_isInit) {
      return;
    }

    _isInit = true;

    await inSplashInit(context);
    final settingsLoad = SettingsManager.loadSettings();

    if (settingsLoad) {
      await VersionManager.checkVersionOnLaunch();
      connectToServer();

      appLazyInit();
      _isInLoadingSettings = false;
      AppBroadcast.reBuildMaterialBySetTheme();
    }
  }

  void connectToServer() async {
    final serverData = await SettingsManager.requestGlobalSettings();

    if (serverData == null) {
      AppSheet.showSheetOneAction(
        RouteTools.materialContext!,
        AppMessages.errorCommunicatingServer,
        builder: () {
          AppBroadcast.gotoSplash();
          connectToServer();
        },
        buttonText: AppMessages.tryAgain,
        isDismissible: false,
      );
    }
    else {
      _isConnectToServer = true;

      SessionService.fetchLoginUsers();
      callState();
    }
  }

  static Future<void> inSplashInit(BuildContext? context) async {
    if (_callInSplashInit) {
      return;
    }

    try {
      _callInSplashInit = true;

      await AppDB.init();
      AppThemes.init();
      await AppLocale.init();
      await DeviceInfoTools.prepareDeviceInfo();
      await DeviceInfoTools.prepareDeviceId();
      TrustSsl.acceptBadCertificate();
      AudioPlayerService.init();

      if (!kIsWeb) {
      	await AppNotification.initial();
        AppNotification.startListenTap();
      }

      if(context != null && context.mounted){
        RouteTools.prepareWebRoute();
      }

      isInitialOk = true;
    }
    catch (e){
      LogTools.logger.logToAll('error in inSplashInit >> $e');
    }

    return;
  }

  static Future<void> appLazyInit() {
    final c = Completer<void>();

    if (!_callLazyInit) {
      Timer.periodic(const Duration(milliseconds: 50), (Timer timer) async {
        if (isInitialOk) {
          timer.cancel();
          await _lazyInitCommands();
          c.complete();
        }
      });
    }
    else {
      c.complete();
    }

    return c.future;
  }

  static Future<void> _lazyInitCommands() async {
    if (_callLazyInit) {
      return;
    }

    try {
      _callLazyInit = true;

      ApplicationSignal.start();
      SettingsManager.init();
      LoginService.init();
      ReviewService.init();
      MessageManager.init();
      StoreManager.init();
      //SettingsManager.requestGlobalSettings(); in connectToServer is call
      await FireBaseService.start();
      MessageManager.requestUnReadCount();
      LeitnerManager.requestLeitnerCount();
      JwtService.runRefreshService();

      /*if (System.isWeb()) {
        void onSizeCheng(oldW, oldH, newW, newH) {
          AppDialogIris.prepareDialogDecoration();
        }

        AppSizes.instance.addMetricListener(onSizeCheng);
      }*/

      if(RouteTools.materialContext != null) {
        //VersionManager.checkAppHasNewVersion(RouteTools.materialContext!);
      }
    }
    catch (e){
      _callLazyInit = false;
      LogTools.logger.logToAll('error in lazyInitCommands >> $e');
    }
  }
}