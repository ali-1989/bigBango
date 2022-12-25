import 'package:app/pages/grammar_page.dart';
import 'package:app/pages/idioms_page.dart';
import 'package:app/pages/listening_page.dart';
import 'package:app/pages/reading_page.dart';
import 'package:app/structures/injectors/grammarPagesInjector.dart';
import 'package:app/structures/injectors/listeningPagesInjector.dart';
import 'package:app/structures/injectors/readingPagesInjector.dart';
import 'package:app/structures/injectors/vocabPagesInjector.dart';
import 'package:app/structures/models/courselevelModel.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/logger/logger.dart';
import 'package:iris_tools/api/logger/reporter.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:app/constants.dart';
import 'package:app/managers/settingsManager.dart';
import 'package:app/structures/mixin/dateFieldMixin.dart';
import 'package:app/structures/models/userModel.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appRoute.dart';

class PublicAccess {
  PublicAccess._();

  static late Logger logger;
  static late Reporter reporter;
  static String serverApi = SettingsManager.settingsModel.httpAddress;
  /// {id: 1, name: پایه, order: 1}, {id: 2, name: مبتدی, order: 2}, {id: 3, name: متوسط, order: 3}, {id: 4, name: پیشرفته, order: 4}
  static List<CourseLevelModel> courseLevels = [];
  /// login, determiningCourseLevel
  static Map advertisingVideos = {};
  /** "supportPhoneNumber": "031-32355205",
    "supportEmail": "support@bigbango.ir",
   "conditionTermsLink": "google.com",
   "description": "بیگ‌‌بنگو اپلیکیشن آموزش زبان"*/
  static Map contacts = {};
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

  static WidgetsBinding getAppWidgetsBinding() {
    return WidgetsBinding.instance;
  }

  static CourseLevelModel? getCourseLevelById(int id){
    for(final x in PublicAccess.courseLevels){
      if(x.id == id){
        return x;
      }
    }

    return null;
  }

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

  static void sortList(List<DateFieldMixin> list, bool isAsc){
    if(list.isEmpty){
      return;
    }

    int sorter(DateFieldMixin d1, DateFieldMixin d2){
      return DateHelper.compareDates(d1.date, d2.date, asc: isAsc);
    }

    list.sort(sorter);
  }

  static Map<String, dynamic> getHeartMap() {
    final heart = <String, dynamic>{
      'heart': 'Heart',
      //Keys.deviceId: DeviceInfoTools.deviceId,
      Keys.languageIso: System.getLocalizationsLanguageCode(AppRoute.getLastContext()!),
      'app_version_code': Constants.appVersionCode,
      'app_version_name': Constants.appVersionName,
      'app_name': Constants.appName,
    };

    final users = [];

    for(var um in Session.currentLoginList) {
      users.add(um.userId);
    }

    heart['users'] = users;

    return heart;
  }

  static Widget? getNextPart(LessonModel lessonModel){
    Widget? page;

    if(lessonModel.vocabModel != null && lessonModel.vocabModel!.hasIdioms){
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
}
///===================================================================================
class UpperLower {
  DateTime? upper;
  DateTime? lower;

  String? get upperAsTS => DateHelper.toTimestampNullable(upper);
  String? get lowerAsTS => DateHelper.toTimestampNullable(lower);
}
