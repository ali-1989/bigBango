import 'package:app/system/keys.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:flutter/material.dart';
import 'package:app/tools/app/appDb.dart';


class AppRoute {

  AppRoute._();

  static late BuildContext materialContext;

  static BuildContext getContext() {
    var res = WidgetsBinding.instance.focusManager.rootScope.focusedChild?.context;//deep: 50
    res ??= WidgetsBinding.instance.focusManager.primaryFocus?.context; //deep: 71

    return res?? materialContext;
  }

  static void init(){
  }

  static void backRoute() {
    final lastCtx = AppNavigator.getLastRouteContext(getContext());
    AppNavigator.backRoute(lastCtx);
  }

  static void backToRoot(BuildContext context) {
    //AppNavigator.popRoutesUntilRoot(AppRoute.getContext());

    while(canPop(context)){
      pop(context);
    }
  }

  static bool canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }

  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }

  /*static void push(BuildContext context, String address, {dynamic extra}) {
    Navigator.of(context).push(r);
  }*/

  static void push(BuildContext context, Widget page, {dynamic extra}) {
    final r = MaterialPageRoute(builder: (ctx){
      return page;
    });

    Navigator.of(context).push(r);
  }

  static void pushNamed(BuildContext context, String name, {dynamic extra}) {
    Navigator.of(context).pushNamed(name, arguments: extra);
  }

  static void replaceNamed(BuildContext context, String name, {dynamic extra}) {
    Navigator.of(context).pushReplacementNamed(name, arguments: extra);
  }

  static Future<bool> saveRouteName(String routeName) async {
    final int res = await AppDB.setReplaceKv(Keys.setting$lastRouteName, routeName);

    return res > 0;
  }

  static String? fetchRouteScreenName() {
    return AppDB.fetchKv(Keys.setting$lastRouteName);
  }
}
///============================================================================================
class MyPageRoute extends PageRouteBuilder {
  final Widget widget;
  final String? routeName;

  MyPageRoute({
    required this.widget,
    this.routeName,
  })
      : super(
        settings: RouteSettings(name: routeName),
        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
          return widget;
        },
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child) {
        //ScaleTransition, RotationTransition, SizeTransition, FadeTransition
        return SlideTransition(
          textDirection: TextDirection.rtl,
          position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero,).animate(animation),
          child: child,
        );
      });
}
