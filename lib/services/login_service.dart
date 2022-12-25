import 'dart:async';

import 'package:app/managers/settingsManager.dart';
import 'package:app/structures/models/courselevelModel.dart';
import 'package:app/structures/models/userModel.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:dio/dio.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/system.dart';

import 'package:app/constants.dart';
import 'package:app/managers/versionManager.dart';
import 'package:app/structures/models/countryModel.dart';
import 'package:app/structures/models/versionModel.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appHttpDio.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/deviceInfoTools.dart';

class LoginService {
  LoginService._();

  static void init(){
    Session.addLoginListener(LoginService.onLogin);
    Session.addLogoffListener(LoginService.onLogoff);
    Session.addProfileChangeListener(LoginService.onProfileChange);
  }

  static void onLogin(UserModel user){
  }

  static void onLogoff(UserModel user){
    sendLogoffState(user);
  }

  // on new data for existUser
  static void onProfileChange(UserModel user, Map? old) async {
  }

  static void sendLogoffState(UserModel user){
    if(AppBroadcast.isNetConnected){
      final reqJs = <String, dynamic>{};
      reqJs['refreshToken'] = user.token?.refreshToken;

      final info = HttpItem();
      info.fullUrl = '${SettingsManager.settingsModel.httpAddress}/logout';
      info.method = 'POST';
      info.body = JsonHelper.mapToJson(reqJs);
      info.setResponseIsPlain();

      AppHttpDio.send(info);
      //r.response.then((value) => );
    }
  }

  static Future forceLogoff(String userId) async {
    final isCurrent = Session.getLastLoginUser()?.userId == userId;
    await Session.logoff(userId);

    AppBroadcast.drawerMenuRefresher.update();
    //AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();

    if (isCurrent) {
      AppRoute.backToRoot(AppRoute.getLastContext()!);
      AppBroadcast.reBuildMaterial();
      /*Future.delayed(Duration(milliseconds: 400), (){
        AppRoute.replaceNamed(AppRoute.getContext(), LoginPage.route.name!);
      });*/
    }
  }

  static Future forceLogoffAll() async {
    await Session.logoffAll();

    AppBroadcast.drawerMenuRefresher.update();
    //AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();

    AppRoute.backToRoot(AppRoute.getLastContext()!);
    AppBroadcast.reBuildMaterial();
  }
  
  static Future<HttpRequester?> requestSendOtp({CountryModel? countryModel, required String phoneNumber, required String sign}) async {
    final http = HttpItem();
    final result = Completer<HttpRequester?>();

    final js = {};
    js['phoneNumber'] = phoneNumber;
    js['smsReaderSignature'] = sign;

    http.fullUrl = '${PublicAccess.serverApi}/login';
    http.method = 'POST';
    http.setBodyJson(js);

    final request = AppHttpDio.send(http);

    var f = request.response.catchError((e){
      result.complete(null);
    });

    f = f.then((Response? response){
      if(response == null || response.statusCode == null) {
        result.complete(null);
        return;
      }

      result.complete(request);
      return null;
    });

    return result.future;
  }

  static Future<HttpRequester?> requestVerifyOtp({CountryModel? countryModel, required String phoneNumber, required String code}) async {
    final http = HttpItem();
    final result = Completer<HttpRequester?>();

    final js = {};
    js['phoneNumber'] = phoneNumber;
    js['code'] = code;
    js['clientSecret'] = DeviceInfoTools.deviceId;

    http.fullUrl = '${PublicAccess.serverApi}/verifyPhoneNumber';
    http.method = 'POST';
    http.setBodyJson(js);

    final request = AppHttpDio.send(http);

    var f = request.response.catchError((e){
      result.complete(null);
    });

    f = f.then((Response? response){
      if(response == null) {
        result.complete(null);
        return;
      }

      result.complete(request);
      return null;
    });

    return result.future;
  }

  static Future<HttpRequester?> requestOnSplash() async {
    final http = HttpItem();
    final result = Completer<HttpRequester?>();

    var os = 1;

    if(System.isIOS()){
      os = 2;
    }

    http.fullUrl = '${PublicAccess.serverApi}/primitiveOptions?CurrentVersion=${Constants.appVersionName}&OperationSystem=$os';
    http.method = 'GET';

    final request = AppHttpDio.send(http);

    var f = request.response.catchError((e){
      result.complete(null);
    });

    f = f.then((Response? response){
      if(response == null || response.statusCode == null) {
        result.complete(null);
        return;
      }

      final js = JsonHelper.jsonToMap(response.data);
      final data = js?['data']?? {};

      final courseLevels = data['courseLevels'];

      if(courseLevels is List){
        for(final k in courseLevels){
          PublicAccess.courseLevels.add(CourseLevelModel.fromMap(k));
        }
      }

      PublicAccess.advertisingVideos = data['advertisingVideos']?? {};
      PublicAccess.contacts = data['contact']?? {};
      final versionModel = VersionModel.fromMap(data['version']?? {});

      /* test VersionModel versionModel = VersionModel();
      versionModel.directLink = 'http://google.com';
      versionModel.restricted = false;
      versionModel.newVersionName = '2.0.1';*/

      VersionManager.checkAppHasNewVersion(AppRoute.getLastContext()!, versionModel);

      result.complete(request);
      return null;
    });

    return result.future;
  }
}
