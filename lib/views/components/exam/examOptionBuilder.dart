import 'package:app/structures/contents/examBuilderContent.dart';
import 'package:app/structures/controllers/examController.dart';
import 'package:flutter/material.dart';

import 'package:animator/animator.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/enums/quizType.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/system/extensions.dart';

class ExamOptionBuilder extends StatefulWidget {
  final ExamBuilderContent content;
  final ExamController controller;
  final int? index;

  const ExamOptionBuilder({
    required this.content,
    required this.controller,
    this.index,
    Key? key
  }) : super(key: key);

  @override
  State<ExamOptionBuilder> createState() => _ExamOptionBuilderState();
}
///==============================================================================================================
class _ExamOptionBuilderState extends StateBase<ExamOptionBuilder>{
  List<ExamModel> examList = [];
  late TextStyle questionNormalStyle;

  @override
  void initState(){
    super.initState();

    if(widget.index == null) {
      examList.addAll(widget.content.examList.where((element) => element.quizType == QuizType.multipleChoice));
    }
    else {
      examList.add(widget.content.examList[widget.index!]);
    }

    questionNormalStyle = TextStyle(fontSize: 16, color: Colors.black);
    widget.controller.init(showAnswer, showAnswers, isAnswerToAll, null);
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
          Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemCount: examList.length *2 -1,
                itemBuilder: buildQuestionAndOptions,
              ),
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
      key: ValueKey(curExam.id),
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

    for(final opt in curExam.options){
      final w = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          if(curExam.showAnswer){
            return;
          }

          bool isSelected = curExam.getUserChoiceById(opt.id) != null;

          if(isSelected){
            curExam.userAnswers.removeWhere((element) => element.id == opt.id);
          }
          else {
            final ex = ExamOptionModel()..order = opt.order;
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
            final optionIdx = curExam.options.indexOf(opt);
            bool isSelected = curExam.getUserChoiceById(opt.id) != null;
            bool isCorrect = optionIdx == curExam.getIndexOfCorrectChoice();

            Color backColor;

            if(curExam.showAnswer){
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
                  color: (isSelected || (!isSelected && curExam.showAnswer && isCorrect))? backColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(5)
              ),
              child: Row(
                children: [
                  Text('  ${optionIdx+1} -  ', style: (isSelected || (!isSelected && curExam.showAnswer && isCorrect))? selectStl : unSelectStl).englishFont(),
                  Text(opt.text, style: (isSelected || (!isSelected && curExam.showAnswer && isCorrect))? selectStl : unSelectStl).englishFont(),
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

  bool isAnswerToAll(){
    for(final k in examList){
      if (k.userAnswers.isEmpty) {
        return false;
      }
    }

    return true;
  }

  void showAnswers(bool state) {
    for (final element in examList) {
      element.showAnswer = state;
    }

    assistCtr.updateHead();
  }

  void showAnswer(String examId, bool state) {
    for (final element in examList) {
      if(element.id == examId){
        element.showAnswer = state;
        break;
      }
    }

    assistCtr.updateHead();
  }
}

