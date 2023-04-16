import 'dart:async';

import 'package:app/managers/leitnerManager.dart';
import 'package:app/managers/messageManager.dart';
import 'package:dio/dio.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/models/twoStateReturn.dart';

import 'package:app/managers/settingsManager.dart';
import 'package:app/structures/models/countryModel.dart';
import 'package:app/structures/models/userModel.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appHttpDio.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/tools/deviceInfoTools.dart';

class LoginService {
  LoginService._();

  static void onLoginObservable({dynamic data}){
    MessageManager.requestSetFirebaseToken();
    MessageManager.requestUnReadCount();
    LeitnerManager.requestLeitnerCount();
  }

  static void onLogoffObservable({dynamic data}){
    if(data is UserModel){
      sendLogoffState(data);
    }
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
      RouteTools.backToRoot(RouteTools.getTopContext()!);
      AppBroadcast.reBuildMaterial();
    }
  }

  static Future forceLogoffAll() async {
    await Session.logoffAll();

    AppBroadcast.drawerMenuRefresher.update();
    //AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();

    RouteTools.backToRoot(RouteTools.getTopContext()!);
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
      return null;
    });

    f = f.then((Response? response){
      if(response == null){
        return;
      }

      if(response.statusCode == null) {
        result.complete(null);
        return;
      }

      result.complete(request);
      return null;
    });

    return result.future;
  }

  static Future<TwoStateReturn<Map?, Map?>> requestVerifyOtp({CountryModel? countryModel, required String phoneNumber, required String code}) async {
    final http = HttpItem();
    final result = Completer<TwoStateReturn<Map?, Map?>>();

    final js = {};
    js['phoneNumber'] = phoneNumber;
    js['code'] = code;
    js['clientSecret'] = DeviceInfoTools.deviceId;

    http.fullUrl = '${PublicAccess.serverApi}/verifyPhoneNumber';
    http.method = 'POST';
    http.setBodyJson(js);

    final request = AppHttpDio.send(http);

    var f = request.response.catchError((e){
      result.complete(TwoStateReturn());
      return null;
    });

    f = f.then((Response? response){
      if(response == null){
        return;
      }

      if(response.statusCode != 200) {
        result.complete(TwoStateReturn(r2: request.getBodyAsJson()));
        return;
      }

      result.complete(TwoStateReturn(r1: request.getBodyAsJson()));
      return null;
    });

    return result.future;
  }
}
