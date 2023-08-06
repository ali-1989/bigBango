import 'package:animate_do/animate_do.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/controllers/examController.dart';
import 'package:app/structures/enums/quizType.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/structures/models/listeningModel.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/views/components/exam/examBlankSpaseBuilder.dart';
import 'package:app/views/components/exam/examMakeSentenceBuilder.dart';
import 'package:app/views/components/exam/examOptionBuilder.dart';
import 'package:app/views/components/exam/examSelectWordBuilder.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/widgets/circle.dart';

class ListeningExamBuilder extends StatefulWidget {
  final List<ExamModel> examModelList;
  
  const ListeningExamBuilder({
    required this.examModelList,
    Key? key,
  }) : super(key: key);

  @override
  State createState() => _ListeningExamBuilderState();
}
///===================================================================================================
class _ListeningExamBuilderState extends StateBase<ListeningExamBuilder> {
  Requester requester = Requester();
  late ExamModel currentExam;
  String description = '';
  ExamController? examController;
  int currentIndex = 0;
  late AnimationController examAnimController;

  @override
  void initState(){
    super.initState();

    currentExam = widget.examModelList[0];
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey.shade100,
      child: Column(
        children: [
          buildExamView(),

          Visibility(
            visible: !currentExam.showAnswer,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
                    ),
                    onPressed: onRegisterExamClick,
                    child: const Text('ثبت')
                ),
              ),
            ),
          ),

          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Circle(size: 10, color: Colors.cyan),
              Circle(size: 10, color: Colors.cyan),
              Circle(size: 10, color: Colors.cyan),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildExamView(){
    return FadeIn(
      animate: true,
      manualTrigger: true,
      controller: (animCtr){
        examAnimController = animCtr;
      },
      duration: const Duration(milliseconds: 500),
      child: Builder(
          builder: (_){
            if(currentExam.quizType == QuizType.fillInBlank){
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Row(
                    children: [
                      Text(ExamBlankSpaceBuilder.questionTitle),
                    ],
                  ),
                  const SizedBox(height: 20),

                  ExamBlankSpaceBuilder(
                    key: ValueKey(currentExam.id),
                    examModel: currentExam,
                  ),
                ],
              );
            }
            else if(currentExam.quizType == QuizType.recorder){
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Row(
                    children: [
                      Text(ExamSelectWordBuilder.questionTitle),
                    ],
                  ),
                  const SizedBox(height: 20),

                  ExamSelectWordBuilder(
                    key: ValueKey(currentExam.id),
                    exam: currentExam,
                  ),
                ],
              );
            }
            else if(currentExam.quizType == QuizType.multipleChoice){
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Row(
                    children: [
                      Text(ExamOptionBuilder.questionTitle),
                    ],
                  ),
                  const SizedBox(height: 20),

                  ExamOptionBuilder(
                    key: ValueKey(currentExam.id),
                    examModel: currentExam,
                  ),
                ],
              );
            }
            else if(currentExam.quizType == QuizType.makeSentence){
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(ExamMakeSentenceBuilder.questionTitle),
                  const SizedBox(height: 20),

                  ExamMakeSentenceBuilder(
                    key: ValueKey(currentExam.id),
                    examModel: currentExam,
                  ),
                ],
              );
            }

            return const SizedBox();
          }
      ),
    );
  }

  void onRegisterExamClick() {
    examController = ExamController.getControllerFor(currentExam);

    if(examController != null){
      if(!examController!.isAnswer()){
        AppToast.showToast(context, 'لطفا تمرین را انجام دهید ');
        return;
      }

      requestSendAnswer();
    }
  }

  void requestSendAnswer(){
    requester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, res) async {
      AppSnack.showSnack$errorCommunicatingServer(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      examController?.showAnswer(true);

      final message = res['message']?? 'پاسخ شما ثبت شد';
      AppSnack.showInfo(context, message);
      assistCtr.updateHead();
    };

    final js = <String, dynamic>{};
    final tempList = [];

    if(currentExam.items.length < 2) {
      tempList.add({
        'exerciseId': currentExam.getExamItem().id,
        'answer': currentExam.getExamItem().getUserAnswerText(),
        'isCorrect': currentExam.getExamItem().isUserAnswerCorrect(),
      });
    }
    else {
      for (final itm in currentExam.items){
        tempList.add({
          'exerciseId': itm.id,
          'answer': currentExam.sentenceExtra!.joinUserAnswerById(itm.id),
          'isCorrect': currentExam.sentenceExtra!.isCorrectById(itm.id),
        });
      }
    }

    js['items'] = tempList;

    requester.methodType = MethodType.post;
    requester.prepareUrl(pathUrl: '/listening/exercises/solving');
    requester.bodyJson = js;

    showLoading();
    requester.request(context);
  }
}
