import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/examOptionsModel.dart';
import 'package:app/models/lessonModels/iSegmentModel.dart';
import 'package:app/models/lessonModels/lessonModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

class ExamOptionInjector {
  late LessonModel lessonModel;
  late ISegmentModel segment;
}
///-----------------------------------------------------
class ExamOptionPage extends StatefulWidget {
  final ExamOptionInjector injector;

  const ExamOptionPage({
    required this.injector,
    Key? key
  }) : super(key: key);

  @override
  State<ExamOptionPage> createState() => _ExamOptionPageState();
}
///======================================================================================================================
class _ExamOptionPageState extends StateBase<ExamOptionPage> {
  List<ExamOptionsModel> examItems = [];
  Map<int, List<int>> selectedAnswer = {};
  bool showAnswers = false;
  int currentExamIdx = 0;
  late TextStyle questionNormalStyle;

  @override
  void initState(){
    super.initState();

    questionNormalStyle = TextStyle(fontSize: 16, color: Colors.black);

    List.generate(10, (index) {
      final m = ExamOptionsModel()..id = index;
      m.question = Generator.generateWords(20, 2, 10);

      for(int i=0; i<4; i++){
        m.options.add(Generator.generateWords(5, 2, 7));
      }

      examItems.add(m);
    });

    for(final k in examItems){
      selectedAnswer[k.id] = [];
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
              child: LinearProgressIndicator(value: calcProgress(), backgroundColor: Colors.red.shade50)
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
              onPressed: onCheckClick,
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
          borderRadius: BorderRadius.circular(10)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Text(
            itm.question,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w200),
          textAlign: TextAlign.justify,
        ),
      ).wrapDotBorder(
        color: Colors.grey.shade600,
      ),
    );

    res.add(SizedBox(height: 20));
    res.add(q);
    res.add(SizedBox(height: 20));

    int num = 1;

    for(final a in itm.options){
      final idx = itm.options.indexOf(a);
      bool isSelected = selectedAnswer[itm.id]!.contains(idx);

      final w = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          isSelected = selectedAnswer[itm.id]!.contains(idx);
          if(isSelected){
            selectedAnswer[itm.id]!.remove(idx);
          }
          else {
            selectedAnswer[itm.id]!.add(idx);
          }

          assistCtr.updateMain();
        },
        child: Container(
          color: isSelected? Colors.lightBlueAccent : Colors.transparent,
          child: Row(
            children: [
              Text('  $num    '),
              Text(a),
            ],
          ).wrapBoxBorder(
            color: Colors.black54,
            radius: 5,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 5)
          ),
        ),
      );

      res.add(SizedBox(height: 20));
      res.add(w);

      num++;
    }

    return res;
  }

  void onNextClick(){
    if(currentExamIdx < examItems.length-1) {
      currentExamIdx++;
    }
    else {
      //showGreeting = true;
    }

    assistCtr.updateMain();
  }

  void onPreClick(){
    /*if(showGreeting){
      showGreeting = false;
    }
    else {
      currentExamIdx--;
    }*/

    if(currentExamIdx > 0) {
      currentExamIdx--;
    }

    assistCtr.updateMain();
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


