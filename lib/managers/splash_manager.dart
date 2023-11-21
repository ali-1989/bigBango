import 'dart:async';

import 'package:app/managers/leitner_manager.dart';
import 'package:app/managers/message_manager.dart';
import 'package:app/managers/store_manager.dart';
import 'package:app/services/audio_player_service.dart';
import 'package:app/services/jwt_service.dart';
import 'package:app/services/review_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/net/trustSsl.dart';

import 'package:app/managers/settings_manager.dart';
import 'package:app/services/firebase_service.dart';
import 'package:app/services/login_service.dart';
import 'package:app/system/application_signal.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_db.dart';
import 'package:app/tools/app/app_locale.dart';
import 'package:app/tools/app/app_notification.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/device_info_tools.dart';
import 'package:app/tools/log_tools.dart';
import 'package:app/tools/route_tools.dart';

class SplashManager {
  SplashManager._();

  static int splashWaitingMil = 3000;
  static bool isFullInitialOk = false;
  static bool mustWaitToSplashTimer = true;
  static bool callLazyInit = false;
  static bool isFirstInitOk = false;
  static bool isInLoadingSettings = true;
  static bool isConnectToServer = false;

  static bool mustWaitInSplash(){
    return !kIsWeb && (mustWaitToSplashTimer || isInLoadingSettings || !isConnectToServer);
  }

  static void gotoSplash() {
    mustWaitToSplashTimer = true;
    AppBroadcast.reBuildMaterial();
  }

  static Future<void> appInitial(BuildContext? context) async {
    try {
      await AppDB.init();
      AppThemes.init();
      await AppLocale.setFallBack();
      await DeviceInfoTools.prepareDeviceInfo();
      await DeviceInfoTools.prepareDeviceId();
      TrustSsl.acceptBadCertificate();
      AudioPlayerService.init();

      if (!kIsWeb) {
        await AppNotification.initial();
        AppNotification.startListenTap();
      }

      if(context != null && context.mounted){
        RouteTools.prepareRoutes();
      }

      SplashManager.isFullInitialOk = true;
    }
    catch (e){
      LogTools.logger.logToAll('error in appInitial >> $e');
    }

    return;
  }

  static Future<void> appLazyInit() {
    final c = Completer<void>();

    if (SplashManager.callLazyInit) {
      c.complete();
      return c.future;
    }

    SplashManager.callLazyInit = true;

    Timer.periodic(const Duration(milliseconds: 50), (Timer timer) async {
      if (SplashManager.isFullInitialOk) {
        timer.cancel();
        await _lazyInitCommands();
        c.complete();
      }
    });

    return c.future;
  }

  static Future<void> _lazyInitCommands() async {
    try {
      //WakeupService.init();
      //NativeCallService.init();
      //NativeCallService.assistanceBridge?.invokeMethod('setAppIsRun');
      ApplicationSignal.start();
      SettingsManager.init();
      LoginService.init();
      ReviewService.init();
      MessageManager.init();
      StoreManager.init();
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
      SplashManager.callLazyInit = false;
      LogTools.logger.logToAll('error in lazyInitCommands >> $e');
    }
  }
}

