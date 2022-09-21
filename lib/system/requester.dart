import 'package:app/system/httpProcess.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/publicAccess.dart';
import 'package:flutter/widgets.dart';

import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/logger/logger.dart';

import 'package:app/managers/settingsManager.dart';
import 'package:app/tools/app/appHttpDio.dart';
import 'package:app/tools/app/appSheet.dart';

///=============================================================================================
enum MethodType {
  post,
  get,
  put
}

enum RequestPath {
  getData,
  setData,
  others
}
///=============================================================================================
class Requester {
  Map<String, dynamic>? _bodyJs;
  MethodType methodType = MethodType.post;
  late HttpRequester _httpRequester;
  late HttpRequestEvents httpRequestEvents;
  late HttpItem _http;
  bool debug = false;

  Requester(){
    _prepareHttp();
    httpRequestEvents = HttpRequestEvents();
    _httpRequester = HttpRequester();
  }

  HttpItem get httpItem => _http;

  HttpRequester? get httpRequester => _httpRequester;

  Map<String, dynamic>? get bodyJson => _bodyJs;

  set bodyJson(Map<String, dynamic>? js) {
    _bodyJs = js;

    if(js != null) {
      PublicAccess.addAppInfo(_bodyJs!);
    }
  }

  void _prepareHttp(){
    _http = HttpItem();
    _http.setResponseIsPlain();
    _http.fullUrl = SettingsManager.settingsModel.httpAddress;
  }

  void prepareUrl({String? fullUrl, String? pathUrl}){
    if(fullUrl != null){
      _http.fullUrl = fullUrl;
      return;
    }

    pathUrl ??= '/graph-v1';

    if(!_http.fullUrl.contains(pathUrl)) {
      _http.fullUrl += pathUrl;
    }
  }

  void request([BuildContext? context, bool promptErrors = true]){
    _http.debugMode = debug;
    _http.method = methodType == MethodType.get ? 'GET': 'POST';

    /*if(_requestPath != RequestPath.Others) {
      _http.pathSection = _requestPath == RequestPath.GetData ? '/get-data' : '/set-data';
    }*/

    if(_bodyJs != null) {
      _http.body = JsonHelper.mapToJson(_bodyJs!);
    }

    AppHttpDio.cancelAndClose(_httpRequester);

    _httpRequester = AppHttpDio.send(_http);

    var f = _httpRequester.response.catchError((e){
      if(debug){
        Logger.L.logToScreen(' catchError --> $e');
      }

      if (_httpRequester.isDioCancelError){
        return _httpRequester.emptyResponse;
      }

      httpRequestEvents.onAnyState?.call(_httpRequester);
      httpRequestEvents.onFailState?.call(_httpRequester);
      httpRequestEvents.onNetworkError?.call(_httpRequester);
    });

    f = f.then((val) async {
      await httpRequestEvents.onAnyState?.call(_httpRequester);

      if(!_httpRequester.isOk){
        if(debug){
          Logger.L.logToScreen('>> Response receive, but is not ok | $val');
        }

        await httpRequestEvents.onFailState?.call(_httpRequester);
        await httpRequestEvents.onResponseError?.call(_httpRequester, false);
        return;
      }

      final Map? js = _httpRequester.getBodyAsJson();

      if (js == null) {
        if(debug){
          Logger.L.logToScreen('>> Response receive, but is not json | $val');
        }

        await httpRequestEvents.onFailState?.call(_httpRequester);
        await httpRequestEvents.onResponseError?.call(_httpRequester, true);
        return;
      }

      if(debug){
        Logger.L.logToScreen('status is 200 >> result : $js');
      }

      if(httpRequestEvents.manageResponse != null){
        await httpRequestEvents.manageResponse?.call(_httpRequester, js);
        return;
      }

      final result = Keys.error;

      if(result == Keys.ok) {
        await httpRequestEvents.onStatusOk?.call(_httpRequester, js);
      }
      else {
        await httpRequestEvents.onFailState?.call(_httpRequester);

        final cause = '';
        final causeCode = 0;
        final managedByUser = await httpRequestEvents.onStatusError?.call(_httpRequester, js, causeCode, cause)?? false;

        if(context != null) {
          if (!managedByUser && promptErrors && !HttpProcess.processCommonRequestError(context, js)) {
            await AppSheet.showSheet$ServerNotRespondProperly(context);
          }
        }
      }

      return null;
    });
  }

  void dispose(){
    AppHttpDio.cancelAndClose(_httpRequester);
  }
}
///================================================================================================
class HttpRequestEvents {
  Future Function(HttpRequester)? onAnyState;
  Future Function(HttpRequester)? onFailState;
  Future Function(HttpRequester)? onNetworkError;
  Future Function(HttpRequester, bool)? onResponseError;
  Future Function(HttpRequester, Map)? manageResponse;
  Future Function(HttpRequester, Map)? onStatusOk;
  Future<bool> Function(HttpRequester, Map, int?, String?)? onStatusError;
}
