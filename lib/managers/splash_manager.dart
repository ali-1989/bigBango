import 'package:app/tools/app/appBroadcast.dart';
import 'package:flutter/foundation.dart';


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
}

