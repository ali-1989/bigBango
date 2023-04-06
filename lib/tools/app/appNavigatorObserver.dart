import 'package:app/stack.dart';
import 'package:flutter/material.dart';
import 'package:app/pages/about_page.dart';
import 'package:app/pages/exam_page.dart';
import 'package:app/pages/grammar_page.dart';
import 'package:app/pages/layout_page.dart';
import 'package:app/pages/otp_page.dart';
import 'package:app/pages/phone_number_page.dart';
import 'package:app/pages/profile_page.dart';
import 'package:app/pages/reading_page.dart';
import 'package:app/pages/register_form_page.dart';
import 'package:app/pages/support_page.dart';
import 'package:app/pages/transaction_page.dart';
import 'package:app/pages/vocab_page.dart';
import 'package:app/pages/wallet_page.dart';

import 'package:app/tools/app/appRouteNoneWeb.dart'
if (dart.library.html) 'package:app/tools/app/appRouteWeb.dart' as web;
import 'package:iris_tools/api/generator.dart';

class AppNavigatorObserver with NavigatorObserver  /* NavigatorObserver or RouteObserver*/ {
  static final AppNavigatorObserver _instance = AppNavigatorObserver._();
  static final StackList<String> _routeList = StackList();
  static final List<MapEntry<int, String>> _routeToLabel = [];
  static final Map<Type, String?> webRoutes = {};

  AppNavigatorObserver._();

  static void init() {
    /*if(_isInit){
      return;
    }*/

    webRoutes[LayoutPage] = null;
    webRoutes[AboutPage] = null;
    webRoutes[ExamPage] = null;
    webRoutes[GrammarPage] = null;
    webRoutes[PhoneNumberPage] = null;
    webRoutes[ProfilePage] = null;
    webRoutes[RegisterFormPage] = null;
    webRoutes[WalletPage] = null;
    webRoutes[VocabPage] = null;
    webRoutes[TransactionsPage] = null;
    webRoutes[SupportPage] = null;
    webRoutes[ReadingPage] = null;
    webRoutes[OtpPage] = null;

    //_isInit = true;
  }

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

    if(route.isFirst){
      _routeList.clear();
      name = '/';
    }
    else {
      /*Future.delayed(Duration(milliseconds: 1500), (){
        //final routes2 = AppNavigator.getAllModalRoutes$();
        final routes = AppNavigator.getAllModalRoutesByFocusScope();

        if(routes.length > 1){
          final last = routes.last;
          if(last.key is PageRoute) {}
        }
      });*/
      if(name == null){
        name = Generator.generateKey(10);
        _routeToLabel.add(MapEntry(route.hashCode, name));
      }
    }

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
}
