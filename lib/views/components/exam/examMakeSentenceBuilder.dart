import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';
import 'package:iris_tools/widgets/text/autoDirection.dart';

import 'package:app/structures/abstract/examStateMethods.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/controllers/examController.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_themes.dart';

class ExamMakeSentenceBuilder extends StatefulWidget {
  static const questionTitle = 'با چینش کلمات جمله بسازید';
  final ExamModel examModel;

  const ExamMakeSentenceBuilder({
    required this.examModel,
    Key? key
  }) : super(key: key);

  @override
  State<ExamMakeSentenceBuilder> createState() => _ExamMakeSentenceBuilderState();
}
///===============================================================================================================
class _ExamMakeSentenceBuilderState extends StateSuper<ExamMakeSentenceBuilder> with ExamStateMethods {
  late TextStyle pickedStyle;
  late MakeSentenceExtra sentenceExtra;
  int currentSentence = 0;

  @override
  void initState() {
    super.initState();

    sentenceExtra = widget.examModel.sentenceExtra!;

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
  }

  Widget buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: buildExam(),
    );
  }

  Widget buildExam() {
    final question = generateQuestion(sentenceExtra);

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
              ).wrapBackground(backColor: Colors.grey.shade100, padding: const EdgeInsets.all(12))
          ),

          const SizedBox(height: 20),

          ///=== selected words
          Builder(
              builder: (_){
                if(sentenceExtra.hasAnswer()){
                  final answer = sentenceExtra.joinUserAnswer();

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
                      backColor: widget.examModel.showAnswer? (sentenceExtra.isCorrectAll()? Colors.green.shade400: Colors.red.shade400): Colors.grey.shade100,
                    padding: const EdgeInsets.all(12),
                  );
                }

                return const SizedBox();
              }
          ),

          ///=== correct answer
          Builder(
              builder: (_){
                if(widget.examModel.showAnswer && !sentenceExtra.isCorrectAll()){
                  final answer = sentenceExtra.joinCorrectAnswer();

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
                  visible: sentenceExtra.hasAnswer() && !widget.examModel.showAnswer,
                  child: GestureDetector(
                    onTap: (){
                      sentenceExtra.back();
                      assistCtr.updateHead();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(AppIcons.refresh, size: 18, color: Colors.blue),
                    ),
                  )
              ),

              ///=== words
              Expanded(
                child: Builder(
                    builder: (context) {
                      if(widget.examModel.showAnswer){
                        return const SizedBox();
                      }

                      return buildWords();
                    }
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }

  String generateQuestion(MakeSentenceExtra holder) {
    String txt = '';

    for(final x in widget.examModel.items){
      txt += ' ${x.question}';
    }

    return txt.trim();
  }

  Widget buildWords() {
    final widgetList = <Widget>[];
    Color color = Colors.grey.shade200;

    for (final w in sentenceExtra.getShuffleForIndex()) {
      /// is picked before
      if (sentenceExtra.getSelectedWordsForIndex().indexWhere((element) => element.id == w.id) > -1) {
        continue;
      }

      widgetList.add(
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                if(widget.examModel.showAnswer){
                  return;
                }

                onWordClick(w);
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

    /*return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widgetList.toList(),
      ),
    );*/

    return Wrap(
      runSpacing: 10,
      children: widgetList.toList(),
    );
  }

  void onWordClick(ExamOptionModel word) {
    if(widget.examModel.showAnswer){
      return;
    }

    sentenceExtra.getSelectedWordsForIndex().add(word);

    if(sentenceExtra.isSentenceFullByIndex()){
      sentenceExtra.forward();
    }

    assistCtr.updateHead();
  }

  @override
  void showAnswer(bool state) {
    widget.examModel.showAnswer = state;
    assistCtr.updateHead();
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
