import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:app/services/event_dispatcher_service.dart';
import 'package:app/services/review_service.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appCache.dart';

class NetListenerTools {
  NetListenerTools._();

  /// this fn call on app launch: if (wifi/cell data) is on.
  static void onNetListener(ConnectivityResult connectivityResult) async {
    EventDispatcherService.notify(EventDispatcher.networkStateChange);

    if(connectivityResult != ConnectivityResult.none) {
      AppBroadcast.isNetConnected = true;
      EventDispatcherService.notify(EventDispatcher.networkConnected);

      ReviewService.sendReviews();
    }
    else {
      AppBroadcast.isNetConnected = false;
      EventDispatcherService.notify(EventDispatcher.networkDisConnected);

      AppCache.clearDownloading();
    }
  }

  /*static void onWsConnectedListener(){
    AppBroadcast.isWsConnected = true;
    EventDispatcherService.notify(EventDispatcher.webSocketStateChange);
    EventDispatcherService.notify(EventDispatcher.webSocketConnected);
  }

  static void onWsDisConnectedListener(){
    AppBroadcast.isWsConnected = false;
    EventDispatcherService.notify(EventDispatcher.webSocketDisConnected);
  }*/
}
