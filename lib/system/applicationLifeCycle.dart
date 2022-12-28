import 'package:flutter/material.dart';

import 'package:iris_tools/api/appEventListener.dart';

import 'package:app/tools/app/appCache.dart';

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
    if(!AppCache.timeoutCache.addTimeout('onPause', const Duration(seconds: 5))) {
      return;
    }
  }

  static void onDetach() async {
    if(!AppCache.timeoutCache.addTimeout('onDetach', const Duration(seconds: 5))) {
      return;
    }

  }

  static void onResume() {
  }
}