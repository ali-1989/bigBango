import 'dart:async';

import 'package:dio/dio.dart';

import 'package:app/models/countryModel.dart';
import 'package:app/system/httpCodes.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appHttpDio.dart';
import 'package:app/tools/deviceInfoTools.dart';

class LoginService {
  LoginService._();

  static Future<Map?> requestSendOtp({CountryModel? countryModel, required String phoneNumber}) async {
    final http = HttpItem();
    final result = Completer<Map?>();

    final js = {};
    js[Keys.mobileNumber] = phoneNumber;
    //js.addAll(countryModel.toMap());

    http.fullUrl = PublicAccess.serverApi;
    http.method = 'POST';
    http.setBodyJson(js);

    final request = AppHttpDio.send(http);

    var f = request.response.catchError((e){
      result.complete(null);
    });

    f = f.then((Response? response){
      if(response == null || !request.isOk) {
        result.complete(null);
        return;
      }

      if(response.statusCode == 422){

      }

      result.complete(request.getBodyAsJson());
      return null;
    });

    return result.future;
  }

  static Future<LoginResultWrapper> requestVerifyOtp({CountryModel? countryModel, required String phoneNumber, required String code}) async {
    final http = HttpItem();
    final result = Completer<LoginResultWrapper>();

    final js = {};
    js[Keys.mobileNumber] = phoneNumber;
    js['code'] = code;
    js['clintId'] = DeviceInfoTools.deviceId;
    //js.addAll(DeviceInfoTools.getDeviceInfo());
    //PublicAccess.addAppInfo(js);

    http.fullUrl = PublicAccess.serverApi;
    http.method = 'POST';
    http.setBodyJson(js);

    final request = AppHttpDio.send(http);
    final loginWrapper = LoginResultWrapper();

    var f = request.response.catchError((e){
      loginWrapper.connectionError = true;
      result.complete(loginWrapper);
    });

    f = f.then((Response? response){
      if(response == null || !request.isOk) {
        loginWrapper.connectionError = true;
        result.complete(loginWrapper);
      }

      final resJs = request.getBodyAsJson()!;
      final status = '';
      loginWrapper.jsResult = resJs;

      if(status == Keys.error){
        loginWrapper.hasError = true;

        if(loginWrapper.causeCode == HttpCodes.error_dataNotExist){
          /**/
        }
        else if(loginWrapper.causeCode == HttpCodes.error_userIsBlocked){
          loginWrapper.isBlock = true;
        }
      }
      else {
        loginWrapper.isVerify = true;
      }

      result.complete(loginWrapper);
      return null;
    });

    return result.future;
  }
}
///============================================================================
class LoginResultWrapper {
  Map? jsResult;
  bool isVerify = false;
  bool isBlock = false;
  bool hasError = false;
  bool connectionError = false;
  int causeCode = 0;
}
