import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appNavigatorObserver.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/homeComponents/splashPage.dart';
import 'package:flutter/material.dart';


/* usage: in MaterialApp()
home: Router(
        routerDelegate: AppRouterDelegate.instance(),
        backButtonDispatcher: RootBackButtonDispatcher(),
      ),*/

class AppRouterDelegate<T> extends RouterDelegate<T> with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  static AppRouterDelegate? _instance;

  AppRouterDelegate._();

  static AppRouterDelegate<T> instance<T>(){
    _instance ??= AppRouterDelegate<T>._();

    return _instance! as AppRouterDelegate<T>;
  }

  @override
  GlobalKey<NavigatorState>? get navigatorKey => AppBroadcast.rootNavigatorKey;

  /*@override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
  }*/

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
        child: Navigator(
          key: AppBroadcast.rootNavigatorKey,
          observers: [AppNavigatorObserver.instance()],
          onUnknownRoute: AppNavigatorObserver.onUnknownRoute,
          onGenerateRoute: AppNavigatorObserver.onGenerateRoute,
          onPopPage: AppNavigatorObserver.onPopPage,
          pages: [
            MaterialPage(child: materialHomeBuilder())
          ],
        )
    );
  }

  @override
  Future<bool> popRoute() async {
    /// on back button press
    if(RouteTools.canPop(RouteTools.getTopContext()!)) {
      RouteTools.popTopView();
      return true;
    }

    return false;
  }

  @override
  Future<void> setNewRoutePath(configuration) async {
    return;
  }

  Widget materialHomeBuilder(){
    return Builder(
      builder: (localContext){
        RouteTools.materialContext = localContext;
        testCodes(localContext);

        return SplashPage();
      },
    );
  }

  Future<void> testCodes(BuildContext context) async {
    //await AppDB.db.clearTable(AppDB.tbKv);
  }
}