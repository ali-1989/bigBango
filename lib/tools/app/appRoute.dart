import 'package:app/tools/app/appNavigator.dart';
import 'package:flutter/material.dart';


class AppRoute {
  AppRoute._();

  static late BuildContext materialContext;

  static void init() {
  }

  static BuildContext getLastContext() {
    var res = WidgetsBinding.instance.focusManager.rootScope.focusedChild?.context;//deep: 50
    res ??= WidgetsBinding.instance.focusManager.primaryFocus?.context; //deep: 71

    return res?? getBaseContext();
  }

  static BuildContext getBaseContext() {
    return materialContext;
  }

  /*static Future<bool> saveRoutePageName(String routeName) async {
    final int res = await AppDB.setReplaceKv(Keys.setting$lastRouteName, routeName);

    return res > 0;
  }

  static String? fetchRoutePageName() {
    return AppDB.fetchKv(Keys.setting$lastRouteName);
  }

  static void navigateRouteScreen(String routeName) {
    saveRouteName(routeName);
    SettingsManager.settingsModel.currentRouteScreen = routeName;
    AppBroadcast.reBuildMaterial();
  }*/

  static void backRoute() {
    final lastCtx = AppNavigator.getLastRouteContext(getLastContext());
    AppNavigator.backRoute(lastCtx);
  }

  static void backToRoot(BuildContext context) {
    //AppNavigator.popRoutesUntilRoot(AppRoute.getContext());

    while(canPop(context)){
      popTopView(context);
    }
  }

  static bool canPop(BuildContext context) {
    return AppNavigator.canPop(context);
  }

  static void popTopView(BuildContext context) {
    AppNavigator.pop(context);
  }

  /*static void popPage(BuildContext context) {
    GoRouter.of(context).pop();
  }*/

  static Future push(BuildContext context, Widget page, {dynamic extra}) async {
    final r = MaterialPageRoute(builder: (ctx){
      return page;
    });

    return Navigator.of(context).push(r);
  }
  
  /*static void push(BuildContext context, String address, {dynamic extra}) {
    if(kIsWeb){
      GoRouter.of(context).go(address, extra: extra);
    }
    else {
      GoRouter.of(context).push(address, extra: extra);
    }
  }*/

  static void replace(BuildContext context, Widget page, {dynamic extra}) {
    final r = MaterialPageRoute(builder: (ctx){
      return page;
    });

    Navigator.of(context).pushReplacement(r);
  }

  static void pushNamed(BuildContext context, String name, {dynamic extra}) {
    Navigator.of(context).pushNamed(name, arguments: extra);
  
    /*if(kIsWeb){
      GoRouter.of(context).goNamed(name, params: {}, extra: extra);
    }
    else {
      GoRouter.of(context).pushNamed(name, params: {}, extra: extra);
    }*/
  }

  static void replaceNamed(BuildContext context, String name, {dynamic extra}) {
    Navigator.of(context).pushReplacementNamed(name, arguments: extra);
    //GoRouter.of(context).replaceNamed(name, params: {}, extra: extra);
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
