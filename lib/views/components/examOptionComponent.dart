import 'package:animator/animator.dart';
import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/examModel.dart';
import 'package:app/models/lessonModels/iSegmentModel.dart';
import 'package:app/models/lessonModels/lessonModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

class ExamOptionInjector {
  late LessonModel lessonModel;
  late ISegmentModel segment;
}
///-----------------------------------------------------
class ExamOptionComponent extends StatefulWidget {
  final ExamOptionInjector injector;

  const ExamOptionComponent({
    required this.injector,
    Key? key
  }) : super(key: key);

  @override
  State<ExamOptionComponent> createState() => _ExamOptionComponentState();
}
///======================================================================================================================
class _ExamOptionComponentState extends StateBase<ExamOptionComponent> {
  List<ExamModel> examItems = [];
  Map<int, int?> selectedAnswer = {};
  bool showAnswers = false;
  int currentExamIdx = 0;
  late TextStyle questionNormalStyle;

  @override
  void initState(){
    super.initState();

    questionNormalStyle = TextStyle(fontSize: 16, color: Colors.black);

    List.generate(10, (index) {
      final m = ExamModel()..id = index;
      m.question = Generator.generateWords(20, 2, 10);

      for(int i=0; i<4; i++){
        final ec = ExamChoiceModel();
        ec.text = Generator.generateWords(5, 2, 7);

        m.choices.add(ec);
      }

      examItems.add(m);
    });
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
    Color preColor = Colors.black;
    Color nextColor = Colors.black;

    if(currentExamIdx <= 0){
      preColor = Colors.grey;
    }

    if(currentExamIdx >= examItems.length-1){
      nextColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          /// progress bar
          Directionality(
              textDirection: TextDirection.ltr,
              child: LinearProgressIndicator(value: calcProgress(), backgroundColor: AppColors.red.withAlpha(50))
          ),

          /// exam
          Expanded(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: ListView(
                  children: [
                    ...buildQuestion()
                  ],
                ),
              )
          ),


          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                  onPressed: onNextClick,
                  icon: RotatedBox(
                      quarterTurns: 2,
                      child: Image.asset(AppImages.arrowLeftIco, color: nextColor)
                  ),
                  label: Text('next').englishFont().color(nextColor)
              ),

              TextButton.icon(
                  style: TextButton.styleFrom(),
                  onPressed: onPreClick,
                  icon: Text('pre').englishFont().color(preColor),
                  label: Image.asset(AppImages.arrowLeftIco, color: preColor)
              ),
            ],
          ),

          SizedBox(height: 2),

          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
              ),
              onPressed: isAllAnswer()? onCheckClick : null,
              child: Text('ثبت و بررسی'),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  List<Widget> buildQuestion(){
    final res = <Widget>[];
    final itm = examItems[currentExamIdx];

    final q = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(5)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Text(
            itm.question,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w200, height: 1.7),
          textAlign: TextAlign.justify,
        ),
      ).wrapDotBorder(
        color: Colors.grey.shade600,
        radius: 5,
      ),
    );

    res.add(SizedBox(height: 20));
    res.add(q);
    res.add(SizedBox(height: 20));

    for(final a in itm.choices){

      final w = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          final idx = itm.choices.indexOf(a);
          bool isSelected = selectedAnswer[itm.id] == idx;

          isSelected = selectedAnswer[itm.id] == idx;

          if(isSelected){
            selectedAnswer[itm.id] = null;
          }
          else {
            selectedAnswer[itm.id] = idx;
          }

          assistCtr.updateMain();
        },
        child: AnimateWidget(
          resetOnRebuild: true,
          triggerOnRebuild: true,
          duration: Duration(milliseconds: 400),
          cycles: 1,
          builder: (_, animate){
            final idx = itm.choices.indexOf(a);
            bool isSelected = selectedAnswer[itm.id] == idx;

            Color c = animate.fromTween((v) => ColorTween(begin: Colors.teal, end:Colors.lightBlueAccent))!;
            TextStyle selectStl = TextStyle(color: Colors.white, fontWeight: FontWeight.w700);
            TextStyle unSelectStl = TextStyle(color: Colors.black87);

            return  DecoratedBox(
              decoration: BoxDecoration(
                  color: isSelected? c : Colors.transparent,
                  borderRadius: BorderRadius.circular(5)
              ),
              child: Row(
                children: [
                  Text('  ${idx+1} -  ', style: isSelected? selectStl : unSelectStl).englishFont(),
                  Text(a.text, style: isSelected? selectStl : unSelectStl).englishFont(),
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

  bool isAllAnswer(){
    for(final k in examItems){
      if(selectedAnswer[k.id] == null){
        return false;
      }
    }

    return true;
  }

  void onNextClick(){
    if(currentExamIdx < examItems.length-1) {
      currentExamIdx++;
    }

    assistCtr.updateMain();
  }

  void onPreClick(){

    if(currentExamIdx > 0) {
      currentExamIdx--;
      assistCtr.updateMain();
    }
  }

  double calcProgress(){
    int r = ((currentExamIdx+1) * 100) ~/ examItems.length;
    return r/100;
  }

  void onCheckClick(){
    showAnswers = !showAnswers;
    assistCtr.updateMain();
  }
}


