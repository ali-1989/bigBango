import 'package:app/structures/models/examModels/examSuperModel.dart';
import 'package:app/structures/enums/examDescription.dart';
import 'package:app/structures/enums/quizType.dart';
import 'package:app/structures/injectors/autodidactPageInjector.dart';
import 'package:app/structures/injectors/examPageInjector.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/structures/models/examModels/autodidactModel.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/views/components/autodidactTextComponent.dart';
import 'package:app/views/components/autodidactVoiceComponent.dart';
import 'package:app/views/components/examBlankSpaseComponent.dart';
import 'package:app/views/components/examOptionComponent.dart';
import 'package:app/views/components/examSelectWordComponent.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/views/widgets/customCard.dart';


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
class _ExamPageState extends StateBase<ExamPage> {
  Requester requester = Requester();
  int currentItemIdx = 0;
  List<ExamSuperModel> itemList = [];
  late ExamSuperModel currentExam;

  @override
  void initState(){
    super.initState();

    for (final element in widget.injector.examList) {
      if(!element.isPrepare) {
        element.prepare();
      }

      itemList.add(element);
    }

    for (final element in widget.injector.autodidactList) {
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
      title = ExamDescription.fromType((currentExam as ExamModel).exerciseType.number).getTypeHuman();
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
                    visible: currentExam is! AutodidactModel,
                    child: ElevatedButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity(horizontal: 0, vertical: -2),
                          shape: StadiumBorder()
                        ),
                        onPressed: sendAnswer,
                        child: Text('ارسال جواب').englishFont().color(Colors.white),
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
      if(model.exerciseType == QuizType.fillInBlank){
        return ExamBlankSpaceComponent(injector: widget.injector);
      }
      else if(model.exerciseType == QuizType.recorder){
        return ExamSelectWordComponent(injector: widget.injector);
      }
      else if(model.exerciseType == QuizType.multipleChoice){
        return ExamOptionComponent(injector: widget.injector);
      }
    }

    else if(model is AutodidactModel){
      final injector = AutodidactPageInjector();
      injector.autodidactModel = currentExam as AutodidactModel;
      injector.lessonModel = widget.injector.lessonModel;

      if(model.question == null){
        return AutodidactTextComponent(injector: injector);
      }
      else if(model.voice == null){
        return AutodidactVoiceComponent(injector: injector);
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

    if(exam.exerciseType == QuizType.multipleChoice){
      if(!widget.injector.state.isAllAnswer()){
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
      widget.injector.state.checkAnswers();
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
    requester.prepareUrl(pathUrl: widget.injector.answerUrl);
    requester.bodyJson = js;

    showLoading();
    requester.request(context);
  }
}


