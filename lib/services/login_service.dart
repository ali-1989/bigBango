import 'dart:async';

import 'package:dio/dio.dart';
import 'package:iris_tools/api/converter.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/system.dart';

import 'package:app/constants.dart';
import 'package:app/managers/versionManager.dart';
import 'package:app/structures/models/countryModel.dart';
import 'package:app/structures/models/versionModel.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appHttpDio.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/deviceInfoTools.dart';

class LoginService {
  LoginService._();

  static Future<HttpRequester?> requestSendOtp({CountryModel? countryModel, required String phoneNumber, required String sign}) async {
    final http = HttpItem();
    final result = Completer<HttpRequester?>();

    final js = {};
    js[Keys.mobileNumber] = phoneNumber;
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

    var os = 1;

    if(System.isIOS()){
      os = 2;
    }

    http.fullUrl = '${PublicAccess.serverApi}/primitiveOptions?CurrentVersion=${Constants.appVersionName}&OperationSystem=$os';
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

      final js = JsonHelper.jsonToMap(response.data);
      final data = js?['data']?? {};

      PublicAccess.courseLevels = Converter.correctList<Map>(data['courseLevels'])?? [];
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
