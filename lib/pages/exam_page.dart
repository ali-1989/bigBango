import 'package:app/structures/contents/examBuilderContent.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/enums/examDescription.dart';
import 'package:app/structures/enums/quizType.dart';
import 'package:app/structures/contents/autodidactBuilderContent.dart';

import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/examModels/autodidactModel.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/structures/models/examModels/examSuperModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/views/components/exam/autodidactTextComponent.dart';
import 'package:app/views/components/exam/autodidactVoiceComponent.dart';
import 'package:app/views/components/exam/examBlankSpaseBuilder.dart';
import 'package:app/views/components/exam/examOptionBuilder.dart';
import 'package:app/views/components/exam/examSelectWordBuilder.dart';
import 'package:iris_tools/widgets/customCard.dart';

class ExamPage extends StatefulWidget {
  final ExamBuilderContent content;

  const ExamPage({
    required this.content,
    Key? key
  }) : super(key: key);

  @override
  State<ExamPage> createState() => _ExamPageState();
}
///======================================================================================================================
class _ExamPageState extends StateBase<ExamPage> {
  Requester requester = Requester();
  int currentItemIdx = 0;
  List<ExamSuperModel> itemList = [];
  late ExamSuperModel currentExam;

  @override
  void initState(){
    super.initState();

    for (final element in widget.content.examList) {
      if(!element.isPrepare) {
        element.prepare();
      }

      itemList.add(element);
    }

    for (final element in widget.content.autodidactList) {
      itemList.add(element);
    }

    currentExam = itemList[0];
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
    Color preColor = Colors.black;
    Color nextColor = Colors.black;
    String title = '';

    if(currentExam is ExamModel){
      title = ExamDescription.fromType((currentExam as ExamModel).quizType.number).getTypeHuman();
    }

    if(currentItemIdx == 0){
      preColor = Colors.grey;
    }

    if(currentItemIdx == itemList.length-1){
      nextColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(height: 20),

          DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
              ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 4,
                        height: 26,
                        child: ColoredBox(color: AppColors.red),
                      ),

                      SizedBox(width: 7),
                      Text('تمرین').bold().fsR(4),
                    ],
                  ),

                  GestureDetector(
                    onTap: (){
                      AppNavigator.pop(context);
                    },
                    child: Row(
                      children: [
                        Text(AppMessages.back),
                        SizedBox(width: 10),
                        CustomCard(
                            color: Colors.white,
                            padding: EdgeInsets.all(5),
                            child: Image.asset(AppImages.arrowLeftIco)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 10),

          /// progress bar
          Visibility(
            visible: itemList.length >1,
              child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: LinearProgressIndicator(value: calcProgress(), backgroundColor: AppColors.red.withAlpha(50))
              ),
          ),

          SizedBox(height: 10),

          /// title
          Row(
            children: [
              Text(title)
            ],
          ),
          SizedBox(height: 14),

          /// exam view
          Expanded(child: buildExamView(currentExam)),

          Visibility(
            visible: itemList.length > 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                      onPressed: onNextClick,
                      icon: RotatedBox(
                          quarterTurns: 2,
                          child: Image.asset(AppImages.arrowLeftIco, color: nextColor)
                      ),
                      label: Text('next').englishFont().color(nextColor)
                  ),

                  Visibility(
                    visible: widget.content.showSendButton,
                    child: ElevatedButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity(horizontal: 0, vertical: -2),
                          shape: StadiumBorder()
                        ),
                        onPressed: sendAnswer,
                        child: Text(widget.content.sendButtonText).englishFont().color(Colors.white),
                    ),
                  ),

                  TextButton.icon(
                      style: TextButton.styleFrom(),
                      onPressed: onPreClick,
                      icon: Text('pre').englishFont().color(preColor),
                      label: Image.asset(AppImages.arrowLeftIco, color: preColor)
                  ),
                ],
              ),
          ),
        ],
      ),
    );
  }

  Widget buildExamView(ExamSuperModel model){
    if(model is ExamModel){
      if(model.quizType == QuizType.fillInBlank){
        return ExamBlankSpaceBuilder(content: widget.content);
      }
      else if(model.quizType == QuizType.recorder){
        return ExamSelectWordBuilder(content: widget.content);
      }
      else if(model.quizType == QuizType.multipleChoice){
        return ExamOptionBuilder(content: widget.content);
      }
    }

    else if(model is AutodidactModel){
      final injector = AutodidactBuilderContent();
      injector.autodidactModel = currentExam as AutodidactModel;

      if(model.question == null){
        return AutodidactTextComponent(content: injector);
      }
      else if(model.voice == null){
        return AutodidactVoiceComponent(content: injector);
      }
    }

    return SizedBox();
  }

  double calcProgress(){
    int r = ((currentItemIdx+1) * 100) ~/ itemList.length;
    return r/100;
  }

  void onNextClick(){
    if(currentItemIdx < itemList.length-1) {
      currentItemIdx++;

      currentExam = itemList[currentItemIdx];
      assistCtr.updateHead();
    }
  }

  void onPreClick(){
    if(currentItemIdx > -1){
      currentItemIdx--;

      currentExam = itemList[currentItemIdx];
      assistCtr.updateHead();
    }
  }

  void sendAnswer(){
    if(currentExam is! ExamModel){
      return;
    }

    ExamModel exam = currentExam as ExamModel;

    if(exam.quizType == QuizType.multipleChoice){
      if(!widget.content.controller.isAnswerToAll()){
        AppToast.showToast(context, 'لطفا یک گزینه را انتخاب کنید');
        return;
      }
    }

    requester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, res) async {
      AppSnack.showSnack$errorCommunicatingServer(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final message = res['message']?? 'پاسخ شما ثبت شد';

      AppSnack.showInfo(context, message);
      widget.content.controller.showAnswers(true);
    };

    final js = <String, dynamic>{};
    js['items'] = [
      {
        'exerciseId' : exam.id,
        'answer' : exam.getUserAnswerText(),
        'isCorrect' : exam.isUserAnswerCorrect(),
      }
    ];

    requester.methodType = MethodType.post;
    requester.prepareUrl(pathUrl: widget.content.answerUrl);
    requester.bodyJson = js;

    showLoading();
    requester.request(context);
  }
}


