import 'package:flutter/material.dart';

import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/pages/layout_page.dart';
import 'package:app/pages/phone_number_page.dart';
import 'package:app/pages/register_form_page.dart';
import 'package:app/pages/select_language_level_page.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appDb.dart';

class RouteDispatcher {
  RouteDispatcher._();

  static Widget dispatch(){

    if(Session.hasAnyLogin()){
      System.showBothStatusBar();

      final user = Session.getLastLoginUser()!;

      if(user.courseLevel == null){
        return SelectLanguageLevelPage();
      }

      return LayoutPage(key: AppBroadcast.layoutPageKey);
    }

    final pNumber = AppDB.fetchKv(Keys.setting$registerPhoneNumber);

    if(pNumber != null){
      final ts = AppDB.fetchKv(Keys.setting$registerPhoneNumberTs);

      if(ts != null && !DateHelper.isPastOf(DateHelper.tsToSystemDate(ts), Duration(minutes: 10))) {
        return RegisterFormPage(phoneNumber: pNumber);
      }
    }

    return PhoneNumberPage();
  }
}
