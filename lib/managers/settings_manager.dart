import 'dart:async';

import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/system.dart';

import 'package:app/system/constants.dart';
import 'package:app/managers/api_manager.dart';
import 'package:app/managers/version_manager.dart';
import 'package:app/structures/enums/app_events.dart';
import 'package:app/structures/models/courseLevelModel.dart';
import 'package:app/structures/models/global_settings_model.dart';
import 'package:app/structures/models/settings_model.dart';
import 'package:app/structures/models/version_model.dart';
import 'package:app/tools/app/app_db.dart';
import 'package:app/tools/app/app_http_dio.dart';
import 'package:app/tools/route_tools.dart';
import '/system/keys.dart';

class SettingsManager {
	SettingsManager._();

	static late final SettingsModel _localSettings;
	static final GlobalSettingsModel _globalSettings = GlobalSettingsModel();
	static bool _isInit = false;
	static final List<VoidCallback> _localSettingsListeners = [];

	static void init(){
		if(_isInit){
			return;
		}

		loadSettings();
		EventNotifierService.addListener(AppEvents.networkConnected, _listener);
	}

	static void _listener({data}) {
		requestGlobalSettings();
	}

	static SettingsModel get localSettings {
		if(!_isInit){
			loadSettings();
		}

		return _localSettings;
	}

  static GlobalSettingsModel get globalSettings {
		return _globalSettings;
	}

  static void addListeners(VoidCallback fn) {
		if(!_localSettingsListeners.contains(fn)) {
		  _localSettingsListeners.add(fn);
		}
  }

	static void removeListeners(VoidCallback fn){
		_localSettingsListeners.remove(fn);
	}

	static void notify({BuildContext? context}){
		//context ??= RouteTools.getContext();
		Future((){
			for(final fun in _localSettingsListeners){
				try{
					fun();
				}
				catch(e){/**/}
			}
		});
	}
	///===================================================================================
	static bool loadSettings() {
		if(!_isInit) {
			_isInit = true;
			final res = AppDB.fetchKv(Keys.setting$appSettings);

			if (res == null) {
				_localSettings = SettingsModel();
				saveSettings();
			}
			else {
				_localSettings = SettingsModel.fromMap(res);
			}
		}

		return true;
	}

	static Future<bool> saveSettings({BuildContext? context, bool delay = false}) async {
		if(delay){
			await Future.delayed(const Duration(seconds: 1));
		}

		final res = await AppDB.setReplaceKv(Keys.setting$appSettings, _localSettings.toMap());

		notify(context: (context?.mounted?? false)? context : null);

		return res > 0;
	}

	static Future<GlobalSettingsModel?> requestGlobalSettings() async {
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

