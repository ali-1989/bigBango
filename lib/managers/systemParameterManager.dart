import 'dart:async';

import 'package:app/constants.dart';
import 'package:app/managers/versionManager.dart';
import 'package:app/structures/models/courseLevelModel.dart';
import 'package:app/structures/models/systemParameterModel.dart';
import 'package:app/structures/models/versionModel.dart';

import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appHttpDio.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:dio/dio.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/system.dart';


class SystemParameterManager {
  static SystemParameterModel systemParameters = SystemParameterModel();

  SystemParameterManager._();

  static CourseLevelModel? getCourseLevelById(int id){
    for(final x in systemParameters.courseLevels){
      if(x.id == id){
        return x;
      }
    }

    return null;
  }

  static int getAmountOf1Minutes(){
    if(systemParameters.timeTableOption.isEmpty){
      return 0;
    }

    return systemParameters.timeTableOption['minuteAmount'];
  }

  static Future<HttpRequester?> requestSystemParameters() async {
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
          SystemParameterManager.systemParameters.courseLevels.add(CourseLevelModel.fromMap(k));
        }
      }

      SystemParameterManager.systemParameters.advertisingVideos = data['advertisingVideos']?? {};
      SystemParameterManager.systemParameters.contacts = data['contact']?? {};


      /*
      test VersionModel versionModel = VersionModel();
      versionModel.directLink = 'http://google.com';
      versionModel.restricted = false;
      versionModel.newVersionName = '2.0.1';
      */

      final versionModel = VersionModel.fromMap(data['version']?? {});
      VersionManager.checkAppHasNewVersion(AppRoute.getLastContext()!, versionModel);

      result.complete(request);
      return null;
    });

    return result.future;
  }
}