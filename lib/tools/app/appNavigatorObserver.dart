import 'package:app/stack.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:flutter/material.dart' hide stack;

import 'package:app/tools/app/appRouteNoneWeb.dart'
if (dart.library.html) 'package:app/tools/app/appRouteWeb.dart' as web;

class AppNavigatorObserver with NavigatorObserver  /* NavigatorObserver or RouteObserver*/ {
  static final AppNavigatorObserver _instance = AppNavigatorObserver._();
  static final StackList<String> _routeList = StackList();

  AppNavigatorObserver._();

  static AppNavigatorObserver instance(){
    return _instance;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    if(route is! PageRoute){
      return;
    }

    /// AppBroadcast.rootNavigatorKey.currentState    <==>    route.navigator
    String? name = route.settings.name;

    //final ww = AppNavigator.getRootNavigator(route.navigator!.context);
    //final ww2 = AppNavigator.getNearestNavigator(route.navigator!.context);

    if(route.isFirst){
      _routeList.clear();
      name = '/';
    }
    else {
      final root = AppNavigator.getRootNavigator$();
      print('============== ddddeeeeppp :${route.navigator}');
    }

    _routeList.push(name!);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _routeList.pop();

    web.clearAddressBar(route.settings.name);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _routeList.popUntil(previousRoute?.settings.name?? '');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
   super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

   _routeList.pop();
   _routeList.push(newRoute?.settings.name?? '');
  }

  static Route? onUnknownRoute(RouteSettings settings) {
    return null;
  }

  static Route? onGenerateRoute(RouteSettings settings) {
    return null;
  }

  static bool onPopPage(Route<dynamic> route, result) {
    return route.didPop(result);
  }
}
