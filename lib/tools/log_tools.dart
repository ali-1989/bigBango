import 'dart:async';
import 'dart:developer';

import 'package:app/managers/api_manager.dart';
import 'package:flutter/foundation.dart';

import 'package:iris_tools/api/logger/logger.dart';
import 'package:iris_tools/api/logger/reporter.dart';

import 'package:app/tools/app/appDirectories.dart';
import 'package:http/http.dart' as http;
import 'package:iris_tools/plugins/javaBridge.dart';


class LogTools {
  LogTools._();

  static late Logger logger;
  static late Reporter reporter;
  static JavaBridge? _errorBridge;

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

    _errorBridge!.init('error_handler', (call) async {
      if(call.method == 'report_error') {
        print('@@@@ error_handler:  ${call.arguments}');
        reportError(call.arguments);
      }

      return null;
    });
  }

  static void reportError(Map<String, dynamic> map) async {
    void fn(){
      final url = Uri.parse(ApiManager.errorReportApi);

      final body = {
        'data': map,
      };

      http.post(url, body: body);
    }

    runZonedGuarded(fn, (error, stack) {
      LogTools.logger.logToAll(error.toString());
    });
  }
}
