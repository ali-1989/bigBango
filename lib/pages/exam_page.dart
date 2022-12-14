import 'package:app/structures/enums/examDescription.dart';
import 'package:app/structures/enums/quizType.dart';
import 'package:app/structures/injectors/examInjector.dart';
import 'package:app/structures/models/examModel.dart';
import 'package:app/views/components/examBlankSpaseComponent.dart';
import 'package:app/views/components/examOptionComponent.dart';
import 'package:app/views/components/examSelectWordComponent.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/views/widgets/customCard.dart';


class ExamPage extends StatefulWidget {
  final ExamInjector injector;

  const ExamPage({
    required this.injector,
    Key? key
  }) : super(key: key);

  @override
  State<ExamPage> createState() => _ExamPageState();
}
///======================================================================================================================
class _ExamPageState extends StateBase<ExamPage> {

  @override
  void initState(){
    super.initState();
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
          return Scaffold(
            body: SafeArea(
                child: buildBody()
            ),
          );
        }
    );
  }

  Widget buildBody(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(height: 20),

          DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
              ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 4,
                        height: 26,
                        child: ColoredBox(color: AppColors.red),
                      ),

                      SizedBox(width: 7),
                      Text('تمرین').bold().fsR(4),
                    ],
                  ),

                  GestureDetector(
                    onTap: (){
                      AppNavigator.pop(context);
                    },
                    child: Row(
                      children: [
                        Text(AppMessages.back),
                        SizedBox(width: 10),
                        CustomCard(
                            color: Colors.white,
                            padding: EdgeInsets.all(5),
                            child: Image.asset(AppImages.arrowLeftIco)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 10),
          Row(
            children: [
              Text(ExamDescription.from(widget.injector.examList[0].exerciseType.type()).getText())
            ],
          ),
          SizedBox(height: 14),

          /// exam
          Expanded(child: buildExamView(widget.injector.examList[0])),
        ],
      ),
    );
  }

  Widget buildExamView(ExamModel examModel){
    if(examModel.exerciseType == QuizType.fillInBlank){
      return ExamBlankSpaceComponent(injector: widget.injector);
    }
    else if(examModel.exerciseType == QuizType.recorder){
      return ExamSelectWordComponent(injector: widget.injector);
    }
    else if(examModel.exerciseType == QuizType.multipleChoice){
      return ExamOptionComponent(injector: widget.injector);
    }

    return SizedBox();
  }

}


