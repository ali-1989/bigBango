import 'package:app/tools/app/appIcons.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';

import 'package:app/structures/abstract/examStateMethods.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/builders/examBuilderContent.dart';
import 'package:app/structures/controllers/examController.dart';
import 'package:app/structures/enums/quizType.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:iris_tools/widgets/text/autoDirection.dart';

class ExamMakeSentenceBuilder extends StatefulWidget {
  final ExamBuilderContent content;
  final String controllerId;
  final int? index;
  final bool showTitle;

  const ExamMakeSentenceBuilder({
    required this.content,
    required this.controllerId,
    this.showTitle = true,
    this.index,
    Key? key
  }) : super(key: key);

  @override
  State<ExamMakeSentenceBuilder> createState() => _ExamMakeSentenceBuilderState();
}
///===============================================================================================================
class _ExamMakeSentenceBuilderState extends StateBase<ExamMakeSentenceBuilder> with ExamStateMethods {
  late TextStyle questionNormalStyle;
  late TextStyle falseStyle;
  late TextStyle pickedStyle;
  List<ExamHolder> examList = [];
  int currentSentence = 0;

  @override
  void initState() {
    super.initState();

    if(widget.index == null) {
      final filteredList = widget.content.examList.where((element) => element.quizType == QuizType.makeSentence);

      examList.addAll(filteredList.map((e) => ExamHolder(e)));
    }
    else {
      final eh = ExamHolder(widget.content.examList[widget.index!]);
      examList.add(eh);
    }

    questionNormalStyle = TextStyle(fontSize: 16, color: Colors.black);
    falseStyle = TextStyle(fontSize: 16,
        color: Colors.red,
        decorationStyle: TextDecorationStyle.solid,
        decoration: TextDecoration.lineThrough,
        decorationColor: Colors.red
    );
    pickedStyle = TextStyle(
      //decorationStyle: TextDecorationStyle.solid,
      //decoration: TextDecoration.lineThrough,
      //decorationColor: Colors.red,
    );

    ExamController(widget.controllerId, this);
  }

  @override
  void dispose(){
    ExamController.removeControllerFor(widget.controllerId);
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
      child: CustomScrollView(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        slivers: [
          SliverVisibility(
              visible: widget.showTitle,
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text('با چینش کلمات جمله بسازید'),
                ),
              )
          ),


          SliverList(
            delegate: SliverChildBuilderDelegate(
              listItemBuilder,
              childCount: examList.length * 2 - 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget listItemBuilder(ctx, idx) {
    ///=== Divider
    if (idx % 2 != 0) {
      return Divider(color: Colors.black12, height: 1);
    }

    final item = examList[idx ~/ 2];

    return buildExam(item);
  }

  Widget buildExam(ExamHolder holder) {
    final question = generateQuestion(holder);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),

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

          SizedBox(height: 20),

          ///=== selected words
          Builder(
              builder: (_){
                if(holder.hasAnswer()){
                  final answer = holder.generateAnswer();

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
                      backColor: holder.examModel.showAnswer? (holder.isCorrect()? Colors.green: Colors.red): Colors.grey.shade100
                  );
                }

                return SizedBox();
              }
          ),

          SizedBox(height: 10),

          Row(
            children: [
              Visibility(
                visible: holder.hasAnswer(),
                  child: GestureDetector(
                    onTap: (){
                      holder.back();
                      assistCtr.updateHead();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(AppIcons.refresh, size: 18, color: Colors.blue),
                    ),
                  )
              ),

              ///=== words
              buildWords(holder),
            ],
          ),

          SizedBox(height: 14),
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
                onWordClick(holder, w);
              },
              child: CustomCard(
                  color: color,
                  radius: 2,
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
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

    holder.getSelectedWordsFor().add(ec);

    if(holder.isSentenceFull()){
      holder.forward();
    }

    assistCtr.updateHead();
  }

  @override
  void showAnswer(String id, bool state) {
    firstIf:
    for (final holder in examList) {
      for(final itm in holder.examModel.items){
        if(itm.id == id){
          holder.examModel.showAnswer = state;
          break firstIf;
        }
      }
    }
  }

  @override
  void showAnswers(bool state) {
    for (final holder in examList) {
      holder.examModel.showAnswer = state;
    }

    assistCtr.updateHead();
  }

  @override
  bool isAnswerToAll(){
    for(final holder in examList){
      for(int i =0; i < holder.shuffleWords.length; i++) {
        if (holder.getSelectedWordsFor(idx: i).length != holder.getShuffleFor(idx: i).length) {
          return false;
        }
      }
    }

    return true;
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
      final lis = x.options.toList();
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

  String generateAnswer() {
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

  bool isCorrect(){
    for(int i =0; i < shuffleWords.length; i++){
      final sh = shuffleWords[i];
      final se = selectedWords[i];

      if(sh.length != se.length){
        return false;
      }

      for(int j=0; j < sh.length; j++){
        if(sh[j].text != se[j].text){
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