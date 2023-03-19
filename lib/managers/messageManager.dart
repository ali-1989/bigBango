// ignore_for_file: empty_catches

import 'dart:core';

import 'package:app/structures/enums/appEventDispatcher.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/services/firebase_service.dart';
import 'package:app/structures/enums/messageStatus.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/messageModel.dart';
import 'package:app/structures/structure/messageStateStructure.dart';
import 'package:app/tools/app/appBadge.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appCache.dart';
import 'package:app/tools/deviceInfoTools.dart';

class MessageManager {
  MessageManager._();
  
  static final List<MessageModel> _messageList = [];
  static List<MessageModel> get messageList => _messageList;
  static MessageStateStructure messageStateStructure = MessageStateStructure();
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
      requestMessages();
    }
  }

  static void reset() async {
    _messageList.clear();
    pageIndex = 1;

    requestMessages();
  }

  static MessageModel? getById(String? id){
    try {
      return _messageList.firstWhere((element) => element.id == id);
    }
    catch(e){
      return null;
    }
  }

  static MessageModel addItem(MessageModel item){
    final existItem = getById(item.id);

    if(existItem == null) {
      _messageList.add(item);
      return item;
    }
    else {
      existItem.matchBy(item);
      return existItem;
    }
  }

  static List<MessageModel> addItemsFromMap(List? itemList, {String? domain}){
    final res = <MessageModel>[];

    if(itemList != null){
      for(final row in itemList){
        final itm = MessageModel.fromMap(row, /*domain: domain*/);
        addItem(itm);

        res.add(itm);
      }
    }

    return res;
  }

  static Future removeItem(String id/*, bool fromDb*/) async {
    _messageList.removeWhere((element) => element.id == id);
  }

  static void sortList(bool asc) async {
    _messageList.sort((MessageModel p1, MessageModel p2){
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
    _messageList.removeWhere((element) => !serverIds.contains(element.id));
  }

  static void requestMessages() async {
    if(AppBroadcast.messageNotifier.states.isInRequest){
      return;
    }

    AppBroadcast.messageNotifier.states.isInRequest = true;
    final requester = Requester();

    requester.httpRequestEvents.onAnyState = (req) async {
      requester.dispose();
    };

    requester.httpRequestEvents.onFailState = (req, res) async {
      AppBroadcast.messageNotifier.states.errorOccur();
    };

    requester.httpRequestEvents.onStatusOk = (req, dataJs) async {
      setUpdate();

      final List data = dataJs['data']?? [];
      final hasNextPage = dataJs['hasNextPage']?? true;
      pageIndex = dataJs['pageIndex']?? pageIndex;

      if(hasNextPage || data.length >= 100){
        pageIndex++;
      }

      AppBroadcast.messageNotifier.states.hasNextPage = hasNextPage;

      addItemsFromMap(data);
      sortList(true);

      AppBroadcast.messageNotifier.states.dataIsOk();
      AppBroadcast.messageNotifier.notify();
    };


    requester.prepareUrl(pathUrl: '/notifications?Page=$pageIndex&Size=100');
    requester.methodType = MethodType.get;
    requester.request(null, false);
  }

  static void requestUpdateMessageSeen(List<MessageModel> notifyList) async {
    final requester = Requester();

    requester.httpRequestEvents.onAnyState = (req) async {
      requester.dispose();
    };

    requester.httpRequestEvents.onStatusOk = (req, dataJs) async {
      for(final x in notifyList){
        x.status = MessageStatus.read;
      }
    };

    List<Map> ids = [];

    for(final x in notifyList){
      if(x.status == MessageStatus.unRead) {
        ids.add({'id': x.id, 'status': 2});
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
      EventNotifierService.addListener(EventDispatcher.networkConnected, _onNetConnected);
    };

    requester.httpRequestEvents.onFailState = (req, dataJs) async {
      if(AppCache.timeoutCache.addTimeout('requestUnReadCount', Duration(minutes: 1))){
        requestUnReadCount();
      }
    };

    requester.httpRequestEvents.onStatusOk = (req, dataJs) async {
      final data = dataJs['data'];
      final count = data['unreadCount']?? 0;

      AppBadge.setMessageBadge(count);
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
      EventNotifierService.addListener(EventDispatcher.networkConnected, _onNetConnected);
    };

    requester.httpRequestEvents.onFailState = (req, dataJs) async {
      if(AppCache.timeoutCache.addTimeout('requestSetFirebaseToken', Duration(minutes: 1))){
        requestSetFirebaseToken();
      }
    };

    requester.httpRequestEvents.onStatusOk = (req, dataJs) async {
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
    EventNotifierService.removeListener(EventDispatcher.networkConnected, _onNetConnected);
    requestUnReadCount();
    requestSetFirebaseToken();
  }
}
