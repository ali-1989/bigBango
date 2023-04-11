import 'package:app/structures/builders/examBuilderContent.dart';
import 'package:app/structures/controllers/examController.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/enums/quizType.dart';
import 'package:app/structures/builders/autodidactBuilderContent.dart';

import 'package:app/structures/models/examModels/autodidactModel.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/structures/models/examModels/examSuperModel.dart';
import 'package:app/tools/app/appToast.dart';
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
  ExamController examController = ExamController();
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
    examController.dispose();
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
      itemBuilder: buildExamViewBuGroup,
      separatorBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(color: Colors.black, height: 2),
        );
      },
    );
  }

  Widget buildExamViewBuGroup(_, int idx){
    ExamSuperModel model = itemListGroup[idx];

    if(model is ExamModel){
      if(model.quizType == QuizType.fillInBlank){
        return ExamBlankSpaceBuilder(
            key: ValueKey(model.id),
            content: widget.builder,
            controller: examController,
        );
      }
      else if(model.quizType == QuizType.recorder){
        return ExamSelectWordBuilder(
            key: ValueKey(model.id),
            content: widget.builder,
            controller: examController,
        );
      }
      else if(model.quizType == QuizType.multipleChoice){
        return ExamOptionBuilder(
            key: ValueKey(model.id),
            builder: widget.builder,
            controller: examController,
        );
      }
    }

    else if(model is AutodidactModel){
      /*final content = AutodidactBuilderContent();
      content.autodidactModel = model;

      if(model.text != null){
        return AutodidactTextComponent(content: content);
      }
      else if(model.voice != null){
        return AutodidactVoiceComponent(content: content);
      }*/
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
            controller: examController,
            showTitle: true,
            index: idx,
        );
      }
      else if(model.quizType == QuizType.recorder){
        return ExamSelectWordBuilder(
            key: ValueKey(model.id),
            content: widget.builder,
            controller: examController,
            index: idx
        );
      }
      else if(model.quizType == QuizType.multipleChoice){
        return ExamOptionBuilder(
            key: ValueKey(model.id),
            builder: widget.builder,
            controller: examController,
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

  void sendAnswer(){

    ExamModel exam = ExamModel();

    if(exam.quizType == QuizType.multipleChoice){
      if(!examController.isAnswerToAll()){
        AppToast.showToast(context, 'لطفا به سوالات پاسخ دهید');
        return;
      }
    }


    /*final js = <String, dynamic>{};
    js['items'] = [
      {
        'exerciseId' : exam.id,
        'answer' : exam.getUserAnswerText(),
        'isCorrect' : exam.isUserAnswerCorrect(),
      }
    ];*/

    /*requester.methodType = MethodType.post;
    requester.prepareUrl(pathUrl: widget.builder.answerUrl);
   */

    showLoading();
    //requester.request(context);
  }
}


