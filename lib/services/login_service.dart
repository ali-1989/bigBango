import 'dart:async';

import 'package:dio/dio.dart';

import 'package:app/models/countryModel.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appHttpDio.dart';
import 'package:app/tools/deviceInfoTools.dart';

class LoginService {
  LoginService._();

  static Future<HttpRequester?> requestSendOtp({CountryModel? countryModel, required String phoneNumber}) async {
    final http = HttpItem();
    final result = Completer<HttpRequester?>();

    final js = {};
    js[Keys.mobileNumber] = phoneNumber;

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
    js[Keys.mobileNumber] = phoneNumber;
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

    http.fullUrl = '${PublicAccess.serverApi}/primitiveOptions';
    http.method = 'GET';
    //http.setBodyJson(js);

    final request = AppHttpDio.send(http);

    var f = request.response.catchError((e){
      result.complete(null);
    });

    f = f.then((Response? response){
      if(response == null || response.statusCode == null) {
        result.complete(null);
        return;
      }

      print(response);//todo
      result.complete(request);
      return null;
    });

    return result.future;
  }
}
