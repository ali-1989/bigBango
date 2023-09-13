import 'dart:core';

import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/structures/enums/app_events.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/tools/app/app_badge.dart';
import 'package:app/tools/app/app_cache.dart';

class LeitnerManager {
  LeitnerManager._();

  ///-----------------------------------------------------------------------------------------
  static DateTime? _lastUpdateTime;

  static bool isUpdated({Duration duration = const Duration(minutes: 30)}) {
    var now = DateTime.now();
    now = now.subtract(duration);

    return _lastUpdateTime != null && _lastUpdateTime!.isAfter(now);
  }

  static void setUpdate({DateTime? dt}) {
    _lastUpdateTime = dt?? DateHelper.getNowToUtc();
  }

  static void setUnUpdate() {
    _lastUpdateTime = null;
  }
  ///-----------------------------------------------------------------------------------------
  static void init() async {
    check();
  }

  static void check() async {
    if(_lastUpdateTime == null || DateHelper.isPastOf(_lastUpdateTime, Duration(minutes: 29))){
      requestLeitnerCount();
    }
  }

  static void reset() async {
    requestLeitnerCount();
  }

  static void requestLeitnerCount() async {
    final requester = Requester();

    requester.httpRequestEvents.onAnyState = (req) async {
      requester.dispose();
    };

    requester.httpRequestEvents.onNetworkError = (req) async {
      EventNotifierService.addListener(AppEvents.networkConnected, _onNetConnected);
    };

    requester.httpRequestEvents.onFailState = (req, dataJs) async {
      if(AppCache.timeoutCache.addTimeout('requestLeitnerCount', const Duration(minutes: 1))){
        requestLeitnerCount();
      }
    };

    requester.httpRequestEvents.onStatusOk = (req, dataJs) async {
      final data = dataJs['data'];
      final count = data['count']?? 0;

      setUpdate();
      AppBadge.setLeitnerBadge(count);
      AppBadge.refreshViews();
    };


    requester.prepareUrl(pathUrl: '/leitner/count');
    requester.methodType = MethodType.get;
    requester.request(null, false);
  }

  static void _onNetConnected({data}) {
    EventNotifierService.removeListener(AppEvents.networkConnected, _onNetConnected);
    requestLeitnerCount();
  }
}
