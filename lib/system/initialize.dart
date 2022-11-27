import 'dart:async';

import 'package:app/services/audio_player_service.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/userLoginTools.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/appEventListener.dart';
import 'package:iris_tools/api/logger/logger.dart';
import 'package:iris_tools/api/logger/reporter.dart';
import 'package:iris_tools/api/system.dart';

import 'package:app/constants.dart';
import 'package:app/system/lifeCycleApplication.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appNotification.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSizes.dart';
import 'package:app/tools/deviceInfoTools.dart';
import 'package:iris_tools/net/trustSsl.dart';

class InitialApplication {
  InitialApplication._();

  static bool _callLaunchUpInit = false;
  static bool _isInitialOk = false;
  static bool _callLazyInit = false;

  static Future<bool> importantInit() async {
    try {
      await AppDirectories.prepareStoragePaths(Constants.appName);

      if (!kIsWeb) {
        PublicAccess.reporter = Reporter(AppDirectories.getAppFolderInExternalStorage(), 'report');
      }

      PublicAccess.logger = Logger('${AppDirectories.getTempDir$ex()}/logs');

      return true;
    }
    catch (e){
      return false;
    }
  }

  static Future<void> launchUpInit() async {
    if (_callLaunchUpInit) {
      return;
    }

    _callLaunchUpInit = true;
    TrustSsl.acceptBadCertificate();
    await DeviceInfoTools.prepareDeviceInfo();
    await DeviceInfoTools.prepareDeviceId();

    AppRoute.init();
    AudioPlayerService.init();

    if (!kIsWeb) {
      await AppNotification.initial();
      AppNotification.startListenTap();
    }

    _isInitialOk = true;
    return;
  }

  static void appLazyInit() {
    if (!_callLazyInit) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Timer.periodic(const Duration(milliseconds: 50), (Timer timer) {
          if (_isInitialOk) {
            timer.cancel();

            _lazyInitCommands();
          }
        });
      });
    }
  }

  static void _lazyInitCommands() {
    if (_callLazyInit) {
      return;
    }

    _callLazyInit = true;

    //VersionManager.checkAppHasNewVersion(AppRoute.getContext()); // this is check in splash
    final eventListener = AppEventListener();
    eventListener.addResumeListener(LifeCycleApplication.onResume);
    eventListener.addPauseListener(LifeCycleApplication.onPause);
    eventListener.addDetachListener(LifeCycleApplication.onDetach);
    WidgetsBinding.instance.addObserver(eventListener);

    //WebsocketService.prepareWebSocket(SettingsManager.settingsModel.wsAddress);
		
		// ignore: unawaited_futures
		//CountryTools.fetchCountries();
    if (System.isWeb()) {
      void onSizeCheng(oldW, oldH, newW, newH) {
        AppDialogIris.prepareDialogDecoration();
      }

      AppSizes.instance.addMetricListener(onSizeCheng);
    }

    Session.addLoginListener(UserLoginTools.onLogin);
    Session.addLogoffListener(UserLoginTools.onLogoff);
    Session.addProfileChangeListener(UserLoginTools.onProfileChange);
	}
}
