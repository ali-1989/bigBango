import 'package:app/structures/enums/quizType.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/structures/models/examModels/examSuperModel.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/views/components/exam/examBlankSpaseBuilder.dart';
import 'package:app/views/components/exam/examMakeSentenceBuilder.dart';
import 'package:app/views/components/exam/examOptionBuilder.dart';
import 'package:app/views/components/exam/examSelectWordBuilder.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';

import 'package:app/pages/autodidact_builder.dart';
import 'package:app/pages/exam_builder.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/builders/examBuilderContent.dart';
import 'package:app/structures/controllers/examController.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appSnack.dart';

class ExamPage extends StatefulWidget {
  final ExamBuilderContent builder;

  const ExamPage({
    required this.builder,
    Key? key
  }) : super(key: key);

  @override
  State<ExamPage> createState() => _ExamPageState();
}
///======================================================================================================================
class _ExamPageState extends StateBase<ExamPage> with TickerProviderStateMixin {
  Requester requester = Requester();
  late TabController tabController;
  late ExamSuperModel currentExam;
  int currentIndex = 0;


  @override
  void initState(){
    super.initState();

    currentExam = widget.builder.examList.first;
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
          DecoratedBox(
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
          ),

          const SizedBox(height: 10),

          /// tabBar view
          Builder(
            builder: (ctx){
              if(widget.builder.autodidactList.isNotEmpty){
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


  Widget buildPage1(){
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
    if(currentExam is ExamModel){
      final model = currentExam as ExamModel;

      if(model.quizType == QuizType.fillInBlank){
        return ExamBlankSpaceBuilder(
          key: ValueKey(model.id),
          examModel: model,
        );
      }
      else if(model.quizType == QuizType.recorder){
        return ExamSelectWordBuilder(
          key: ValueKey(model.id),
          exam: model,
        );
      }
      else if(model.quizType == QuizType.multipleChoice){
        return ExamOptionBuilder(
          key: ValueKey(model.id),
          examModel: model,
        );
      }
      else if(model.quizType == QuizType.makeSentence){
        return ExamMakeSentenceBuilder(
          key: ValueKey(model.id),
          examModel: model,
        );
      }
    }

    return const SizedBox();
  }

  Widget buildBottomSectionPage1() {
    return Visibility(
        visible: widget.builder.showSendButton,
        child: Builder(
          builder: (context) {
            if (widget.builder.examList.length < 2) {
              return ElevatedButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(200, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: const VisualDensity(
                      horizontal: 0, vertical: -2),
                  //shape: StadiumBorder()
                ),
                onPressed: sendAnswer,
                child: Text(widget.builder.sendButtonText).englishFont().color(
                    Colors.white),
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
                    visualDensity: const VisualDensity(
                        horizontal: 0, vertical: -2),
                    //shape: StadiumBorder()
                  ),
                  onPressed: sendAnswer,
                  child: Text(widget.builder.sendButtonText).englishFont().color(
                      Colors.white),
                ),

                TextButton(
                    onPressed: onSkipClick,
                    child: const Text('skip')
                ),
              ],
            );
          }
        )
    );
    }

  void onSkipClick() {
    if(currentIndex < widget.builder.examList.length){
      currentIndex++;
      currentExam = widget.builder.examList[currentIndex];

      assistCtr.updateHead();
    }
  }

  Widget buildPage2(){
    return Column(
      children: [
        const SizedBox(height: 20),

        /// exams
        Expanded(child: AutodidactBuilder(builder: widget.builder)),

        const SizedBox(height: 10),
      ],
    );
  }

  void sendAnswer(){
    AppDialogIris.instance.showYesNoDialog(
      context,
      yesFn: (ctx) {
        Future.delayed(const Duration(milliseconds: 500)).then((value) {
          requestSendAnswer();
        });
      },
      desc: 'آیا جواب تمرین ارسال شود؟',
    );
  }

  void requestSendAnswer(){
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
      //bool sentResult = false; sentResult = true;

      final message = res['message']?? 'پاسخ تمرین ثبت شد';

      AppSnack.showInfo(context, message);

      for(final x in widget.builder.examList){
        ExamController.getControllerFor(x)?.showAnswer(true);
      }

      assistCtr.updateHead();
    };

    final tempList = [];
    final js = <String, dynamic>{};

    for(final x in widget.builder.examList){
      if(x.items.length < 2) {
        tempList.add({
          'exerciseId': x.getExamItem().id,
          'answer': x.getExamItem().getUserAnswerText(),
          'isCorrect': x.getExamItem().isUserAnswerCorrect(),
        });
      }
      else {
        for (final itm in x.items){
          tempList.add({
            'exerciseId': itm.id,
            'answer': itm.getUserAnswerText(),
            'isCorrect': itm.isUserAnswerCorrect(),
          });
        }
      }
    }

    js['items'] = tempList;

    requester.methodType = MethodType.post;
    requester.prepareUrl(pathUrl: widget.builder.answerUrl);
    requester.bodyJson = js;

    showLoading();
    requester.request(context);
  }
}


