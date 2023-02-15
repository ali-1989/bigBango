// ignore_for_file: empty_catches
import 'dart:core';

import 'package:app/structures/models/notificationModel.dart';
import 'package:app/structures/structure/notificationStateStructure.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/structures/middleWare/requester.dart';
import 'package:app/tools/app/appBroadcast.dart';

class NotificationManager {
  NotificationManager._();
  
  static final List<NotificationModel> _notificationList = [];
  static List<NotificationModel> get notificationList => _notificationList;
  static int pageIndex = 1;
  static NotificationStateStructure notificationStateStructure = NotificationStateStructure();
  ///-----------------------------------------------------------------------------------------
  static DateTime? lastUpdateTime;

  static void init() async {
    check();
  }

  static void check() async {
    await Future.delayed(Duration(seconds: 8), (){}); // for avoid call fast after init
    if(lastUpdateTime == null || DateHelper.isPastOf(lastUpdateTime, Duration(minutes: 29))){
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
      lastUpdateTime = DateHelper.getNowToUtc();

      final List data = dataJs['data']?? [];
      final hasNextPage = dataJs['hasNextPage']?? true;
      pageIndex = dataJs['pageIndex']?? pageIndex;

      if(hasNextPage || data.length >= 100){
        pageIndex++;
      }

      AppBroadcast.notifyMessageNotifier.states.hasNextPage = hasNextPage;

      addItemsFromMap(data);
      addItem(NotificationModel()..id = 'a'..title = 'title'..body = 'ffgg ffggf fgffg'..createAt = DateTime.now());

      AppBroadcast.notifyMessageNotifier.states.dataIsOk();
      AppBroadcast.notifyMessageNotifier.notify();
    };


    requester.prepareUrl(pathUrl: '/notifications?Page=$pageIndex&Size=100');
    requester.methodType = MethodType.get;
    requester.request(null, false);
  }
}
