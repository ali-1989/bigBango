import 'dart:async';

import 'package:app/constants.dart';
import 'package:app/models/versionModel.dart';
import 'package:app/pages/new_version_page.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import '/managers/settingsManager.dart';

class VersionManager {
  VersionManager._();

  static Future<void> onFirstInstall() async {
    SettingsManager.settingsModel.currentVersion = Constants.appVersionCode;

    await AppDB.firstLaunch();
    SettingsManager.saveSettings();
  }

  static Future<void> onUpdateInstall() async {
    SettingsManager.settingsModel.currentVersion = Constants.appVersionCode;
    SettingsManager.saveSettings();
  }

  static Future<void> checkInstallVersion() async {
    final oldVersion = SettingsManager.settingsModel.currentVersion;

    if (oldVersion == null) {
      onFirstInstall();
    }
    else if (oldVersion < Constants.appVersionCode) {
      onUpdateInstall();
    }
  }

  /*static void checkAppHasNewVersion(BuildContext context) async {
    final deviceInfo = DeviceInfoTools.getDeviceInfo();

    final vm = await requestCheckVersion(context, deviceInfo);

    if(vm != null){
      if(vm.newVersionCode > Constants.appVersionCode){
        showUpdateDialog(AppRoute.getContext(), vm);
      }
    }
  }

  static Future<VersionModel?> requestCheckVersion(BuildContext context, Map<String, dynamic> data) async {
    final res = Completer<VersionModel?>();

    final requester = Requester();

    requester.httpRequestEvents.onAnyState = (req) async {
      requester.dispose();
    };

    requester.httpRequestEvents.onFailState = (req, response) async {
      res.complete(null);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final version = VersionModel.fromMap(data);

      res.complete(version);
    };

    requester.bodyJson = data;
    requester.prepareUrl(pathUrl: '');
    requester.request(context, false);
    return res.future;
  }
*/

  static void checkAppHasNewVersion(BuildContext context, VersionModel serverVersion) async {
    var v = serverVersion.newVersionName;
    v = v.replaceAll('.', '');

    if(MathHelper.toInt(v) > Constants.appVersionCode){
      showUpdateDialog(AppRoute.getLastContext(), serverVersion);
    }
  }

  static void showUpdateDialog(BuildContext context, VersionModel vm) {
    AppRoute.push(context, NewVersionPage(versionModel: vm));
    /*void closeApp(){
      System.exitApp();
    }

    //final msg = vm.description?? AppMessages.newAppVersionIsOk;

    final decoration = AppDialogIris.instance.dialogDecoration.copy();
    decoration.positiveButtonBackColor = Colors.blue;

    AppDialogIris.instance.showYesNoDialog(
      context,
      desc: msg,
      decoration: decoration,
      yesText: AppMessages.update,
      noText: vm.restricted ? AppMessages.exit : AppMessages.later,
      yesFn: (){
        UrlHelper.launchLink(vm.directLink?? '');
      },
      noFn: vm.restricted ? closeApp: null,
    );*/
  }
}
