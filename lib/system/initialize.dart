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

  static bool isCallInit = false;
  static bool isInitialOk = false;
  static bool isLaunchOk = false;

  static Future<bool> importantInit() async {
    AppDirectories.prepareStoragePaths(Constants.appName);

    if (!kIsWeb) {
      PublicAccess.reporter = Reporter(AppDirectories.getAppFolderInExternalStorage(), 'report');
    }

    return true;
  }

  static Future<bool> onceInit(BuildContext context) async {
    if (isCallInit) {
      return true;
    }

    isCallInit = true;
    TrustSsl.acceptBadCertificate();
    PublicAccess.logger = Logger('${AppDirectories.getTempDir$ex()}/events.txt');
    await DeviceInfoTools.prepareDeviceInfo();
    await DeviceInfoTools.prepareDeviceId();

    AppRoute.init();

    //AppCache.screenBack = const AssetImage(AppImages.background);
    //await precacheImage(AppCache.screenBack!, context);
    //PlayerTools.init();

    if (!kIsWeb) {
      await AppNotification.initial();
      AppNotification.startListenTap();
    }

    isInitialOk = true;
    return true;
  }

  static void callOnLaunchUp() {
    if (isLaunchOk) {
      return;
    }

    isLaunchOk = true;

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
