import 'package:iris_notifier/iris_notifier.dart';

class MessageStateStructure<String> extends StateHolder<String> {
  bool isRequested = false;
  bool isInRequest = false;
  bool hasErrorInReceiveData = false;
  bool hasNextPage = true;
  bool receivedNewFirebaseMessage = false;

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