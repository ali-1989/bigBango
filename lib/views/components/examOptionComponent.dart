import 'package:app/structures/enums/quizType.dart';
import 'package:app/structures/models/examModel.dart';
import 'package:flutter/material.dart';

import 'package:animator/animator.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/injectors/examInjector.dart';
import 'package:app/structures/interfaces/examStateInterface.dart';
import 'package:app/system/extensions.dart';


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
  //Map<String, int?> selectedAnswers = {};
  List<ExamModel> examList = [];
  bool showAnswers = false;
  late TextStyle questionNormalStyle;

  @override
  void initState(){
    super.initState();

    widget.injector.state = this;
    examList.addAll(widget.injector.examList.where((element) => element.exerciseType == QuizType.multipleChoice));
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [

          /// exam
          Directionality(
            textDirection: TextDirection.ltr,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemCount: examList.length *2 -1,
              itemBuilder: buildQuestionAndOptions,
            ),
          ),


          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget buildQuestionAndOptions(_, int idx){
    ///=== Divider
    if(idx % 2 != 0){
      return Divider(color: Colors.black, height: 2);
    }

    final curExam = examList[idx~/2];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        DecoratedBox(
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
        ),

        SizedBox(height: 10),
        ...buildOptions(curExam),
        SizedBox(height: 20)
      ],
    );
  }

  List<Widget> buildOptions(ExamModel curExam){
    List<Widget> res = [];

    for(final opt in curExam.choices){
      final w = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          if(showAnswers){
            return;
          }

          bool isSelected = curExam.getUserChoiceById(opt.id) != null;

          if(isSelected){
            curExam.userAnswers.removeWhere((element) => element.id == opt.id);
          }
          else {
            final ex = ExamChoiceModel()..order = opt.order;
            ex.id = opt.id;

            curExam.userAnswers.clear();
            curExam.userAnswers.add(ex);
          }

          assistCtr.updateHead();
        },
        child: AnimateWidget(
          resetOnRebuild: true,
          triggerOnRebuild: true,
          duration: Duration(milliseconds: 400),
          cycles: 1,
          builder: (_, animate){
            final optionIdx = curExam.choices.indexOf(opt);
            bool isSelected = curExam.getUserChoiceById(opt.id) != null;
            bool isCorrect = optionIdx == curExam.getIndexOfCorrectChoice();

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
    for(final k in examList){
      if(k.userAnswers.isEmpty){
        return false;
      }
    }

    return true;
  }

  @override
  void checkAnswers() {
    /*if(selectedAnswers.isEmpty || selectedAnswers.length < currentExamIdx){
      AppToast.showToast(context, 'لطفا یک گزینه را انتخاب کنید');
      return;
    }*/

    showAnswers = !showAnswers;
    assistCtr.updateHead();
  }
}


