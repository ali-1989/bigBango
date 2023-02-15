import 'package:app/services/stateNotifier.dart';

class NotificationStateStructure<String> extends StateHolder<String> {
  bool isRequested = false;
  bool isInRequest = false;
  bool hasErrorInReceiveData = false;
  bool hasNextPage = true;

  void errorOccur(){
    isRequested = true;
    isInRequest = false;
    hasErrorInReceiveData = true;
  }

  void dataIsOk(){
    isRequested = true;
    isInRequest = false;
    hasErrorInReceiveData = false;
  }

  bool isOk(){
    return isRequested && !isInRequest && !hasErrorInReceiveData;
  }
}