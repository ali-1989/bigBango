import 'package:animate_do/animate_do.dart';
import 'package:app/structures/enums/quizType.dart';
import 'package:app/structures/models/examModels/autodidactModel.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/views/components/exam/autodidactTextComponent.dart';
import 'package:app/views/components/exam/autodidactVoiceComponent.dart';
import 'package:app/views/components/exam/examBlankSpaseBuilder.dart';
import 'package:app/views/components/exam/examMakeSentenceBuilder.dart';
import 'package:app/views/components/exam/examOptionBuilder.dart';
import 'package:app/views/components/exam/examSelectWordBuilder.dart';
import 'package:flutter/material.dart';

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
  late TabController tabController;
  late ExamModel currentExam;
  late AutodidactModel currentAutodidact;
  int currentExamIndex = 0;
  int currentAutodidactIndex = 0;
  List<String> answeredExamList = [];
  List<String> answeredAutodidactList = [];

  @override
  void initState(){
    super.initState();

    currentExam = widget.injector.examList.first;
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose(){
    super.dispose();

    requester.dispose();
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

          /// tabBar view
          Builder(
            builder: (ctx){
              if(widget.injector.examList.isNotEmpty && widget.injector.autodidactList.isNotEmpty){
                return TabBar(
                  controller: tabController,
                  tabs: const [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('تمرین'),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('خودآموز'),
                    ),
                  ],
                );
              }

              return const SizedBox();
            },
          ),

          /// body view
          Expanded(
            child: TabBarView(
                controller: tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  buildPage1(),

                  buildPage2(),
                ]
            ),
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
      duration: const Duration(milliseconds: 400),
      child: Builder(
          builder: (_){
            if(currentExam.quizType == QuizType.fillInBlank){
              return Column(
                children: [
                  const Text(ExamBlankSpaceBuilder.questionTitle),
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
                children: [
                  const Text(ExamSelectWordBuilder.questionTitle),
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
                children: [
                  const Text(ExamOptionBuilder.questionTitle),
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
            child: Text(AppMessages.send)
                .englishFont().color(Colors.white),
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            ElevatedButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(100, 40),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                //shape: StadiumBorder()
              ),
              onPressed: onSendExamAnswerClick,
              child: Text(answeredExamList.contains(currentExam.id) ? AppMessages.send : AppMessages.next)
                  .englishFont().color(Colors.white),
            ),

            Visibility(
              visible: currentExamIndex < widget.injector.examList.length-1,
              child: TextButton(
                  onPressed: onExamSkipClick,
                  child: const Text('skip')
              ),
            ),
          ],
        );
      }
    );
    }

  void onExamSkipClick() {
    if(currentExamIndex < widget.injector.examList.length){
      currentExamIndex++;
      currentExam = widget.injector.examList[currentExamIndex];

      assistCtr.updateHead();
    }
  }

  Widget buildPage2(){
    if(widget.injector.autodidactList.isEmpty){
      return const SizedBox();
    }

    return Column(
      children: [
        const SizedBox(height: 20),

        /// exams
        Expanded(child: buildAutodidactView()),

        const SizedBox(height: 10),
      ],
    );
  }

  Widget buildAutodidactView(){
    return FadeIn(
      animate: true,
      duration: const Duration(milliseconds: 400),
      child: Builder(
          builder: (_){
            if(currentAutodidact.text != null){
              return Column(
                children: [
                  const Text(ExamBlankSpaceBuilder.questionTitle),
                  const SizedBox(height: 20),

                  AutodidactTextComponent(model: currentAutodidact),
                ],
              );
            }
            else if(currentAutodidact.voice != null){
              return Column(
                children: [
                  const Text(ExamBlankSpaceBuilder.questionTitle),
                  const SizedBox(height: 20),

                  AutodidactVoiceComponent(model: currentAutodidact),
                ],
              );
            }

            return const SizedBox();
          }
      ),
    );
  }

  void onSendExamAnswerClick(){
    AppDialogIris.instance.showYesNoDialog(
      context,
      yesFn: (ctx) {
        Future.delayed(const Duration(milliseconds: 500)).then((value) {
          requestSendExamAnswer();
        });
      },
      desc: 'آیا جواب تمرین ارسال شود؟',
    );
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

      AppSnack.showInfo(context, message);

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
          'answer': itm.getUserAnswerText(),
          'isCorrect': itm.isUserAnswerCorrect(),
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
