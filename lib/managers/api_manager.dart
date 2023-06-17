import 'dart:async';
import 'dart:math';

import 'package:app/services/session_service.dart';
import 'package:app/structures/enums/appAssistKeys.dart';
import 'package:app/structures/enums/appStoreScope.dart';
import 'package:app/structures/models/courseLevelModel.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:dio/dio.dart';
import 'package:iris_runtime_cache/iris_runtime_cache.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/models/twoStateReturn.dart';

import 'package:app/managers/settings_manager.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

class ApiManager {
  ApiManager._();

  static String serverApi = SettingsManager.localSettings.httpAddress;

  static Future<TwoStateReturn<Map, Response>> publicApiCaller(String url, MethodType methodType, Map<String, dynamic>? body){
    Requester requester = Requester();
    Completer<TwoStateReturn<Map, Response>> res = Completer();

    requester.httpRequestEvents.onFailState = (req, response) async {
      res.complete(TwoStateReturn(r2: response));
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final js = JsonHelper.jsonToMap(data)!;

      res.complete(TwoStateReturn(r1: js));
    };

    if(body != null){
      requester.bodyJson = body;
    }

    requester.prepareUrl(pathUrl: url);
    requester.methodType = methodType;

    requester.request(null, false);
    return res.future;
  }

  static Future<int?> requestUserBalance() async {
    final r = await publicApiCaller('/wallet/balance', MethodType.get, null);

    if(r.hasResult1()){
      final data = r.result1!['data'];
      return data['amount'];
    }
    else {
      return null;
    }
  }

  static Future<int?> requestUserRemainingMinutes(String userId) async {
    final r = await publicApiCaller('/appointments/remainingMinutes', MethodType.get, null);

    if(r.hasResult1()){
      final data = r.result1!['data'];
      final int min = max(data['minutes'], 0);

      IrisRuntimeCache.storeOrUpdate(AppStoreScope.user$supportTime, userId, min, updateDuration: Duration(minutes: 10));
      return min;
    }
    else {
      return null;
    }
  }

  static Future<bool> requestSetLevel(CourseLevelModel? level){
    Requester requester = Requester();
    Completer<bool> res = Completer();

    requester.httpRequestEvents.onFailState = (req, data) async {
      res.complete(false);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final user = SessionService.getLastLoginUser()!;

      user.courseLevel = level;
      SessionService.sinkUserInfo(user);

      res.complete(true);
    };

    requester.bodyJson = {'courseLevelId' : SettingsManager.getCourseLevelById(1)?.id};
    requester.prepareUrl(pathUrl: '/profile/update');
    requester.methodType = MethodType.put;

    requester.request(null, false);
    return res.future;
  }

  static Future<void> requestGetLessonProgress(LessonModel lessonModel) async {
    final url = '/lessons/details?LessonId=${lessonModel.id}';

    final twoResponse = await publicApiCaller(url, MethodType.get, null);

    if(twoResponse.hasResult1()){
      final data = twoResponse.result1!['data'];

      final les = LessonModel.fromMap(data);
      lessonModel.matchBy(les);
      AssistController.updateGroupGlobal(AppAssistKeys.updateOnLessonChange);
    }
  }
}

