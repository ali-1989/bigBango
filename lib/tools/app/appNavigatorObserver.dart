import 'dart:developer';

import 'package:app/pages/about_page.dart';
import 'package:app/tools/routeTools.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/api/stackList.dart';

import 'package:app/tools/app/appRouteNoneWeb.dart'
if (dart.library.html) 'package:app/tools/app/appRouteWeb.dart' as web;


class AppNavigatorObserver with NavigatorObserver  /*NavigatorObserver or RouteObserver*/ {
  static final AppNavigatorObserver _instance = AppNavigatorObserver._();
  static final StackList<String> _routeList = StackList();
  static final List<MapEntry<int, String>> _routeToLabel = [];
  static final List<WebRoute> webRoutes = [];
  static final String homeName = 'homePage';

  AppNavigatorObserver._();

  static AppNavigatorObserver instance(){
    return _instance;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if(route is! PageRoute){
      super.didPush(route, previousRoute);
      return;
    }

    /// AppBroadcast.rootNavigatorKey.currentState    <==>    route.navigator
    String? name = route.settings.name;

    /*Future.delayed(Duration(milliseconds: 1500), (){
        //final routes2 = AppNavigator.getAllModalRoutes$();
        final routes = AppNavigator.getAllModalRoutesByFocusScope();

        if(routes.length > 1){
          final last = routes.last;
          if(last.key is PageRoute) {}
        }
      });*/

    if(homeName == name){
      _routeList.clear();
      name = '/';
    }

    if(name == null){
      name = Generator.generateKey(10);
      _routeToLabel.add(MapEntry(route.hashCode, name));
    }

    super.didPush(route, previousRoute);

    _routeList.push(name);
    _changeAddressBar();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);

    if(route is! PageRoute){
      return;
    }

    _routeList.pop();
    _changeAddressBar();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);

    if(route is! PageRoute){
      return;
    }

    String? name = route.settings.name;

    if(name == null){
      for(final kv in _routeToLabel){
        if(kv.key == route.hashCode){
          _routeList.popUntil(kv.value);
        }
      }
    }
    else {
      _routeList.popUntil(name);
    }

    _changeAddressBar();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
   super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

   if(newRoute is! PageRoute){
     return;
   }

   String? name = newRoute.settings.name;

   if(newRoute.isFirst){
     _routeList.clear();
     name = '/';
     _routeList.push(name);
   }
   else {
     if(name == null){
       name = Generator.generateKey(10);
       _routeToLabel.add(MapEntry(newRoute.hashCode, name));
     }

     _routeList.pop();
     _routeList.push(name);
   }

   _changeAddressBar();
  }

  static Route? onUnknownRoute(RouteSettings settings) {
    return null;
  }

  static Route? onGenerateRoute(RouteSettings settings) {
    final w = WebRoute();
    w.routeName = 'aaa';
    w.builder = (){return AboutPage();};

    webRoutes.add(w);


    if(kIsWeb){
      if(_routeList.isEmpty && web.getCurrentWebAddress() != web.getBaseWebAddress()) {
        final address = web.getCurrentWebAddress();
        final lastPath = getLastPart(address);

        for(final i in webRoutes){
          if(i.routeName.toLowerCase() == lastPath.toLowerCase()){
            print('------------------- name: ${settings.name},  ${settings.arguments}');
            return MaterialPageRoute(
                builder: (ctx){
                  return i.builder();
                },
            settings: settings);
          }
        }
      }
    }

    return null;
  }

  static bool onPopPage(Route<dynamic> route, result) {
    return route.didPop(result);
  }

  void _changeAddressBar() {
    String url = '';

    for(final sec in _routeList.toList().skip(1)){
      url += '$sec/';
    }

    web.changeAddressBar(url);
  }

  static String getLastPart(String address){
    final split = address.split('/');

    if(split.length > 1){
      final last = split.last;

      int idxQuestionMark = last.indexOf('?');
      int idxSharpMark = last.indexOf('#');

      //int idx = MathHelper.minInt(idxQuestionMark, idxSharpMark);
      int idx = idxQuestionMark;

      if(idx < 0){
        idx = idxSharpMark;
      }

      if(idx > 0){
        return last.substring(0, idx);
      }

      return last;
    }

    return address;
  }
}



class WebRoute {
  late String routeName;
  late Widget Function() builder;
  String? routeAddress;
  bool show404OnInvalidAddress = false;
}
