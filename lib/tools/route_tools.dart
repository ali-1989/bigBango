import 'package:flutter/material.dart';

import 'package:iris_route/iris_route.dart';
import 'package:iris_tools/api/stack_list.dart';

import 'package:app/tools/app/app_navigator.dart';
import 'package:app/views/pages/about_page.dart';
import 'package:app/views/pages/home_page.dart';
import 'package:app/views/pages/support_page.dart';
import 'package:app/views/pages/wallet_page.dart';

class RouteTools {
  static BuildContext? materialContext;
  static final StackList<State> widgetStateStack = StackList();

  RouteTools._();

  static prepareRoutes(){
    final aboutPage = IrisPageRoute.by((AboutPage).toString(), AboutPage());
    final homePage = IrisPageRoute.by((HomePage).toString(), HomePage());
    final supportPage = IrisPageRoute.by((SupportPage).toString(), SupportPage());
    final walletPage = IrisPageRoute.by((WalletPage).toString(), WalletPage());

    //final registerFormPage = WebRoute.by((RegisterFormPage).toString(), RegisterFormPage());
    //final profilePage = WebRoute.by((ProfilePage).toString(), ProfilePage());

    IrisNavigatorObserver.notFoundHandler = (settings) => null;
    IrisNavigatorObserver.allAppRoutes.add(aboutPage);
    IrisNavigatorObserver.allAppRoutes.add(homePage);
    IrisNavigatorObserver.allAppRoutes.add(supportPage);
    IrisNavigatorObserver.allAppRoutes.add(walletPage);
    IrisNavigatorObserver.homeName = homePage.routeName;
  }

  static void addWidgetState(State state){
    return widgetStateStack.push(state);
  }

  static State removeWidgetState(){
    return widgetStateStack.pop();
  }

  static State getTopWidgetState(){
    return widgetStateStack.top();
  }

  static BuildContext? getTopContext() {
    var res = WidgetsBinding.instance.focusManager.rootScope.focusedChild?.context;//deep: 50,66

    Navigator? nav1 = res?.findAncestorWidgetOfExactType();

    if(res == null || nav1 == null) {
      res = AppNavigator.getTopBuildContext();//WidgetsBinding.instance.focusManager.rootScope.context;
    }

    return res?? getBaseContext();
  }

  static BuildContext? getBaseContext() {
    return materialContext?? AppNavigator.getDeepBuildContext();
  }

  /*static Future<bool> saveRouteName(String routeName) async {
    final int res = await AppDB.setReplaceKv(Keys.setting$lastRouteName, routeName);

    return res > 0;
  }

  static String? fetchLastRouteName() {
    return AppDB.fetchKv(Keys.setting$lastRouteName);
  }*/
  ///------------------------------------------------------------
  static void backRoute() {
    final lastCtx = getTopContext()!;
    AppNavigator.backRoute(lastCtx);
  }

  static void backToRoot(BuildContext context) {
    while(canPop(context)){
      popTopView(context: context);
    }
  }

  static bool canPop(BuildContext context) {
    return AppNavigator.canPop(context);
  }

  /// popPage
  static void popTopView({BuildContext? context, dynamic data}) {
    if(canPop(context?? getTopContext()!)) {
      AppNavigator.pop(context?? getTopContext()!, result: data);
    }
  }

  /*static void pushNamed(BuildContext context, String name, {dynamic extra}) {
    Navigator.of(context).pushNamed(name, arguments: extra);
    ///updateAddressBar(url);
  }

  static void replaceNamed(BuildContext context, String name, {dynamic extra}) {
    Navigator.of(context).pushReplacementNamed(name, arguments: extra);
    ///updateAddressBar(url);
  }*/

  /// note: Navigator.of()... not change url automatic in browser. if use [MaterialApp.router]
  /// and can not effect on back/pre buttons in browser
  static Future pushPage(BuildContext context, Widget page, {dynamic args, String? name}) async {
    final n = name?? (page).toString();

    final r = MaterialPageRoute(
        builder: (ctx){return page;},
        settings: RouteSettings(name: n, arguments: args)
    );

    return Navigator.of(context).push(r);
  }

  static Future pushReplacePage(BuildContext context, Widget page, {dynamic args, String? name}) {
    final n = name?? (page).toString();

    final r = MaterialPageRoute(
        builder: (ctx){return page;},
        settings: RouteSettings(name: n, arguments: args)
    );

    return Navigator.of(context).pushReplacement(r);
  }
}
