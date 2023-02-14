// ignore_for_file: empty_catches

import 'dart:core';

import 'package:app/structures/models/notificationModel.dart';
import 'package:iris_pic_editor/picEditor/state_manager.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';


import 'package:app/structures/middleWare/requester.dart';
import 'package:app/tools/app/appBroadcast.dart';

class NotificationManager {
  NotificationManager._();
  
  static final List<NotificationModel> _notificationList = [];
  static List<NotificationModel> get notificationList => _notificationList;
  static int page = 1;
  static bool isRequested = false;
  static bool isInRequest = false;
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

  /*static void sortList(bool asc) async {
    _notificationList.sort((NotificationModel p1, NotificationModel p2){
      final d1 = p1.date;
      final d2 = p2.date;

      if(d1 == null){
        return asc? 1: 1;
      }

      if(d2 == null){
        return asc? 1: 1;
      }

      return asc? d1.compareTo(d2) : d2.compareTo(d1);
    });
  }*/

  static Future removeNotMatchByServer(List<String> serverIds) async {
    _notificationList.removeWhere((element) => !serverIds.contains(element.id));
  }


  static Future requestNotification() async {
    final requester = Requester();

    requester.httpRequestEvents.onAnyState = (req) async {
      requester.dispose();
      isRequested = true;
      isInRequest = false;
    };

    requester.httpRequestEvents.onStatusOk = (req, dataJs) async {
      lastUpdateTime = DateHelper.getNowToUtc();

      final data = dataJs['data'];

      addItemsFromMap(data);

      AssistController.commonUpdateAssist(AppBroadcast.assistId$notificationPage);
    };

    isInRequest = true;
    requester.prepareUrl(pathUrl: '/notifications?Page=$page&Size=100');
    requester.methodType = MethodType.get;
    requester.request(null, false);
  }
}
