import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/middleWares/requester.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({Key? key}) : super(key: key);

  @override
  State<LogsPage> createState() => _LogsPageState();
}
///==============================================================================================
class _LogsPageState extends StateSuper<LogsPage> {
  Requester requester = Requester();


  @override
  void initState(){
    super.initState();

    //assistCtr.addState(AssistController.state$loading);
    //requestData();
  }

  @override
  void dispose(){
    requester.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
        builder: (_, ctr, data){
          return Scaffold(
            body: buildBody(),
          );
        }
    );
  }

  Widget buildBody(){
    return Center(child: Text('بزودی'));
  }


  void onRefresh(){
    assistCtr.clearStates();
    assistCtr.addStateAndUpdateHead(AssistController.state$loading);

    requestData();
  }

  void requestData(){
    requester.httpRequestEvents.onFailState = (requester, res) async {
      assistCtr.clearStates();
      assistCtr.addStateAndUpdateHead(AssistController.state$error);
    };

    requester.httpRequestEvents.onStatusOk = (requester, map) async {
      final data = map['data'];


      assistCtr.clearStates();
      assistCtr.updateHead();
    };

    requester.prepareUrl(pathUrl: '/profile/introduces?Page=1&Size=100');
    requester.methodType = MethodType.get;
    requester.request(context);
  }
}
