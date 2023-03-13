import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/services/event_dispatcher_service.dart';
import 'package:app/tools/app/appBadge.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appNotification.dart';

// https://firebase.google.com/docs/cloud-messaging/flutter/receive
// https://firebase.google.com/docs/cloud-messaging/flutter/client

@pragma('vm:entry-point')
Future<void> _fbMessagingBackgroundHandler(RemoteMessage message) async {
  /// firebase it self sending a notification

  // this is runs in its own isolate outside your applications context,
  // and can, perform logic such as HTTP requests,
  // perform IO operations (e.g. updating local storage),
  // communicate with other plugins


  //await Firebase.initializeApp();
  //await ApplicationInitial.prepareDirectoriesAndLogger();
  //await ApplicationInitial.inSplashInit();
}

Future<void> _onNewNotification(RemoteMessage message) async {
  try{
    if(AppBroadcast.messagePageIsOpen){
      AppBroadcast.messageStateNotifier.states.receivedNewFirebaseMessage = true;
      AppBroadcast.messageStateNotifier.notify();
    }
    else {
      if(message.notification != null && message.notification!.body != null) {
        int old = AppBadge.getMessageBadge();
        AppBadge.setMessageBadge(old + 1);
        AppBadge.refreshViews();

        AppNotification.sendNotification(
            message.notification!.title,
            message.notification!.body!,
            payload: {'key': 'message'}
        );
      }
    }
  }
  catch (e){/**/}
}
///================================================================================================
class FireBaseService {
  static String? token;
  static DateTime? lastUpdateToken;

  FireBaseService._();

  static Future<void> initializeApp() async {
    try {
      if(kIsWeb){
        final firebaseOptions = FirebaseOptions(
          appId: '1:749269012345:web:4ee1b7c8dbd87deea029a8',
          apiKey: 'AIzaSyD_Fo5k9gaMc7XH1D9dnwYSmjqamllhi8I',
          projectId: 'bigbango-messaging',
          messagingSenderId: '749269012345',
          measurementId: 'G-RCVHT2215T',
        );

        await Firebase.initializeApp(options: firebaseOptions);
        return;
      }

      final firebaseOptions = FirebaseOptions(
        appId: '1:749269012345:android:81c6b4bdda067517a029a8',
        apiKey: 'AIzaSyDK_jAmfkPi7AKQfqHOM8YBLttSL3HRvGY',
        projectId: 'bigbango-messaging',
        messagingSenderId: '749269012345',
        measurementId: 'G-RCVHT2215T',
      );

      await Firebase.initializeApp(options: firebaseOptions);
    }
    catch (e){/**/}
  }

  static Future prepare() async {
    //FirebaseMessaging.instance.isSupported()

    try {
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      ///----- ios
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      /// https://firebase.google.com/docs/cloud-messaging/flutter/client#prevent-auto-init
      //FirebaseMessaging.instance.setAutoInitEnabled(false);

      setListening();
    }
    catch (e){/**/}
  }

  static void setListening() async {
    /// it's fire when app is open and is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
     _onNewNotification(message);
    });

    /// it's fire when app is be in background or is was terminated
    FirebaseMessaging.onBackgroundMessage(_fbMessagingBackgroundHandler);

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      token = fcmToken;
      EventDispatcherService.notify(EventDispatcher.firebaseTokenReceived);
    });

    /// it's fire when be click on Fcm notification. (no notification by app)
    FirebaseMessaging.onMessageOpenedApp.listen(_handler);

    ///When app is opened by the user touch (not by the notification), and there is a Fcm notification in the statusbar
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handler(initialMessage);
    }
  }

  static void _handler(RemoteMessage message) {
    //if (message.data['type'] == 'chat') {
    AppBroadcast.layoutPageKey.currentState?.gotoPage(3);
  }

  static Future<String?> getTokenForce() async {
    token = await FirebaseMessaging.instance.getToken(vapidKey: 'BAXEdcb2ZrYd6vPtQcdz03M4JCftVqGh1_TbSU2HXkekcS1y_Y3NB1_UI1p2py6XYZfAi8MvXJlO7k7kRouXY4U');

    if(token != null) {
      lastUpdateToken = DateHelper.getNow();
      EventDispatcherService.notify(EventDispatcher.firebaseTokenReceived);

      return token;
    }
    else {
      EventDispatcherService.attachFunction(EventDispatcher.networkConnected, _onNetConnected);
      return null;
    }
  }

  static Future<String?> getToken() async {
    if(token == null || lastUpdateToken == null){
      return getTokenForce();
    }

    if(DateHelper.isPastOf(lastUpdateToken, Duration(hours: 2))){
      return getTokenForce();
    }

    return token;
  }

  static Future<void> subscribeToTopic(String name) async {
    return FirebaseMessaging.instance.subscribeToTopic(name);
  }

  static Future<void> unsubscribeFromTopic(String name) async {
    return FirebaseMessaging.instance.unsubscribeFromTopic(name);
  }

  static Map generateMessage(String? token) {
    final messageCount = 0;

    final js = {};
    js['token'] = token;

    js['data'] = {
    'from': 'FlutterFire Cloud Messaging!!!',
    'count': messageCount.toString(),
    };

    js['notification'] = {
    'title': 'Hello FlutterFire!',
    'body': 'This notification (#$messageCount) was created via FCM!',
    };

    return js;
  }

  static void _onNetConnected({data}) {
    EventDispatcherService.deAttachFunction(EventDispatcher.networkConnected, _onNetConnected);
    getTokenForce();
  }
}
