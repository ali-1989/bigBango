import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/injectors/examPageInjector.dart';
import 'package:app/structures/models/examModels/autodidactModel.dart';
import 'package:app/structures/models/examModels/examSuperModel.dart';
import 'package:app/views/components/exam/autodidactTextComponent.dart';
import 'package:app/views/components/exam/autodidactVoiceComponent.dart';

class AutodidactBuilder extends StatefulWidget {
  final ExamPageInjector builder;

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
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(color: Colors.black, height: 2),
        );
      },
    );
  }

  Widget buildExamView(_, int idx){
    ExamSuperModel model = itemList[idx];

    if(model is AutodidactModel){

      if(model.text != null){
        return AutodidactTextComponent(model: model);
      }
      else if(model.voice != null){
        return AutodidactVoiceComponent(model: model);
      }
    }

    return const SizedBox();
  }
}


