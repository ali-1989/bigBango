import 'package:iris_notifier/iris_notifier.dart';

class MessageStateManager<String> extends StatesManager<String> {
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
///=============================================================================
enum MessageStates implements EventNotifyImplement {
  receivedNewFirebaseMessage,
}