import 'dart:async';

import 'package:app/managers/fontManager.dart';
import 'package:app/models/abstract/stateBase.dart';
import 'package:app/pages/home_page.dart';
import 'package:app/pages/phone_number_page.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/net/trustSsl.dart';

import 'package:app/constants.dart';
import 'package:app/managers/settingsManager.dart';
import 'package:app/managers/versionManager.dart';
import 'package:app/system/initialize.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/tools/deviceInfoTools.dart';

bool _isInit = false;
bool _isInLoadingSettings = true;
bool mustShowSplash = true;
int splashWaitingMil = 4000;

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}
///======================================================================================================
class SplashScreenState extends StateBase<SplashPage> {

  @override
  void initState() {
    super.initState();

    System.hideBothStatusBar();
  }

  @override
  Widget build(BuildContext context) {
    /// ReBuild First Widgets tree, not call on Navigator pages
    return StreamBuilder<bool>(
        initialData: false,
        stream: AppBroadcast.viewUpdaterStream.stream,
        builder: (context, snapshot) {
          splashTimer();
          init();

          if (_isInLoadingSettings || canShowSplash()) {
            return getSplashView();
          }
          else {
            return getMaterialApp();
          }
        });
  }
  ///==================================================================================================
  Widget getSplashView() {
    if (kIsWeb) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFFF0A17D), Color(0xFFFFFFFF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                )
            ),
            child: SizedBox.expand(),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            //child: SvgPicture.asset('assets/images/splash.svg', fit: BoxFit.fill, allowDrawingOutsideViewBox: true)
            child: SizedBox(height: sh * 0.75, child: Image.asset(AppImages.logoSplash, fit: BoxFit.fill)
            ),
          ),

          Positioned(
            bottom: 40,
            left: 43,
            right: 43,
            child: Image.asset(AppImages.keyboard, fit: BoxFit.scaleDown),
          ),

          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ColoredBox(
                color: Colors.white,
                child: SizedBox(
                    height: 30,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: Text(' نسخه ی 1.1',
                        style: TextStyle(fontFamily: FontManager.instance.defaultFontFor('fa', FontUsage.bold).family)
                      ),
                    )
                ),
              )),
        ],
      ),
    );
  }

  ///==================================================================================================
  Widget getMaterialApp() {
    return MaterialApp(
      key: AppBroadcast.materialAppKey,
      debugShowCheckedModeBanner: false,
      //navigatorObservers: [ClearFocusOnPush()],
      //scrollBehavior: MyCustomScrollBehavior(),
      title: Constants.appTitle,
      theme: AppThemes.instance.themeData,
      // ThemeData.light()
      //darkTheme: ThemeData.dark(),
      themeMode: AppThemes.instance.currentThemeMode,
      scaffoldMessengerKey: AppBroadcast.rootScaffoldMessengerKey,
      home: pageRouting(),
      scrollBehavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
        },
      ),
      builder: (context, home) {
        AppRoute.materialContext = context;
        final mediaQueryData = MediaQuery.of(context);

        /// detect orientation change and rotate screen
        return MediaQuery(
          data: mediaQueryData.copyWith(textScaleFactor: 1.0),
          child: OrientationBuilder(builder: (context, orientation) {
            //AppLocale.detectLocaleDirection(SettingsManager.settingsModel.appLocale); //Localizations.localeOf(context)
            testCodes(context);

            return Directionality(
                textDirection: AppThemes.instance.textDirection,
                child: Toaster(child: home!)
            );
          }),
        );
      },
    );
  }

  Widget pageRouting(){
    return Builder(
      builder: (ctx){
        if(Session.hasAnyLogin()){
          return HomePage(key: AppBroadcast.homeScreenKey);
        }

        return const PhoneNumberPage();
      },
    );
  }

  ///==================================================================================================
  bool canShowSplash() {
    return mustShowSplash && !kIsWeb;
  }

  void splashTimer() async {
    if (splashWaitingMil > 0 && canShowSplash()) {
      Timer(Duration(milliseconds: splashWaitingMil), () {
        mustShowSplash = false;

        AppBroadcast.reBuildMaterial();
      });

      splashWaitingMil = 0;
    }
  }

  void init() async {
    if (_isInit) {
      return;
    }

    _isInit = true;

    await InitialApplication.importantInit();
    await AppDB.init();

    AppThemes.initial();
    _isInLoadingSettings = !SettingsManager.loadSettings();

    if (!_isInLoadingSettings) {
      await Session.fetchLoginUsers();
      await checkInstallVersion();
      await InitialApplication.onceInit(context);

      AppBroadcast.reBuildMaterialBySetTheme();
      asyncInitial(context);
    }
  }

  void asyncInitial(BuildContext context) {
    if (!InitialApplication.isLaunchOk) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Timer.periodic(const Duration(milliseconds: 50), (Timer timer) {
          if (InitialApplication.isInitialOk) {
            timer.cancel();

            TrustSsl.acceptBadCertificate();
            checkAppNewVersion(context);
            InitialApplication.callOnLaunchUp();
          }
        });
      });
    }
  }

  Future<void> checkInstallVersion() async {
    final oldVersion = SettingsManager.settingsModel.currentVersion;

    if (oldVersion == null) {
      VersionManager.onFirstInstall();
    }
    else if (oldVersion < Constants.appVersionCode) {
      VersionManager.onUpdateInstall();
    }
  }

  void checkAppNewVersion(BuildContext context) async {
    final holder = DeviceInfoTools.getDeviceInfo();

    //final version = await VersionManager.checkVersion(holder);
  }

  Future<void> testCodes(BuildContext context) async {
    //await AppDB.db.clearTable(AppDB.tbKv);
  }
}
