import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_notifier/iris_notifier.dart';

import 'package:app/managers/message_manager.dart';
import 'package:app/structures/structure/messageStateManager.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/views/pages/home_page.dart';
import 'package:app/views/pages/layout_page.dart';

class AppBroadcast {
  AppBroadcast._();

  static final StreamController<bool> viewUpdaterStream = StreamController<bool>();
  static final EventStateNotifier<MessageStateManager> messageNotifier = EventStateNotifier(MessageManager.messageStateManager);

  //---------------------- keys
  static const String drawerMenuRefresherId = 'drawerMenuRefresherId';
  static LocalKey materialAppKey = UniqueKey();
  static final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final layoutPageKey = GlobalKey<LayoutPageState>();
  static final homePageKey = GlobalKey<HomePageState>();
  static final addTicketNotifier = DataNotifierService.generateKey();

  //---------------------- status
  static bool isNetConnected = true;
  static bool isWsConnected = false;
  static bool messagePageIsOpen = false;


  /// this call build() method of all widgets
  /// this is effect on First Widgets tree, not rebuild Pushed pages
  static void reBuildMaterialBySetTheme() {
    AppThemes.applyTheme(AppThemes.instance.currentTheme);
    reBuildMaterial();
  }

  static void reBuildMaterial() {
    if(kIsWeb){
      materialAppKey = UniqueKey();
    }

    viewUpdaterStream.sink.add(true);
  }
}