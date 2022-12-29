import 'package:app/structures/enums/autodidactReplyType.dart';
import 'package:app/structures/injectors/autodidactPageInjector.dart';
import 'package:app/structures/models/autodidactModel.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/views/widgets/customCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/system/extensions.dart';

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
///=================================================================================================================
class AutodidactTextComponentState extends StateBase<AutodidactTextComponent> implements ExamStateInterface {
  late AutodidactModel model;

  @override
  void initState(){
    super.initState();

    model = widget.injector.autodidactModel;
    widget.injector.state = this;
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
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  Image.asset(AppImages.doubleArrow),
                  SizedBox(width: 4),
                  Text(model.question?? ''),
                ],
              ),
              SizedBox(height: 20),

              Directionality(
                textDirection: TextDirection.ltr,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 15),
                  child: Text(model.text!).englishFont().fsR(-1),
                ).wrapDotBorder(
                    color: Colors.black12,
                    alpha: 100,
                    dashPattern: [4,8]),
              ),

              SizedBox(height: 30),
              buildReply()
            ],
          ),
        ),

        ElevatedButton(
          onPressed: showAnswer,
          child: Text('نمایش پاسخ'),
        ),

        SizedBox(height: 10),
      ],
    );
  }

  Widget buildReply(){
    if(model.replyType != AutodidactReplyType.text){
      return buildTextReply();
    }

    return buildMicReply();
  }

  Widget buildTextReply(){
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          minLines: 4,
          maxLines: 6,
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ).wrapDotBorder(
          color: Colors.black,
          alpha: 100,
          dashPattern: [4,8]
      ),
    );
  }

  Widget buildMicReply(){
    return Column(
      children: [
        CustomCard(
          color: AppColors.red,
            radius: 50,
            padding: EdgeInsets.all(10),
            child: Image.asset(AppImages.mic)
        ),
      ],
    );
  }

  void showAnswer(){
    final w = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: CustomCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            children: [
              Text('پاسخ استاد').bold().fsR(4),
              SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      model.correctAnswer?? '',
                    ).englishFont(),
                  ),
                ),
              ).wrapDotBorder(
                  color: Colors.black,
                  alpha: 100,
                  dashPattern: [4,8]
              ),

              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: (){
                      AppRoute.popTopView(context);
                    },
                    child: Text('بستن')
                ),
              ),
            ],
          ),
        ),
      ),
    );

    AppSheet.showSheetCustom(
        context,
        builder: (ctx){
          return w;
        },
        routeName: 'showAnswer',
      contentColor: Colors.transparent,
      isScrollControlled: true,
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


