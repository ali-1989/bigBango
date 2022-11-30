import 'package:app/tools/app/appToast.dart';
import 'package:flutter/material.dart';

import 'package:animator/animator.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/injectors/examInjector.dart';
import 'package:app/structures/interfaces/examStateInterface.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';

class ExamOptionComponent extends StatefulWidget {
  final ExamInjector injector;

  const ExamOptionComponent({
    required this.injector,
    Key? key
  }) : super(key: key);

  @override
  State<ExamOptionComponent> createState() => _ExamOptionComponentState();
}
///======================================================================================================================
class _ExamOptionComponentState extends StateBase<ExamOptionComponent> implements ExamStateInterface {
  Map<String, int?> selectedAnswers = {};
  bool showAnswers = false;
  int currentExamIdx = 0;
  late TextStyle questionNormalStyle;

  @override
  void initState(){
    super.initState();

    widget.injector.state = this;
    questionNormalStyle = TextStyle(fontSize: 16, color: Colors.black);
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
        builder: (ctx, ctr, data){
          return buildBody();
        }
    );
  }

  Widget buildBody(){
    Color preColor = Colors.black;
    Color nextColor = Colors.black;

    if(currentExamIdx <= 0){
      preColor = Colors.grey;
    }

    if(currentExamIdx >= widget.injector.examList.length-1){
      nextColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [

          /// progress bar
          Visibility(
            visible: widget.injector.examList.length > 1,
            child: Directionality(
                textDirection: TextDirection.ltr,
                child: LinearProgressIndicator(value: calcProgress(), backgroundColor: AppColors.red.withAlpha(50))
            ),
          ),

          /// exam
          Directionality(
            textDirection: TextDirection.ltr,
            child: ListView(
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              children: [
                ...buildQuestionAndOptions()
              ],
            ),
          ),


          SizedBox(height: 10),

          /// next, pre buttons
          Visibility(
            visible: widget.injector.examList.length > 1,
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

  List<Widget> buildQuestionAndOptions(){
    final res = <Widget>[];
    final curExam = widget.injector.examList[currentExamIdx];

    final questionWidget = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(5)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Text(
            curExam.question,
            style: TextStyle(fontSize: 12, height: 1.7),
          textAlign: TextAlign.justify,
        ),
      ).wrapDotBorder(
        color: Colors.grey.shade600,
        radius: 5,
      ),
    );

    res.add(SizedBox(height: 20));
    res.add(questionWidget);
    res.add(SizedBox(height: 20));


    for(final opt in curExam.choices){
      final w = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          if(showAnswers){
            return;
          }

          final optionIdx = curExam.choices.indexOf(opt);
          bool isSelected = selectedAnswers[curExam.id] == optionIdx;

          if(isSelected){
            selectedAnswers[curExam.id] = null;
          }
          else {
            selectedAnswers[curExam.id] = optionIdx;
          }

          assistCtr.updateMain();
        },
        child: AnimateWidget(
          resetOnRebuild: true,
          triggerOnRebuild: true,
          duration: Duration(milliseconds: 400),
          cycles: 1,
          builder: (_, animate){
            final optionIdx = curExam.choices.indexOf(opt);
            bool isSelected = selectedAnswers[curExam.id] == optionIdx;
            bool isCorrect = optionIdx == widget.injector.examList[currentExamIdx].getCorrectChoiceIndex();

            Color backColor;

            if(showAnswers){
              if(isCorrect){
                backColor = Colors.green;
              }
              else {
                backColor = Colors.redAccent;
              }
            }
            else {
              backColor = animate.fromTween((v) => ColorTween(begin: Colors.teal, end:Colors.lightBlueAccent))!;
            }

            TextStyle selectStl = TextStyle(color: Colors.white, fontWeight: FontWeight.w700);
            TextStyle unSelectStl = TextStyle(color: Colors.black87);

            return DecoratedBox(
              decoration: BoxDecoration(
                  color: (isSelected || (!isSelected && showAnswers && isCorrect))? backColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(5)
              ),
              child: Row(
                children: [
                  Text('  ${optionIdx+1} -  ', style: (isSelected || (!isSelected && showAnswers && isCorrect))? selectStl : unSelectStl).englishFont(),
                  Text(opt.text, style: (isSelected || (!isSelected && showAnswers && isCorrect))? selectStl : unSelectStl).englishFont(),
                ],
              ).wrapBoxBorder(
                  color: Colors.black,
                  alpha: 100,
                  radius: 5,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 5)
              ),
            );
          },
        ),
      );

      res.add(SizedBox(height: 10));
      res.add(w);
    }

    return res;
  }

  bool isAllAnswer(){
    for(final k in widget.injector.examList){
      if(selectedAnswers[k.id] == null){
        return false;
      }
    }

    return true;
  }

  void onNextClick(){
    if(currentExamIdx < widget.injector.examList.length-1) {
      currentExamIdx++;
    }

    assistCtr.updateMain();
  }

  void onPreClick(){
    if(currentExamIdx > 0) {
      currentExamIdx--;
      assistCtr.updateMain();
    }
  }

  double calcProgress(){
    int r = ((currentExamIdx+1) * 100) ~/ widget.injector.examList.length;
    return r/100;
  }

  @override
  void checkAnswers() {
    if(selectedAnswers.isEmpty || selectedAnswers.length < currentExamIdx){
      AppToast.showToast(context, 'لطفا یک گزینه را انتخاب کنید');
      return;
    }

    showAnswers = !showAnswers;
    assistCtr.updateMain();
  }
}


