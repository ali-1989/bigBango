import 'package:app/tools/app/appCache.dart';

class LifeCycleApplication {
  LifeCycleApplication._();

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
