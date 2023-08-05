import 'dart:async';
import 'dart:developer';

import 'package:app/services/session_service.dart';
import 'package:app/tools/deviceInfoTools.dart';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/logger/logger.dart';
import 'package:iris_tools/api/logger/reporter.dart';
import 'package:iris_tools/plugins/javaBridge.dart';

import 'package:app/managers/api_manager.dart';
import 'package:app/tools/app/appDirectories.dart';

class LogTools {
  LogTools._();

  static late Logger logger;
  static late Reporter reporter;
  static JavaBridge? _errorBridge;
  static JavaBridge? assistanceBridge;

  static Future<bool> init() async {
    try {
      if (!kIsWeb) {
        LogTools.reporter = Reporter(AppDirectories.getExternalAppFolder(), 'report');
      }

      LogTools.logger = Logger('${AppDirectories.getExternalTempDir()}/logs');

      initErrorReport();
      return true;
    }
    catch (e){
      log('$e\n\n${StackTrace.current}');
      return false;
    }
  }

  static void initErrorReport(){
    if(_errorBridge != null){
      return;
    }

    _errorBridge = JavaBridge();
    assistanceBridge = JavaBridge();

    _errorBridge!.init('error_handler', (call) async {
      if(call.method == 'report_error') {
        print('::::::::::::::::::: error_report recive:  ${call.arguments}');
        reportError(call.arguments);
      }

      return null;
    });

    assistanceBridge!.init('assistance', (call) async {
      /**/

      return null;
    });
  }

  static void reportError(Map<String, dynamic> map) async {
    void fn(){
      final url = Uri.parse(ApiManager.errorReportApi);

      final body = {
        'data': map,
        'device_id': DeviceInfoTools.deviceId,
      };

      if(SessionService.hasAnyLogin()){
        body['user_id'] = SessionService.getLastLoginUser()?.userId;
      }

      http.post(url, body: JsonHelper.mapToJson(body));
    }

    runZonedGuarded(fn, (error, stack) {
      LogTools.logger.logToAll('::::::::::::: report ::::::::::: ${error.toString()}');
    });
  }
}


/*
echo
echo_arg
throw_error
set_kv
get_kv
setAppIsRun
isAppRun
dismiss_notification
move_app_to_back
 */