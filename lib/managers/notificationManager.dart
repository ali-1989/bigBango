// ignore_for_file: empty_catches
import 'dart:core';

import 'package:app/services/event_dispatcher_service.dart';
import 'package:app/services/firebase_service.dart';
import 'package:app/structures/enums/notificationStatus.dart';
import 'package:app/structures/models/notificationModel.dart';
import 'package:app/structures/structure/notificationStateStructure.dart';
import 'package:app/tools/app/appBadge.dart';
import 'package:app/tools/app/appCache.dart';
import 'package:app/tools/deviceInfoTools.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/structures/middleWare/requester.dart';
import 'package:app/tools/app/appBroadcast.dart';

class NotificationManager {
  NotificationManager._();
  
  static final List<NotificationModel> _notificationList = [];
  static List<NotificationModel> get notificationList => _notificationList;
  static NotificationStateStructure notificationStateStructure = NotificationStateStructure();
  static int pageIndex = 1;
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
      requestNotification();
    }
  }

  static void reset() async {
    _notificationList.clear();
    pageIndex = 1;

    requestNotification();
  }

  static NotificationModel? getById(String? id){
    try {
      return _notificationList.firstWhere((element) => element.id == id);
    }
    catch(e){
      return null;
    }
  }

  static NotificationModel addItem(NotificationModel item){
    final existItem = getById(item.id);

    if(existItem == null) {
      _notificationList.add(item);
      return item;
    }
    else {
      existItem.matchBy(item);
      return existItem;
    }
  }

  static List<NotificationModel> addItemsFromMap(List? itemList, {String? domain}){
    final res = <NotificationModel>[];

    if(itemList != null){
      for(final row in itemList){
        final itm = NotificationModel.fromMap(row, /*domain: domain*/);
        addItem(itm);

        res.add(itm);
      }
    }

    return res;
  }

  static Future removeItem(String id/*, bool fromDb*/) async {
    _notificationList.removeWhere((element) => element.id == id);
  }

  static void sortList(bool asc) async {
    _notificationList.sort((NotificationModel p1, NotificationModel p2){
      final d1 = p1.createAt;
      final d2 = p2.createAt;

      /*if(d1 == null){
        return asc? 1: 1;
      }

      if(d2 == null){
        return asc? 1: 1;
      }*/

      return asc? d1.compareTo(d2) : d2.compareTo(d1);
    });
  }

  static Future removeNotMatchByServer(List<String> serverIds) async {
    _notificationList.removeWhere((element) => !serverIds.contains(element.id));
  }


  static void requestNotification() async {
    if(AppBroadcast.notifyMessageNotifier.states.isInRequest){
      return;
    }

    AppBroadcast.notifyMessageNotifier.states.isInRequest = true;
    final requester = Requester();

    requester.httpRequestEvents.onAnyState = (req) async {
      requester.dispose();
    };

    requester.httpRequestEvents.onFailState = (req, res) async {
      AppBroadcast.notifyMessageNotifier.states.errorOccur();
    };

    requester.httpRequestEvents.onStatusOk = (req, dataJs) async {
      setUpdate();

      final List data = dataJs['data']?? [];
      final hasNextPage = dataJs['hasNextPage']?? true;
      pageIndex = dataJs['pageIndex']?? pageIndex;

      if(hasNextPage || data.length >= 100){
        pageIndex++;
      }

      AppBroadcast.notifyMessageNotifier.states.hasNextPage = hasNextPage;

      addItemsFromMap(data);
      addItem(NotificationModel()..id = 'a'..title = 'خرید درس'..body = 'سلام چطوری'..createAt = DateTime.now());
      addItem(NotificationModel()..id = 'b'..title = 'برداشت پول'..body = 'خرید شما انجام شد'..createAt = DateTime.now());

      AppBroadcast.notifyMessageNotifier.states.dataIsOk();
      AppBroadcast.notifyMessageNotifier.notify();
    };


    requester.prepareUrl(pathUrl: '/notifications?Page=$pageIndex&Size=100');
    requester.methodType = MethodType.get;
    requester.request(null, false);
  }

  static void requestUpdateNotification(List<NotificationModel> notifyList) async {
    final requester = Requester();

    requester.httpRequestEvents.onAnyState = (req) async {
      requester.dispose();
    };

    requester.httpRequestEvents.onStatusOk = (req, dataJs) async {
      for(final x in notifyList){
        x.status = NotificationStatus.read;
      }
    };

    List<Map> ids = [];

    for(final x in notifyList){
      if(x.status == NotificationStatus.unRead) {
        ids.add({'id': x.id, 'status': 1});
      }
    }

    final js = <String, dynamic>{};
    js['items'] = ids;

    requester.prepareUrl(pathUrl: '/notifications/update');
    requester.methodType = MethodType.put;
    requester.bodyJson = js;
    requester.request(null, false);
  }

  static void requestUnReadCount() async {
    final requester = Requester();

    requester.httpRequestEvents.onAnyState = (req) async {
      requester.dispose();
    };

    requester.httpRequestEvents.onNetworkError = (req) async {
      EventDispatcherService.attachFunction(EventDispatcher.networkConnected, _onNetConnected);
    };

    requester.httpRequestEvents.onFailState = (req, dataJs) async {
      if(AppCache.timeoutCache.addTimeout('requestUnReadCount', Duration(minutes: 1))){
        requestUnReadCount();
      }
    };

    requester.httpRequestEvents.onStatusOk = (req, dataJs) async {
      final data = dataJs['data'];
      final count = data['unreadCount'];

      AppBadge.setNotifyMessageBadge(count);
      AppBadge.refreshViews();
    };


    requester.prepareUrl(pathUrl: '/notifications/count');
    requester.methodType = MethodType.get;
    requester.request(null, false);
  }

  static void requestSetFirebaseToken() async {
    if(FireBaseService.token == null){
      return;
    }

    final requester = Requester();

    requester.httpRequestEvents.onAnyState = (req) async {
      requester.dispose();
    };

    requester.httpRequestEvents.onNetworkError = (req) async {
      EventDispatcherService.attachFunction(EventDispatcher.networkConnected, _onNetConnected);
    };

    requester.httpRequestEvents.onFailState = (req, dataJs) async {
      if(AppCache.timeoutCache.addTimeout('requestSetFirebaseToken', Duration(minutes: 1))){
        requestSetFirebaseToken();
      }
    };

    requester.httpRequestEvents.onStatusOk = (req, dataJs) async {
      final data = dataJs['data'];
      final count = data['unreadCount'];

      AppBadge.setNotifyMessageBadge(count);
      AppBadge.refreshViews();
    };

    final js = <String, dynamic>{};
    js['clientSecret'] = DeviceInfoTools.deviceId;
    js['token'] = FireBaseService.token;

    requester.prepareUrl(pathUrl: '/messagingDevices/add');
    requester.methodType = MethodType.post;
    requester.bodyJson = js;
    requester.request(null, false);
  }

  static void _onNetConnected({data}) {
    EventDispatcherService.deAttachFunction(EventDispatcher.networkConnected, _onNetConnected);
    requestUnReadCount();
    requestSetFirebaseToken();
  }
}
