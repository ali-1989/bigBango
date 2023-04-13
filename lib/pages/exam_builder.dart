import 'package:app/structures/builders/examBuilderContent.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/enums/quizType.dart';
import 'package:app/structures/builders/autodidactBuilderContent.dart';

import 'package:app/structures/models/examModels/autodidactModel.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/structures/models/examModels/examSuperModel.dart';
import 'package:app/views/components/exam/autodidactTextComponent.dart';
import 'package:app/views/components/exam/autodidactVoiceComponent.dart';
import 'package:app/views/components/exam/examBlankSpaseBuilder.dart';
import 'package:app/views/components/exam/examOptionBuilder.dart';
import 'package:app/views/components/exam/examSelectWordBuilder.dart';

class ExamBuilder extends StatefulWidget {
  final ExamBuilderContent builder;
  final bool groupSameTypes;

  const ExamBuilder({
    required this.builder,
    this.groupSameTypes = true,
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

      if(widget.groupSameTypes){
        bool existType = itemListGroup.indexWhere((elm){return (elm as ExamModel).quizType == element.quizType;}) > -1;

        if(!existType){
          itemListGroup.add(element);
        }
      }
    }

    for (final element in widget.builder.autodidactList) {
      itemList.add(element);
      itemListGroup.add(element);
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
          return widget.groupSameTypes? buildBodyByGroup(): buildBodyWithoutGroup();
        }
    );
  }

  Widget buildBodyByGroup() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: itemListGroup.length,
      itemBuilder: buildExamViewByGroup,
      separatorBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(color: Colors.black, height: 2),
        );
      },
    );
  }

  Widget buildExamViewByGroup(_, int idx){
    ExamSuperModel model = itemListGroup[idx];

    if(model is ExamModel){
      if(model.quizType == QuizType.fillInBlank){
        return ExamBlankSpaceBuilder(
            key: ValueKey(model.id),
            content: widget.builder,
            controllerId: model.id,
        );
      }
      else if(model.quizType == QuizType.recorder){
        return ExamSelectWordBuilder(
            key: ValueKey(model.id),
            content: widget.builder,
            controllerId: model.id,
        );
      }
      else if(model.quizType == QuizType.multipleChoice){
        return ExamOptionBuilder(
            key: ValueKey(model.id),
            builder: widget.builder,
            controllerId: model.id,
        );
      }
    }

    else if(model is AutodidactModel){
      final content = AutodidactBuilderContent();
      content.autodidactModel = model;

      if(model.text != null){
        return AutodidactTextComponent(content: content);
      }
      else if(model.voice != null){
        return AutodidactVoiceComponent(content: content);
      }
    }

    return SizedBox();
  }

  Widget buildBodyWithoutGroup() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: itemList.length,
      itemBuilder: buildExamView,
      separatorBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(color: Colors.black, height: 2),
        );
      },
    );
  }

  Widget buildExamView(_, int idx){
    ExamSuperModel model = itemList[idx];

    if(model is ExamModel){
      if(model.quizType == QuizType.fillInBlank){
        return ExamBlankSpaceBuilder(
            key: ValueKey(model.id),
            content: widget.builder,
            controllerId: model.id,
            showTitle: true,
            index: idx,
        );
      }
      else if(model.quizType == QuizType.recorder){
        return ExamSelectWordBuilder(
            key: ValueKey(model.id),
            content: widget.builder,
            controllerId: model.id,
            index: idx
        );
      }
      else if(model.quizType == QuizType.multipleChoice){
        return ExamOptionBuilder(
            key: ValueKey(model.id),
            builder: widget.builder,
            controllerId: model.id,
            showTitle: true,
            index: idx
        );
      }
    }

    else if(model is AutodidactModel){
      final content = AutodidactBuilderContent();
      content.autodidactModel = model;

      if(model.text != null){
        return AutodidactTextComponent(content: content);
      }
      else if(model.voice != null){
        return AutodidactVoiceComponent(content: content);
      }
    }

    return SizedBox();
  }
}


