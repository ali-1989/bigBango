import 'package:flutter/material.dart';

import 'package:iris_tools/dateSection/calendarTools.dart';

import 'package:app/managers/fontManager.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/dateTools.dart';

class SettingsModel {
  static const defaultHttpAddress = 'https://bigbangoappapi.nicode.org/v1';
  static const defaultWsAddress = 'https://bigbangoappapi.nicode.org/v1';
  static const defaultProxyAddress = '95.174.67.50:18080';
  static const Locale defaultAppLocale = Locale('fa', 'IR');
  static final CalendarType defaultCalendarType = CalendarType.solarHijri;
  static final defaultDateFormat = DateFormat.yyyyMmDd.format();
  static int webSocketPeriodicHeartMinutes = 3;
  static int drawerMenuTimeMill = 350;
  static int maxCoverWidth = 180;
  static int maxCoverHeightL = 120;
  static int maxCoverHeightP = 240;
  static int maxViewWidth = 380;
  static int maxViewHeightL = 200;
  static int maxViewHeightP = 460;

  String? lastUserId;
  //String? currentRouteScreen;
  Locale appLocale = defaultAppLocale;
  CalendarType calendarType = defaultCalendarType;
  String dateFormat = defaultDateFormat;
  String? colorTheme;
  String? appPatternKey;
  String? lastToBackgroundTs;
  bool confirmOnExit = true;
  String httpAddress = defaultHttpAddress;
  String wsAddress = defaultWsAddress;
  String proxyAddress = defaultProxyAddress;
  Orientation? appRotationState; // null: free
  int? currentVersion;
  


  SettingsModel(){
    //currentRouteScreen = RoutesName.homePage;
  }

  SettingsModel.fromMap(Map map){
    final localeMap = map['app_locale'];

    if(localeMap != null){
      appLocale = Locale(localeMap[Keys.languageIso], localeMap[Keys.countryIso]);
    }

    lastUserId = map['last_user_id'];
    calendarType = CalendarTypeHelper.calendarTypeFrom(map['calendar_type_name']);
    dateFormat = map['date_format']?? defaultDateFormat;
    colorTheme = map[Keys.setting$colorThemeName];
    //appPatternKey = map[Keys.setting$patternKey];
    //lastToBackgroundTs = map[Keys.setting$toBackgroundTs];
    confirmOnExit = map[Keys.setting$confirmOnExit]?? true;
    httpAddress = map['http_address']?? defaultHttpAddress;
    wsAddress = map['ws_address']?? defaultWsAddress;
    proxyAddress = map['proxy_address']?? defaultProxyAddress;
    currentVersion = map[Keys.setting$currentVersion];

    _prepareSettings();
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map['last_user_id'] = lastUserId;
    map['app_locale'] = {Keys.languageIso: appLocale.languageCode, Keys.countryIso: appLocale.countryCode};
    map['calendar_type_name'] = calendarType.name;
    map['date_format'] = dateFormat;
    map[Keys.setting$colorThemeName] = colorTheme;
    map[Keys.setting$confirmOnExit] = confirmOnExit;
    map[Keys.setting$currentVersion] = currentVersion;
    map['http_address'] = httpAddress;
    map['ws_address'] = wsAddress;
    map['proxy_address'] = proxyAddress;
    //map[Keys.setting$patternKey] = appPatternKey;
    //map[Keys.setting$toBackgroundTs] = lastToBackgroundTs;

    return map;
  }

  void matchBy(SettingsModel other){
    lastUserId = other.lastUserId;
    appLocale = other.appLocale;
    calendarType = other.calendarType;
    dateFormat = other.dateFormat;
    colorTheme = other.colorTheme;
    confirmOnExit = other.confirmOnExit;
    appPatternKey = other.appPatternKey;
    lastToBackgroundTs = other.lastToBackgroundTs;
    httpAddress = other.httpAddress;
    wsAddress = other.wsAddress;
    proxyAddress = other.proxyAddress;
  }

  void _prepareSettings() {
    //final locale = System.getCurrentLocalizationsLocale(context);
    //settingsModel.lastUserId ??= Session.getLastLoginUser()?.id;
    colorTheme ??= AppThemes.instance.currentTheme.themeName;

    FontManager.fetchFontThemeData(appLocale.languageCode);

    if(AppThemes.instance.currentTheme.themeName != colorTheme) {
      for (var t in AppThemes.instance.themeList.entries) {
        if (t.key == colorTheme) {
          AppThemes.applyTheme(t.value);
          break;
        }
      }
    }
  }

  @override
  String toString(){
    return toMap().toString();
  }
}
