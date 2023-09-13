import 'dart:async';

import 'package:dio/dio.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/models/twoStateReturn.dart';

import 'package:app/managers/api_manager.dart';
import 'package:app/managers/leitner_manager.dart';
import 'package:app/managers/message_manager.dart';
import 'package:app/managers/settings_manager.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/enums/app_events.dart';
import 'package:app/structures/models/country_model.dart';
import 'package:app/structures/models/user_model.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_http_dio.dart';
import 'package:app/tools/device_info_tools.dart';
import 'package:app/tools/route_tools.dart';
import 'package:iris_tools/modules/stateManagers/assistState.dart';

class LoginService {
  LoginService._();

  static void init(){
    EventNotifierService.addListener(AppEvents.userLogin, onLoginObservable);
    EventNotifierService.addListener(AppEvents.userLogoff, onLogoffObservable);
  }

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
      info.fullUrl = '${SettingsManager.localSettings.httpAddress}/logout';
      info.method = 'POST';
      info.body = JsonHelper.mapToJson(reqJs);
      info.setResponseIsPlain();

      AppHttpDio.send(info);
      //r.response.then((value) => );
    }
  }

  static Future forceLogoff(String userId) async {
    final isCurrent = SessionService.getLastLoginUser()?.userId == userId;
    await SessionService.logoff(userId);

    AssistController.forId(AppBroadcast.drawerMenuRefresherId)!.update();
    //AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();

    if (isCurrent) {
      RouteTools.backToRoot(RouteTools.getTopContext()!);
      AppBroadcast.reBuildMaterial();
    }
  }

  static Future forceLogoffAll() async {
    await SessionService.logoffAll();

    AssistController.forId(AppBroadcast.drawerMenuRefresherId)!.update();
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

    http.fullUrl = '${ApiManager.serverApi}/login';
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

    http.fullUrl = '${ApiManager.serverApi}/verifyPhoneNumber';
    http.method = 'POST';
    http.setBodyJson(js);
    http.debugMode = true;

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
