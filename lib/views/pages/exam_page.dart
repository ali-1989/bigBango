import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';

import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/controllers/examController.dart';
import 'package:app/structures/enums/quizType.dart';
import 'package:app/structures/injectors/examPageInjector.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_dialog_iris.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_navigator.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/views/components/exam/examBlankSpaseBuilder.dart';
import 'package:app/views/components/exam/examMakeSentenceBuilder.dart';
import 'package:app/views/components/exam/examOptionBuilder.dart';
import 'package:app/views/components/exam/examSelectWordBuilder.dart';

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
class _ExamPageState extends StateSuper<ExamPage> with TickerProviderStateMixin {
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
            child: buildExamView(),
          ),

          const SizedBox(height: 10),

          /// bottom, send button
          buildBottomSection(),

          const SizedBox(height: 10),
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
                const Text('آزمون').bold().fsR(4),
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

  Widget buildBottomSection() {
    if(!widget.injector.showSendButton){//answeredExamList.length == widget.injector.examList.length ||
      return const SizedBox();
    }

    return Builder(
      builder: (context) {
        if (widget.injector.examList.length < 2) {
          return ElevatedButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(200, 50),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(
                  horizontal: 0, vertical: -2),
              //shape: StadiumBorder()
            ),
            onPressed:  answeredExamList.contains(currentExam.id)? null : onSendExamAnswerClick,
            child: const Text('ثبت و بررسی').color(Colors.white).fsR(-2),
          );
        }

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Visibility(
                    visible: hasNextExam(),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black87,
                          ),
                          onPressed: onNextClick,
                          icon: RotatedBox(
                            quarterTurns: 2,
                            child: Image.asset(AppImages.arrowLeftIco)
                          ),
                          label: const Text('Next').fsR(-1)
                      ),
                    ),
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
                    visible: hasPrevExam(),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black87,
                        ),
                          onPressed: onPrevClick,
                          icon: const Text('Prev').fsR(-1),
                        label: Image.asset(AppImages.arrowLeftIco,),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(100, 50),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                    ),
                    onPressed: answeredExamList.contains(currentExam.id)? null : onSendExamAnswerClick,
                    child: const Text('ثبت و بررسی')
                        .color(Colors.white).fsR(-2),
                  ),
                ),
              ],
            ),
          ],
        );
      }
    );
  }

  bool hasNextExam(){
    return currentExamIndex < widget.injector.examList.length-1;
  }

  bool hasPrevExam(){
    return currentExamIndex > 0;
  }

  void onNextClick() {
    if(hasNextExam()){
      currentExamIndex++;
      currentExam = widget.injector.examList[currentExamIndex];

      examAnimController.reset();
      assistCtr.updateHead();
      examAnimController.forward();
    }
  }

  void onPrevClick() {
    if(hasPrevExam()){
      currentExamIndex--;
      currentExam = widget.injector.examList[currentExamIndex];

      examAnimController.reset();
      assistCtr.updateHead();
      examAnimController.forward();
    }
  }

  void onSendExamAnswerClick(){
    /*if(answeredExamList.contains(currentExam.id)){
      onNextClick();
      return;
    }*/

    if(widget.injector.askConfirmToSend && !answeredExamList.contains(currentExam.id)) {
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
      AppSnack.showSnackText(context, AppMessages.errorCommunicatingServer);
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
