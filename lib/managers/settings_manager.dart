import 'dart:async';

import 'package:dio/dio.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/system.dart';

import 'package:app/managers/api_manager.dart';
import 'package:app/managers/font_manager.dart';
import 'package:app/managers/version_manager.dart';
import 'package:app/structures/enums/app_events.dart';
import 'package:app/structures/models/courseLevelModel.dart';
import 'package:app/structures/models/global_settings_model.dart';
import 'package:app/structures/models/settings_model.dart';
import 'package:app/structures/models/version_model.dart';
import 'package:app/system/constants.dart';
import 'package:app/tools/app/app_cache.dart';
import 'package:app/tools/app/app_db.dart';
import 'package:app/tools/app/app_http_dio.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/route_tools.dart';
import '/system/keys.dart';

class SettingsManager {
	SettingsManager._();

	static late final SettingsModel _localSettings;
	static late final GlobalSettingsModel _globalSettings;
	static bool _isInit = false;

	static void init(){
		if(_isInit){
			return;
		}

		_isInit = true;
		loadSettings();
		_prepareSettings();
		EventNotifierService.addListener(AppEvents.networkConnected, _netListener);
	}

	static void _netListener({data}) {
		requestGlobalSettings();
	}

	static SettingsModel get localSettings {
		init();

		return _localSettings;
	}

  static GlobalSettingsModel get globalSettings {
		init();

		return _globalSettings;
	}

	static void _prepareSettings() {
		FontManager.fetchFontThemeData(_localSettings.appLocale.languageCode);

		if(AppThemes.instance.currentTheme.themeName != _localSettings.colorTheme) {
			for (final t in AppThemes.instance.themeList.entries) {
				if (t.key == _localSettings.colorTheme) {
					AppThemes.applyTheme(t.value);
					break;
				}
			}
		}
	}

	static void loadSettings() {
		_isInit = true;
		final local = AppDB.fetchKv(Keys.setting$appSettings);
		final global = AppDB.fetchKv(Keys.setting$globalSettings);

		if (local == null) {
			_localSettings = SettingsModel();
			_localSettings.colorTheme ??= AppThemes.instance.currentTheme.themeName;
			saveLocalSettingsAndNotify(notify: false);
		}
		else {
			_localSettings = SettingsModel.fromMap(local);
		}

		if (global == null) {
			_globalSettings = GlobalSettingsModel();
			saveGlobalSettingsAndNotify(notify: false);
		}
		else {
			_globalSettings = GlobalSettingsModel.fromMap(global);
		}
	}

	static Future<void> saveLocalSettingsAndNotify({int delaySec = 0, bool notify = true}) async {
		if(delaySec > 0){
			await Future.delayed(Duration(seconds: delaySec));
		}

		await AppDB.setReplaceKv(Keys.setting$appSettings, _localSettings.toMap());

		if(notify) {
			EventNotifierService.notify(SettingsEvents.localSettingsChange);
		}

		return;
	}

	static Future<void> saveGlobalSettingsAndNotify({int delaySec = 0, bool notify = true}) async {
		if(delaySec > 0){
			await Future.delayed(Duration(seconds: delaySec));
		}

		await AppDB.setReplaceKv(Keys.setting$globalSettings, _globalSettings.toMap());

		if(notify) {
			EventNotifierService.notify(SettingsEvents.globalSettingsChange);
		}

		return;
	}

	static Future<GlobalSettingsModel?> requestGlobalSettings() async {
		if(!AppCache.canCallMethodAgain('requestGlobalSettings')){
			return _globalSettings;
		}

		final http = HttpItem();
		final result = Completer<GlobalSettingsModel?>();

		var os = 1;

		if(System.isIOS()){
			os = 2;
		}

		http.fullUrl = '${ApiManager.serverApi}/primitiveOptions?CurrentVersion=${Constants.appVersionName}&OperationSystem=$os';
		http.method = 'GET';

		final request = AppHttpDio.send(http);

		var f = request.response.catchError((e){
			result.complete(null);
			return null;
		});

		f = f.then((Response? response){
			if(response == null || response.statusCode == null) {
				result.complete(null);
				return;
			}

			final js = JsonHelper.jsonToMap(response.data);
			final data = js?['data']?? {};

			final temp = GlobalSettingsModel.fromMap(data);
			globalSettings.matchBy(temp);

			/*
      test VersionModel versionModel = VersionModel();
      versionModel.directLink = 'http://google.com';
      versionModel.restricted = false;
      versionModel.newVersionName = '2.0.1';
      */

			final versionModel = VersionModel.fromMap(globalSettings.version);
			VersionManager.checkAppHasNewVersion(RouteTools.getTopContext()!, versionModel);

			result.complete(globalSettings);
			return null;
		});

		return result.future;
	}

	static CourseLevelModel? getCourseLevelById(int id){
		for(final x in globalSettings.courseLevels){
			if(x.id == id){
				return x;
			}
		}

		return null;
	}

	static double getAmountOf1Minutes(){
		if(globalSettings.timeTable.isEmpty){
			return 0;
		}

		return globalSettings.timeTable['minuteAmount']?? 0;
	}
}

enum SettingsEvents implements EventImplement {
	localSettingsChange(4),
	globalSettingsChange(5);

	final int _number;

	const SettingsEvents(this._number);

	int getNumber(){
		return _number;
	}
}


