import 'package:app/structures/injectors/autodidactPageInjector.dart';
import 'package:app/structures/models/autodidactModel.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';

import 'package:app/structures/interfaces/examStateInterface.dart';

class AutodidactTextComponent extends StatefulWidget {
  final AutodidactPageInjector injector;

  const AutodidactTextComponent({
    required this.injector,
    Key? key
  }) : super(key: key);

  @override
  State<AutodidactTextComponent> createState() => AutodidactTextComponentState();
}
///======================================================================================================================
class AutodidactTextComponentState extends StateBase<AutodidactTextComponent> implements ExamStateInterface {
  late TextStyle questionNormalStyle;
  late AutodidactModel model;

  @override
  void initState(){
    super.initState();

    model = widget.injector.autodidactModel;
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        children: [

        ],
      ),
    );
  }

  Widget listItemBuilder(){

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text('ff')
    );
  }

  @override
  bool isAllAnswer(){
    return true;
  }

  @override
  void checkAnswers() {
  }
}


