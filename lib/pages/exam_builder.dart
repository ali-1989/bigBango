import 'package:app/views/components/exam/examMakeSentenceBuilder.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/builders/examBuilderContent.dart';
import 'package:app/structures/enums/quizType.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/structures/models/examModels/examSuperModel.dart';
import 'package:app/views/components/exam/examBlankSpaseBuilder.dart';
import 'package:app/views/components/exam/examOptionBuilder.dart';
import 'package:app/views/components/exam/examSelectWordBuilder.dart';

class ExamBuilder extends StatefulWidget {
  final ExamBuilderContent builder;

  const ExamBuilder({
    required this.builder,
    Key? key
  }) : super(key: key);

  @override
  State<ExamBuilder> createState() => _ExamBuilderState();
}
///======================================================================================================================
class _ExamBuilderState extends StateBase<ExamBuilder> {
  List<ExamSuperModel> itemList = [];
  List<ExamSuperModel> itemListGroup = [];

  @override
  void initState(){
    super.initState();

    for (final element in widget.builder.examList) {
      if(!element.isPrepare) {
        element.prepare();
      }

      itemList.add(element);

      /*if(widget.groupSameTypes){
        bool existType = itemListGroup.indexWhere((elm){return (elm as ExamModel).quizType == element.quizType;}) > -1;

        if(!existType){
          itemListGroup.add(element);
        }
      }*/
    }
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
          return /*widget.groupSameTypes?*/ buildBody();
        }
    );
  }

  /*Widget buildBody() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: itemList.length,
      itemBuilder: buildExamView,
      separatorBuilder: (BuildContext context, int index) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(color: Colors.black, height: 2),
        );
      },
    );
  }*/

  Widget buildBody() {
    return Column(
      children: [


      ],
    );
  }

  Widget buildExamView(_, int idx){
    ExamSuperModel model = itemList[idx];

    if(model is ExamModel){
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

}