import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/onlineExamModels/onlineExamModel.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/views/states/backBtn.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:flutter/material.dart';

import 'package:app/managers/systemParameterManager.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

class SelectLevelOnline extends StatefulWidget {
  const SelectLevelOnline({Key? key}) : super(key: key);

  @override
  State<SelectLevelOnline> createState() => _SelectLevelOnlineState();
}
///=========================================================================================================
class _SelectLevelOnlineState extends StateBase<SelectLevelOnline> {
  int currentQuestion = 0;
  Requester requester = Requester();
  List<OnlineExamModel> questions = [];

  @override
  void initState(){
    super.initState();

    requestQuestions();
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
      builder: (_, __, data) {
        return Scaffold(
          body: buildBody(),
        );
      }
    );
  }

  Widget buildBody() {
    if(assistCtr.hasState(AssistController.state$loading)){
      return WaitToLoad();
    }

    /*if(assistCtr.hasState(AssistController.state$error)){
      return ErrorOccur(backButton: BackBtn());
    }*/

    Color preColor = Colors.black;
    Color nextColor = Colors.black;

    if(currentQuestion == 0){
      preColor = Colors.grey;
    }

    if(currentQuestion == questions.length -1){
      nextColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// close button
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(AppImages.selectLevelIco3),
                  const SizedBox(width: 10),
                  Text(AppMessages.selectLevelOnline, style: const TextStyle(fontSize: 17)),
                ],
              ),

              BackBtn(button: Icon(AppIcons.close)),
            ],
          ),

          /// description
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(AppMessages.onlineDetectLevelDescription, textAlign: TextAlign.start, style: const TextStyle(height: 1.4)),
          ),

          const SizedBox(height: 25),
          SizedBox(
            height: 0.5,
            width: double.infinity,
            child: ColoredBox(color: Colors.black.withAlpha(120)),
          ),

          /// progressbar
          const SizedBox(height: 17),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(' ${questions.length}   /',
                      style: TextStyle(fontSize: 15)
                  ),

                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: ColoredBox(
                      color: Colors.grey[200]!,
                      child: SizedBox(
                        width: 25,
                        height: 25,
                        child: Center(
                          child: Text('${currentQuestion+1}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              /*Text(AppMessages.chooseTheCorrectAnswer,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
              ),*/
            ],
          ),

          const SizedBox(height: 12),
          Directionality(
            textDirection: TextDirection.ltr,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                backgroundColor: Colors.red.withAlpha(30),
                color: AppColors.red,
                value: calcQuestionProgress(),
                minHeight: 5,
              ),
            ),
          ),

          Expanded(
              child: SizedBox(),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                  onPressed: (){
                    goNextQuestion();
                  },
                  icon: Image.asset(AppImages.arrowRightIco, color: nextColor),
                  label: Text('Next').englishFont().color(nextColor)
              ),

              TextButton.icon(
                  onPressed: (){
                    goPrevQuestion();
                  },
                  icon: Text('pre').englishFont().color(preColor),
                  label: Image.asset(AppImages.arrowLeftIco, color: preColor)
              ),
            ],
          )
        ],
      ),
    );
  }

  void goNextQuestion() {

  }

  void goPrevQuestion() {

  }

  void parseQuestions(List list) {
    for(final ex in list){
      final q = OnlineExamModel.fromMap(ex);
      questions.add(q);
    }
  }

  double calcQuestionProgress() {
    return ((currentQuestion+1) *100 / questions.length)/100;
  }

  void requestQuestions(){
    requester.httpRequestEvents.onFailState = (req, response) async {
      final q = OnlineExamModel();
      questions.add(q);

      assistCtr.clearStates();
      assistCtr.addStateAndUpdateHead(AssistController.state$error);
    };

    requester.httpRequestEvents.onStatusOk = (req, response) async {
      final data = response['data'];

      if(data is List){
        parseQuestions(data);
      }

      assistCtr.clearStates();
      assistCtr.updateHead();
    };


    assistCtr.addStateAndUpdateHead(AssistController.state$loading);
    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/placementTest/questions');
    requester.request();
  }
}