import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/logger/logger.dart';
import 'package:iris_tools/api/logger/reporter.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/net/netManager.dart';
import 'package:iris_tools/net/trustSsl.dart';

import 'package:app/constants.dart';
import 'package:app/managers/messageManager.dart';
import 'package:app/services/audio_player_service.dart';
import 'package:app/services/event_dispatcher_service.dart';
import 'package:app/services/firebase_service.dart';
import 'package:app/services/login_service.dart';
import 'package:app/system/applicationLifeCycle.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appNotification.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSizes.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/deviceInfoTools.dart';
import 'package:app/tools/netListenerTools.dart';

class ApplicationInitial {
  ApplicationInitial._();

  static bool _importantInit = false;
  static bool _callInSplashInit = false;
  static bool _isInitialOk = false;
  static bool _callLazyInit = false;
  static String errorInInit = '';

  static bool isInit() {
    return _isInitialOk;
  }

  static Future<bool> prepareDirectoriesAndLogger() async {
    if (_importantInit) {
      return true;
    }

    try {
      _importantInit = true;
      await AppDirectories.prepareStoragePaths(Constants.appName);
      PublicAccess.logger = Logger('${AppDirectories.getTempDir$ex()}/logs');

      if (!kIsWeb) {
        PublicAccess.reporter = Reporter(AppDirectories.getAppFolderInExternalStorage(), 'report');
      }

      return true;
    }
    catch (e){
      _importantInit = false;
      errorInInit = '$e\n\n${StackTrace.current}';
      log('$e\n\n${StackTrace.current}');
      return false;
    }
  }

  static Future<void> inSplashInit() async {
    if (_callInSplashInit) {
      return;
    }

    try {
      _callInSplashInit = true;
      await AppDB.init();
      AppThemes.initial();
      TrustSsl.acceptBadCertificate();
      await DeviceInfoTools.prepareDeviceInfo();
      await DeviceInfoTools.prepareDeviceId();
      AudioPlayerService.init();

      if (!kIsWeb) {
        await AppNotification.initial();
        AppNotification.startListenTap();
      }

      _isInitialOk = true;
    }
    catch (e){
      PublicAccess.logger.logToAll('error in launchUpInit >> $e');
    }

    return;
  }

  static Future<void> inSplashInitWithContext(BuildContext context) async {
    AppRoute.init();
  }

  static Future<void> appLazyInit() {
    final c = Completer<void>();

    if (!_callLazyInit) {
      Timer.periodic(const Duration(milliseconds: 50), (Timer timer) async {
        if (_isInitialOk) {
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

      /// net & websocket
      NetManager.addChangeListener(NetListenerTools.onNetListener);
      //WebsocketService.prepareWebSocket(SettingsManager.settingsModel.wsAddress);

      /// life cycle
      ApplicationLifeCycle.init();

      /// login & logoff
      EventDispatcherService.attachFunction(EventDispatcher.userLogin, LoginService.onLoginObservable);
      EventDispatcherService.attachFunction(EventDispatcher.userLogoff, LoginService.onLogoffObservable);

      if (System.isWeb()) {
        void onSizeCheng(oldW, oldH, newW, newH) {
          AppDialogIris.prepareDialogDecoration();
        }

        AppSizes.instance.addMetricListener(onSizeCheng);
      }

      MessageManager.requestUnReadCount();

      EventDispatcherService.attachFunction(EventDispatcher.firebaseTokenReceived, ({data}) {MessageManager.requestSetFirebaseToken();});
      await FireBaseService.init();
      FireBaseService.getToken();
    }
    catch (e){
      _callLazyInit = false;
      PublicAccess.logger.logToAll('error in lazyInitCommands >> $e');
    }
  }
}
