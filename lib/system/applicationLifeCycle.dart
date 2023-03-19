import 'package:app/structures/enums/appEventDispatcher.dart';
import 'package:flutter/material.dart';

import 'package:app/tools/app/appCache.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/notifiers/appEventListener.dart';

class ApplicationLifeCycle {
  ApplicationLifeCycle._();

  static void init(){
    final eventListener = AppEventListener();
    eventListener.addResumeListener(ApplicationLifeCycle.onResume);
    eventListener.addPauseListener(ApplicationLifeCycle.onPause);
    eventListener.addDetachListener(ApplicationLifeCycle.onDetach);
    WidgetsBinding.instance.addObserver(eventListener);
  }

  static void onPause() async {
    if(!AppCache.timeoutCache.addTimeout('onPause', const Duration(seconds: 4))) {
      return;
    }

    EventNotifierService.notify(EventDispatcher.appPause);
  }

  static void onDetach() async {
    if(!AppCache.timeoutCache.addTimeout('onDetach', const Duration(seconds: 4))) {
      return;
    }

    EventNotifierService.notify(EventDispatcher.appDeatach);
  }

  static void onResume() {
    EventNotifierService.notify(EventDispatcher.appResume);
  }
}
