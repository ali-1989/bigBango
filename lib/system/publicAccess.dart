import 'dart:async';
import 'dart:math';

import 'package:app/pages/grammar_page.dart';
import 'package:app/pages/idioms_page.dart';
import 'package:app/pages/listening_page.dart';
import 'package:app/pages/reading_page.dart';
import 'package:app/structures/injectors/grammarPagesInjector.dart';
import 'package:app/structures/injectors/listeningPagesInjector.dart';
import 'package:app/structures/injectors/readingPagesInjector.dart';
import 'package:app/structures/injectors/vocabPagesInjector.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:app/structures/models/towReturn.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';

import 'package:iris_tools/api/logger/logger.dart';
import 'package:iris_tools/api/logger/reporter.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/constants.dart';
import 'package:app/managers/settingsManager.dart';
import 'package:app/structures/mixin/dateFieldMixin.dart';
import 'package:app/structures/models/userModel.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PublicAccess {
  PublicAccess._();

  static late Logger logger;
  static late Reporter reporter;
  static String serverApi = SettingsManager.settingsModel.httpAddress;

  static ClassicFooter classicFooter = const ClassicFooter(
    loadingText: '',
    idleText: '',
    noDataText: '',
    failedText: '',
    loadStyle: LoadStyle.ShowWhenLoading,
  );

  static Map addLanguageIso(Map src, [BuildContext? ctx]) {
    src[Keys.languageIso] = System.getLocalizationsLanguageCode(ctx ?? AppRoute.getLastContext()!);

    return src;
  }

  static Map addAppInfo(Map src, {UserModel? curUser}) {
    final token = curUser?.token ?? Session.getLastLoginUser()?.token;

    src.addAll(getAppInfo());

    if (token?.token != null) {
      src[Keys.token] = token?.token;
      //src['fcm_token'] = FireBaseService.token;
    }

    return src;
  }

  static Map<String, dynamic> getAppInfo() {
    final res = <String, dynamic>{};
    res['app_version_code'] = Constants.appVersionCode;
    res['app_version_name'] = Constants.appVersionName;

    return res;
  }

  static void sortList(List<DateFieldMixin> list, bool isAsc){
    if(list.isEmpty){
      return;
    }

    int sorter(DateFieldMixin d1, DateFieldMixin d2){
      return DateHelper.compareDates(d1.date, d2.date, asc: isAsc);
    }

    list.sort(sorter);
  }

  static Widget? getNextPartOfLesson(LessonModel lessonModel){
    Widget? page;

    if(lessonModel.vocabSegmentModel != null && lessonModel.vocabSegmentModel!.hasIdioms){
      page = IdiomsPage(injector: VocabIdiomsPageInjector(lessonModel));
    }
    else if (lessonModel.grammarModel != null){
      page = GrammarPage(injector: GrammarPageInjector(lessonModel));
    }
    else if (lessonModel.readingModel != null){
      page = ReadingPage(injector: ReadingPageInjector(lessonModel));
    }
    else if (lessonModel.listeningModel != null && lessonModel.listeningModel!.listeningList.isNotEmpty){
      if (lessonModel.listeningModel!.listeningList.length == 1) {
        page = ListeningPage(injector: ListeningPageInjector(lessonModel, lessonModel.listeningModel!.listeningList[0].id));
      }
      else {
        page = ListeningPage(injector: ListeningPageInjector(lessonModel, lessonModel.listeningModel!.listeningList[0].id));
      }
    }

    return page;
  }

  static void printObj(Object obj){
    print('${'*' * 40}\n ${obj.toString()} \n${'*' * 50}');
  }

  static Future<TwoReturn<Map, Response>> publicApiCaller(String url, MethodType methodType, Map<String, dynamic>? body){
    Requester requester = Requester();
    Completer<TwoReturn<Map, Response>> res = Completer();

    requester.httpRequestEvents.onFailState = (req, response) async {
      res.complete(TwoReturn(r2: response));
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final js = JsonHelper.jsonToMap(data)!;

      res.complete(TwoReturn(r1: js));
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

  static Future<int?> requestUserRemainingMinutes() async {
    final r = await publicApiCaller('/appointments/remainingMinutes', MethodType.get, null);

    if(r.hasResult1()){
      final data = r.result1!['data'];
      return max(data['minutes'], 0);
    }
    else {
      return null;
    }
  }
}


/*static WidgetsBinding getAppWidgetsBinding() {
    return WidgetsBinding.instance;
  }*/



/*static UpperLower findUpperLower(List<DateFieldMixin> list, bool isAsc){
    final res = UpperLower();

    if(list.isEmpty){
      return res;
    }

    DateTime lower = list[0].date!;
    DateTime upper = list[0].date!;

    for(final x in list){
      var c = DateHelper.compareDates(x.date, lower, asc: isAsc);

      if(c < 0){
        upper = x.date!;
      }

      c = DateHelper.compareDates(x.date, upper, asc: isAsc);

      if(c > 0){
        lower = x.date!;
      }
    }

    return UpperLower()..lower = lower..upper = upper;
  }*/
