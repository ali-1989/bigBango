import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/builders/autodidactBuilderContent.dart';
import 'package:app/structures/builders/examBuilderContent.dart';
import 'package:app/structures/models/examModels/autodidactModel.dart';
import 'package:app/structures/models/examModels/examSuperModel.dart';
import 'package:app/views/components/exam/autodidactTextComponent.dart';
import 'package:app/views/components/exam/autodidactVoiceComponent.dart';

class AutodidactBuilder extends StatefulWidget {
  final ExamBuilderContent builder;

  const AutodidactBuilder({
    required this.builder,
    Key? key
  }) : super(key: key);

  @override
  State<AutodidactBuilder> createState() => _AutodidactBuilderState();
}
///======================================================================================================================
class _AutodidactBuilderState extends StateBase<AutodidactBuilder> {
  List<AutodidactModel> itemList = [];

  @override
  void initState(){
    super.initState();

    for (final element in widget.builder.autodidactList) {
      itemList.add(element);
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
          return buildBody();
        }
    );
  }

  Widget buildBody() {
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

    if(model is AutodidactModel){
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


