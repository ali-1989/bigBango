import 'package:animate_do/animate_do.dart';
import 'package:app/structures/enums/quizType.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/views/components/exam/examBlankSpaseBuilder.dart';
import 'package:app/views/components/exam/examMakeSentenceBuilder.dart';
import 'package:app/views/components/exam/examOptionBuilder.dart';
import 'package:app/views/components/exam/examSelectWordBuilder.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/system.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/injectors/examPageInjector.dart';
import 'package:app/structures/controllers/examController.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appSnack.dart';

class ExamPage extends StatefulWidget {
  final ExamPageInjector injector;

  const ExamPage({
    required this.injector,
    Key? key
  }) : super(key: key);

  @override
  State<ExamPage> createState() => _ExamPageState();
}
///======================================================================================================================
class _ExamPageState extends StateBase<ExamPage> with TickerProviderStateMixin {
  Requester requester = Requester();
  late ExamModel currentExam;
  int currentExamIndex = 0;
  Set<String> answeredExamList = {};
  late AnimationController examAnimController;

  @override
  void initState(){
    super.initState();

    if(widget.injector.examList.isNotEmpty) {
      currentExam = widget.injector.examList.first;
    }
  }

  @override
  void dispose(){
    super.dispose();

    requester.dispose();

    if(widget.injector.clearUserAnswerOnExit){
      for (final exam in widget.injector.examList) {
        exam.clearUserAnswers();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
        controller: assistCtr,
        builder: (ctx, ctr, data){
          return Scaffold(
            body: SafeArea(
                child: buildBody()
            ),
          );
        }
    );
  }

  Widget buildBody(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),

          /// page header
          buildHeader(),

          const SizedBox(height: 10),

          /// body view
          Expanded(
            child: buildPage1(),
          ),
        ],
      ),
    );
  }

  Widget buildHeader(){
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 4,
                  height: 26,
                  child: ColoredBox(color: AppDecoration.red),
                ),

                const SizedBox(width: 7),
                const Text('تمرین').bold().fsR(4),
              ],
            ),

            GestureDetector(
              onTap: (){
                AppNavigator.pop(context);
              },
              child: Row(
                children: [
                  Text(AppMessages.back),
                  const SizedBox(width: 10),
                  CustomCard(
                      color: Colors.white,
                      padding: const EdgeInsets.all(5),
                      child: Image.asset(AppImages.arrowLeftIco)
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPage1(){
    if(widget.injector.examList.isEmpty){
      return const SizedBox();
    }
    
    return Column(
      children: [
        const SizedBox(height: 10),

        /// exams
        /*Expanded(child: ExamBuilder(builder: widget.builder, groupSameTypes: widget.groupSameTypes)),*/
        Expanded(
            child: buildExamView(),
        ),

        /// send button
        buildBottomSectionPage1(),

        const SizedBox(height: 10),
      ],
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

  Widget buildBottomSectionPage1() {
    if(answeredExamList.length == widget.injector.examList.length || !widget.injector.showSendButton){
      return const SizedBox();
    }

    return Builder(
      builder: (context) {
        if (widget.injector.examList.length < 2) {
          return ElevatedButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(200, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(
                  horizontal: 0, vertical: -2),
              //shape: StadiumBorder()
            ),
            onPressed: onSendExamAnswerClick,
            child: const Text('ثبت و بررسی')
                .englishFont().color(Colors.white),
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Expanded(
              child: ElevatedButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(100, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                  //shape: StadiumBorder()
                ),
                onPressed: onSendExamAnswerClick,
                child: Text(answeredExamList.contains(currentExam.id) ? AppMessages.next : 'ثبت و بررسی')
                    .englishFont().color(Colors.white),
              ),
            ),

            Expanded(
                child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: TextDirection.ltr,
                      children: [
                        CustomCard(
                            color: Colors.grey.shade200,
                            padding: const EdgeInsets.symmetric(horizontal:6, vertical: 2),
                            radius: 4,
                            child: Text('${currentExamIndex+1}').bold().ltr()
                        ),

                        Text('  /  ${widget.injector.examList.length}').ltr(),
                      ],
                    )
                )
            ),

            Expanded(
              child: Visibility(
                visible: hasNextExam(),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black87,
                    ),
                      onPressed: onExamSkipClick,
                      child: const Text('skip')
                  ),
                ),
              ),
            ),
          ],
        );
      }
    );
  }

  bool hasNextExam(){
    return currentExamIndex < widget.injector.examList.length-1;
  }

  void onExamSkipClick() {
    if(hasNextExam()){
      answeredExamList.add(currentExam.id);

      currentExamIndex++;
      currentExam = widget.injector.examList[currentExamIndex];

      examAnimController.reset();
      assistCtr.updateHead();
      examAnimController.forward();
    }
  }

  void onSendExamAnswerClick(){
    if(answeredExamList.contains(currentExam.id)){
      onExamSkipClick();
      return;
    }

    if(widget.injector.askConfirmToSend) {
      AppDialogIris.instance.showYesNoDialog(
        context,
        yesFn: (ctx) async {
          await System.wait(const Duration(milliseconds: 500));
          requestSendExamAnswer();
        },
        desc: 'آیا جواب تمرین ارسال شود؟',
      );
    }
    else {
      requestSendExamAnswer();
    }
  }

  void requestSendExamAnswer(){
    /*if(!examController.isAnswerToAll()){
        AppToast.showToast(context, 'لطفا به سوالات پاسخ دهید');
        return;
      }*/

    requester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, res) async {
      AppSnack.showSnack$errorCommunicatingServer(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      answeredExamList.add(currentExam.id);
      final message = res['message']?? 'پاسخ تمرین ثبت شد';

      AppSnack.showInfo(context, message, millis: 1600);

      ExamController.getControllerFor(currentExam)?.showAnswer(true);

      assistCtr.updateHead();
    };

    final tempList = [];
    final js = <String, dynamic>{};

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
    requester.prepareUrl(pathUrl: widget.injector.answerUrl);
    requester.bodyJson = js;

    showLoading();
    requester.request(context);
  }
}
