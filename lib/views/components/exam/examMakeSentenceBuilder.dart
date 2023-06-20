import 'package:app/tools/app/appIcons.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';

import 'package:app/structures/abstract/examStateMethods.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/controllers/examController.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:iris_tools/widgets/text/autoDirection.dart';

class ExamMakeSentenceBuilder extends StatefulWidget {
  final ExamModel examModel;

  const ExamMakeSentenceBuilder({
    required this.examModel,
    Key? key
  }) : super(key: key);

  @override
  State<ExamMakeSentenceBuilder> createState() => _ExamMakeSentenceBuilderState();
}
///===============================================================================================================
class _ExamMakeSentenceBuilderState extends StateBase<ExamMakeSentenceBuilder> with ExamStateMethods {
  late TextStyle pickedStyle;
  late ExamHolder examHolder;
  int currentSentence = 0;

  @override
  void initState() {
    super.initState();

    examHolder = ExamHolder(widget.examModel);

    pickedStyle = const TextStyle(
      //decorationStyle: TextDecorationStyle.solid,
      //decoration: TextDecoration.lineThrough,
      //decorationColor: Colors.red,
    );

    ExamController(widget.examModel, this);
  }

  @override
  void dispose(){
    ExamController.removeControllerFor(widget.examModel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
        controller: assistCtr,
        builder: (ctx, ctr, data) {
          return buildBody();
        }
    );
  }//'با چینش کلمات جمله بسازید

  Widget buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: buildExam(examHolder),
    );
  }

  Widget buildExam(ExamHolder holder) {
    final question = generateQuestion(holder);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          ///=== question
          Visibility(
              visible: question.isNotEmpty,
              child: AutoDirection(
                builder: (_, AutoDirectionController direction) {
                  return Align(
                    alignment: direction.getAlignment(question),
                    child: Text(
                      question,
                      textDirection: direction.getTextDirection(question),
                    ),
                  );
                },
              ).wrapBackground(backColor: Colors.grey.shade100)
          ),

          const SizedBox(height: 20),

          ///=== selected words
          Builder(
              builder: (_){
                if(holder.hasAnswer()){
                  final answer = holder.generateUserAnswer();

                  return AutoDirection(
                    builder: (_, AutoDirectionController direction) {
                      return Align(
                        alignment: direction.getAlignment(answer),
                        child: Text(
                          answer,
                          textDirection: direction.getTextDirection(answer),
                        ),
                      );
                    },
                  ).wrapBackground(
                      backColor: holder.examModel.showAnswer? (holder.isCorrect()? Colors.green.shade400: Colors.red.shade400): Colors.grey.shade100
                  );
                }

                return const SizedBox();
              }
          ),

          ///=== selected words
          Builder(
              builder: (_){
                if(holder.examModel.showAnswer && !holder.isCorrect()){
                  final answer = holder.generateCorrectAnswer();

                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: AutoDirection(
                      builder: (_, AutoDirectionController direction) {
                        return Align(
                          alignment: direction.getAlignment(answer),
                          child: Text(
                            answer,
                            textDirection: direction.getTextDirection(answer),
                          ),
                        );
                      },
                    ).wrapBackground(
                      backColor: Colors.grey.shade100,
                      borderColor: Colors.green,
                    ),
                  );
                }

                return const SizedBox();
              }
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Visibility(
                  visible: holder.hasAnswer() && !holder.examModel.showAnswer,
                  child: GestureDetector(
                    onTap: (){
                      holder.back();
                      assistCtr.updateHead();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(AppIcons.refresh, size: 18, color: Colors.blue),
                    ),
                  )
              ),

              ///=== words
              Builder(
                  builder: (context) {
                    if(holder.examModel.showAnswer){
                      return const SizedBox();
                    }

                    return buildWords(holder);
                  }
              ),
            ],
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }

  String generateQuestion(ExamHolder holder) {
    String txt = '';

    for(final x in holder.examModel.items){
      txt += ' ${x.question}';
    }

    return txt.trim();
  }

  Widget buildWords(ExamHolder holder) {
    final widgetList = <Widget>[];
    Color color = Colors.grey.shade200;

    for (final w in holder.getShuffleFor()) {
      if (holder.getSelectedWordsFor().indexWhere((element) => element.id == w.id) > -1) {
        continue;
      }

      widgetList.add(
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                if(holder.examModel.showAnswer){
                  return;
                }

                onWordClick(holder, w);
              },
              child: CustomCard(
                  color: color,
                  radius: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  child: Text(w.text,
                    style: AppThemes.baseTextStyle(),
                  ).fsR(2)
              ),
            ),
          )
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widgetList.toList(),
      ),
    );
  }

  void onWordClick(ExamHolder holder, ExamOptionModel ec) {
    //setUserAnswer(model, currentSpaceOrder, ec);
    if(holder.examModel.showAnswer){
      return;
    }

    holder.getSelectedWordsFor().add(ec);

    if(holder.isSentenceFull()){
      holder.forward();
    }

    assistCtr.updateHead();
  }

  @override
  void showAnswer(bool state) {
    examHolder.examModel.showAnswer = state;
    assistCtr.updateHead();
  }
}
///=====================================================================================
class ExamHolder {
  late ExamModel examModel;
  List<List<ExamOptionModel>> selectedWords = [];
  List<List<ExamOptionModel>> shuffleWords = [];
  int currentIndex = 0;

  ExamHolder(this.examModel){
    for(final x in examModel.items){
      final lis = x.teacherOptions.toList();
      lis.shuffle();

      selectedWords.add([]);
      shuffleWords.add(lis);
    }
  }

  List<ExamOptionModel> getShuffleFor({int? idx}){
    idx ??= currentIndex;

    if(shuffleWords.length > idx) {
      return shuffleWords[idx];
    }

    return [];
  }

  List<ExamOptionModel> getSelectedWordsFor({int? idx}){
    idx ??= currentIndex;

    if(selectedWords.length > idx) {
      return selectedWords[idx];
    }

    return [];
  }

  bool isSentenceFull({int? idx}){
    idx ??= currentIndex;

    if(selectedWords.length > idx) {
      return selectedWords[idx].length == shuffleWords[idx].length;
    }

    return false;
  }

  bool hasAnswer(){
    return selectedWords[0].isNotEmpty;
  }

  void forward(){
    if(currentIndex < shuffleWords.length-1) {
      currentIndex++;
    }
  }

  void back(){
    final lis = getSelectedWordsFor();

    if(lis.isNotEmpty){
      lis.clear();
    }
    else {
      currentIndex--;

      if(currentIndex < 0){
        currentIndex = 0;
      }

      getSelectedWordsFor().clear();
    }
  }

  String generateUserAnswer() {
    String txt = '';

    for(int i =0; i < selectedWords.length; i++){
      final x = selectedWords[i];

      for(final x2 in x){
        txt += ' ${x2.text}';
      }

      if(x.length == getShuffleFor(idx: i).length) {
        txt += '.';
      }
    }

    return txt.trim();
  }

  String generateCorrectAnswer() {
    String txt = '';

    for(int i =0; i < examModel.items.length; i++){
      final x = examModel.items[i];

      for(final x2 in x.teacherOptions){
        txt += ' ${x2.text}';
      }

      txt += '.';
    }

    return txt.trim();
  }

  bool isCorrect(){
    for(int i =0; i < shuffleWords.length; i++){
      final itm = examModel.items[i];
      final se = selectedWords[i];

      if(itm.teacherOptions.length != se.length){
        return false;
      }

      for(int j=0; j < itm.teacherOptions.length; j++){
        if(itm.teacherOptions[j].text != se[j].text){
          return false;
        }
      }
    }

    return true;
  }
}



/*
 Widget buildSelectedWordsA(ExamHolder holder) {
    final list = <Widget>[];

    for (final w in holder.getSelectedWordsFor(0)) {
      list.add(
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: CustomCard(
                color: Colors.lightBlueAccent,
                radius: 6,
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: Text(w.text, style: pickedStyle,).fsR(2)
            ),
          )
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: list.toList(),
      ),
    );
  }

   Widget buildSelectedWordsB(ExamModel model) {
    final list = <Widget>[];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: list.toList(),
      ),
    );
  }
 */