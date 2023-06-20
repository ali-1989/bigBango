import 'package:app/structures/builders/examBuilderContent.dart';
import 'package:app/structures/enums/quizType.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/structures/models/onlineExamModels/onlineExamCategoryModel.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/views/components/exam/examBlankSpaseBuilder.dart';
import 'package:app/views/components/exam/examMakeSentenceBuilder.dart';
import 'package:app/views/components/exam/examOptionBuilder.dart';
import 'package:app/views/components/exam/examSelectWordBuilder.dart';
import 'package:app/views/states/backBtn.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:flutter/material.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appDecoration.dart';
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
  int currentCategoryIdx = 0;
  int currentQuestionIdx = 0;
  Requester requester = Requester();
  List<OnlineExamCategoryModel> categories = [];
  List<ExamModel> questions = [];
  ExamModel? currentQuestion;


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
      return const WaitToLoad();
    }

    if(assistCtr.hasState(AssistController.state$error)){
      return ErrorOccur(backButton: const BackBtn());
    }

    if(questions.isEmpty){
      return const EmptyData(backButton: BackBtn());
    }

    Color preColor = Colors.black;
    Color nextColor = Colors.black;

    if(currentQuestionIdx == 0){
      preColor = Colors.grey;
    }

    if(currentQuestionIdx >= questions.length-1){
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

              const BackBtn(button: Icon(AppIcons.close)),
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
                  Text(' ${questions.length}  /',
                      style: const TextStyle(fontSize: 15)
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
                          child: Text('${currentQuestionIdx+1}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
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
                color: AppDecoration.red,
                value: calcQuestionProgress(),
                minHeight: 5,
              ),
            ),
          ),

          Expanded(
              child: buildQuestion(),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                  onPressed: (){
                    goNextQuestion();
                  },
                  icon: Image.asset(AppImages.arrowRightIco, color: nextColor),
                  label: const Text('Next').englishFont().color(nextColor)
              ),

              TextButton.icon(
                  onPressed: (){
                    goPrevQuestion();
                  },
                  icon: const Text('pre').englishFont().color(preColor),
                  label: Image.asset(AppImages.arrowLeftIco, color: preColor)
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget buildQuestion(){
    //final builder = ExamBuilderContent();
    //builder.showSendButton = false;
    //builder.examList.add(currentQuestion!);
    
    if(currentQuestion!.quizType == QuizType.fillInBlank){
      return ExamBlankSpaceBuilder(
        key: ValueKey('id_${currentQuestion!.hashCode}'),
        examModel: currentQuestion!,
      );
    }
    else if(currentQuestion!.quizType == QuizType.recorder){
      return ExamSelectWordBuilder(
          key: ValueKey('id_${currentQuestion!.hashCode}'),
          exam: currentQuestion!,
      );
    }
    else if(currentQuestion!.quizType == QuizType.multipleChoice){
      return ExamOptionBuilder(
          key: ValueKey('id_${currentQuestion!.hashCode}'),
          examModel: currentQuestion!,
      );
    }
    else if(currentQuestion!.quizType == QuizType.makeSentence){
      return ExamMakeSentenceBuilder(
          key: ValueKey('id_${currentQuestion!.hashCode}'),
          examModel: currentQuestion!,
      );
    }
    
    return const SizedBox();
  }
  
  void goNextQuestion() {
    if(currentQuestionIdx < questions.length){
      currentQuestionIdx++;
      currentQuestion = questions[currentQuestionIdx];

      assistCtr.updateHead();
    }
  }

  void goPrevQuestion() {
    if(currentQuestionIdx > 0){
      currentQuestionIdx--;
      currentQuestion = questions[currentQuestionIdx];

      assistCtr.updateHead();
    }
  }

  void parseQuestions(List list) {
    for(final ex in list){
      final q = OnlineExamCategoryModel.fromMap(ex);

      if(q.questions.isNotEmpty) {
        categories.add(q);
        questions.addAll(q.questions);
      }
    }

    if(questions.isNotEmpty){
      currentQuestion = questions[0];
    }
  }

  double calcQuestionProgress() {
    return ((currentQuestionIdx+1) *100 / questions.length)/100;
  }

  void requestQuestions(){
    requester.httpRequestEvents.onFailState = (req, response) async {
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
    requester.prepareUrl(pathUrl: '/placementExam/questions');
    requester.request();
  }
}