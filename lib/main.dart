import 'dart:async';

import 'package:app/constants.dart';
import 'package:app/pages/splash_page.dart';
import 'package:app/system/applicationInitialize.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:app/tools/app/appRoute.dart';


///================ call on any hot restart
Future<void> main() async {

  Future<void> mainInitialize() async {
    SchedulerBinding.instance.ensureVisualUpdate();
    SchedulerBinding.instance.window.scheduleFrame();

    FlutterError.onError = onErrorCatch;
    //FireBaseService.init();
  }

  WidgetsFlutterBinding.ensureInitialized();
  final initOk = await ApplicationInitial.importantInit();

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
                  child: DevicePreview(
                      enabled: false,
                      builder: (ctx){
                        return MyApp();
                      }),
                ),
              );
            }
          )
    );
    }, zonedGuardedCatch);
  }
}
///==============================================================================================
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  ///============ call on any hot reload
  @override
  Widget build(BuildContext context) {
    var x = DefaultTextStyle.of(context).style.fontFamily;
    print('\n ---------- start :$x');
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
      builder: (subContext, home) {
        AppRoute.materialContext = subContext;
        var x = DefaultTextStyle.of(subContext).style.fontFamily;
        print('\n ---------- subContext :: $x ${AppThemes.instance.themeData.textTheme.bodyText1?.fontFamily}');

        return Directionality(
            textDirection: AppThemes.instance.textDirection,
            child: DevicePreview.appBuilder(subContext, home)// home! //materialHomeBuilder(home)
        );
      },
    );
  }

  Widget materialHomeBuilder(Widget? firstPage){
    return Builder(
      builder: (subContext){
        AppRoute.materialContext = subContext;
        final mediaQueryData = MediaQuery.of(subContext);

        /// detect orientation change and rotate screen
        return MediaQuery(
          data: mediaQueryData.copyWith(textScaleFactor: 1.0),
          child: OrientationBuilder(builder: (context, orientation) {
            testCodes(context);

            return SplashPage();
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
            child: Center(child: Text('Error in init.')),
          ),
        ),
      ),
    );
  }
}
///==============================================================================================
void onErrorCatch(FlutterErrorDetails errorDetails) {
  var data = 'on Error catch: ${errorDetails.exception.toString()}';
  data += '\n stack: ${errorDetails.stack}\n==========================================';

  PublicAccess.logger.logToAll(data);
}
///==============================================================================================
zonedGuardedCatch(error, sTrace) {
  final txt = 'on ZonedGuarded catch: ${error.toString()}\n==========================================';
  PublicAccess.logger.logToAll(txt);

  if(kDebugMode) {
    throw error;
  }
}
