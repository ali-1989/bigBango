import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:app/constants.dart';
import 'package:app/pages/splash_page.dart';
import 'package:app/system/applicationInitialize.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/app/appToast.dart';

///================ call on any hot restart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initOk = await ApplicationInitial.prepareDirectoriesAndLogger();

  if(!initOk){
    runApp(const MyErrorApp());
  }
  else {
    runZonedGuarded(() async {
      await mainInitialize();

      runApp(
        /// ReBuild First Widgets tree, not call on Navigator pages
          StreamBuilder<bool>(
              initialData: false,
              stream: AppBroadcast.viewUpdaterStream.stream,
              builder: (context, snapshot) {
              return DefaultTextHeightBehavior(
                textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false),
                child: Toaster(
                  child: MyApp(),
                ),
              );
            }
          )
    );
    }, zonedGuardedCatch);
  }
}

Future<void> mainInitialize() async {
  SchedulerBinding.instance.ensureVisualUpdate();
  SchedulerBinding.instance.window.scheduleFrame();

  FlutterError.onError = onErrorCatch;
}
///==============================================================================================
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  ///============ call on any hot reload
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: AppBroadcast.materialAppKey,
      navigatorKey: AppBroadcast.rootNavigatorKey,
      scaffoldMessengerKey: AppBroadcast.rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      title: Constants.appTitle,
      theme: AppThemes.instance.themeData,
      //darkTheme: ThemeData.dark(),
      themeMode: AppThemes.instance.currentThemeMode,
      //navigatorObservers: [ClearFocusOnPush()],
      scrollBehavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
        },
      ),
      home: materialHomeBuilder(null),
      builder: (localContext, home) {
        AppRoute.materialContext = localContext;

        return DefaultTextStyle(
          style: AppThemes.instance.themeData.textTheme.bodyText1?? TextStyle(),
          child: Directionality(
              textDirection: AppThemes.instance.textDirection,
              child: home! //materialHomeBuilder(home)
              //child: DevicePreview.appBuilder(subContext, home)
          ),
        );
      },
    );
  }

  Widget materialHomeBuilder(Widget? firstPage){
    return Builder(
      builder: (localContext){
        AppRoute.materialContext = localContext;

        /// detect orientation change and rotate screen
        return MediaQuery(
          data: MediaQuery.of(localContext).copyWith(textScaleFactor: 1.0),
          child: OrientationBuilder(builder: (context, orientation) {
            testCodes(context);

            return SplashPage(firstPage: firstPage);
          }),
        );
      },
    );
  }

  Future<void> testCodes(BuildContext context) async {
    //await AppDB.db.clearTable(AppDB.tbKv);
  }
}
///==============================================================================================
class MyErrorApp extends StatelessWidget {
  const MyErrorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Material(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox.expand(
          child: ColoredBox(
              color: Colors.brown,
            child: Center(child: Text('Error in app initialization')),
          ),
        ),
      ),
    );
  }
}
///==============================================================================================
void onErrorCatch(FlutterErrorDetails errorDetails) {
  var txt = 'AN ERROR HAS OCCURRED:: ${errorDetails.exception.toString()}';

  if(!kIsWeb) {
    txt += '\n STACK TRACE:: ${errorDetails.stack}';
  }

  txt += '\n**************************************** [END CATCH]';

  PublicAccess.logger.logToAll(txt);
}
///==============================================================================================
void zonedGuardedCatch(error, sTrace) {
  var txt = 'ZONED-GUARDED CAUGHT AN ERROR:: ${error.toString()}';

  if(!kIsWeb && !kDebugMode) {
    txt += '\n STACK TRACE:: $sTrace';
  }

  txt += '\n**************************************** [END ZONED-GUARDED]';
  PublicAccess.logger.logToAll(txt);

  if(kDebugMode) {
    throw error;
  }
}
