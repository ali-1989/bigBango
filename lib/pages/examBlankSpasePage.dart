import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/lessonModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/views/customCard.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:simple_html_css/simple_html_css.dart';

class ExamBlankSpacePageInjection {
  late LessonModel lessonModel;
  late String segmentTitle;
}
///-----------------------------------------------------
class ExamBlankSpacePage extends StatefulWidget {
  final ExamBlankSpacePageInjection injection;

  const ExamBlankSpacePage({
    required this.injection,
    Key? key
  }) : super(key: key);

  @override
  State<ExamBlankSpacePage> createState() => _ExamBlankSpacePageState();
}
///======================================================================================================================
class _ExamBlankSpacePageState extends StateBase<ExamBlankSpacePage> {

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
                        child: ColoredBox(color: Colors.red),
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
              Text(' جای خالی را پر کنید')
            ],
          ),
          SizedBox(height: 14),

          /// exam
          Expanded(
              child: ListView(
                children: [

                ],
              )
          ),



          SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
              ),
              onPressed: (){

              },
              child: Text('ثبت و بررسی'),
            ),
          ),
          SizedBox(height: 14),
        ],
      ),
    );
  }
}
