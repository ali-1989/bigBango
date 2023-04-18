import 'package:flutter/gestures.dart';
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
  List<ExamModel> examList = [];
  int currentSpaceOrder = 0;

  @override
  void initState() {
    super.initState();

    if(widget.index == null) {
      examList.addAll(widget.content.examList.where((element) => element.quizType == QuizType.makeSentence));
    }
    else {
      examList.add(widget.content.examList[widget.index!]);
    }

    questionNormalStyle = TextStyle(fontSize: 16, color: Colors.black);
    falseStyle = TextStyle(fontSize: 16,
        color: Colors.red,
        decorationStyle: TextDecorationStyle.solid,
        decoration: TextDecoration.lineThrough,
        decorationColor: Colors.red
    );
    pickedStyle = TextStyle(
      decorationStyle: TextDecorationStyle.solid,
      decoration: TextDecoration.lineThrough,
      decorationColor: Colors.red,
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
                  child: Text('با کلمات جمله بسازید'),
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
      return Divider(color: Colors.black, height: 2);
    }

    final item = examList[idx ~/ 2];

    return buildExam(item);
  }

  Widget buildExam(ExamModel model) {
    final List<InlineSpan> spans = generateSpans(model);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),

          ///=== question
          RichText(
            text: TextSpan(children: spans),
            textDirection: TextDirection.ltr,
          ),

          SizedBox(height: 20),

          ///=== words
          buildWords(model),
          SizedBox(height: 14),
        ],
      ),
    );
  }

  List<InlineSpan> generateSpans(ExamModel model) {
    final List<InlineSpan> spans = [];

    for (int i = 0; i < model.questionSplit.length; i++) {
      final q = TextSpan(text: model.questionSplit[i], style: questionNormalStyle);
      spans.add(q);

      void onSpanClick(gesDetail) {
        if (model.showAnswer) {
          return;
        }

        setUserAnswer(model, i+1, null);

        /*if (currentSelectIndex > 0) {
          if (currentSelectIndex == i+1) {
            currentSelectIndex = 0;
          }
          else {
            currentSelectIndex = i+1;
          }
        }
        else {
          currentSelectIndex = i+1;
        }*/

        assistCtr.updateHead();
      }

      if (i < model.questionSplit.length - 1) {
        InlineSpan choiceSpan;
        String choiceText = '';
        Color choiceColor;

        final tapRecognizer = TapGestureRecognizer()..onTapUp = onSpanClick;

        if (model.showAnswer) {
          final correctAnswer = model.getChoiceByOrder(i+1)!.text;
          final userAnswer = model.getUserChoiceByOrder(i+1)?.text;
          Color trueColor = Colors.green;
          Color falseColor = Colors.red;

          if (correctAnswer == userAnswer) {
            /// correct span
            choiceSpan = WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //Image.asset(AppImages.trueCheckIco),
                    //SizedBox(width: 5),
                    Text(userAnswer?? '', style: questionNormalStyle.copyWith(color: trueColor))
                  ],
                )
            );
          }
          else {
            /// wrong span
            choiceSpan = WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //Image.asset(AppImages.falseCheckIco),
                    //SizedBox(width: 5),
                    Text(userAnswer?? '-', style: falseStyle.copyWith(color: falseColor)),
                    SizedBox(width: 5),
                    Text('[$correctAnswer]', style: questionNormalStyle.copyWith(color: trueColor))
                  ],
                )
            );
          }
        }
        else {
          final userAnswer = model.getUserChoiceByOrder(i+1)?.text ?? '';

          if (userAnswer.isNotEmpty) {
            choiceText = userAnswer;
            choiceColor = Colors.blue;
          }
          else {
            choiceText = '\u00A0_____\u00A0';
            choiceColor = Colors.blue.shade200;
          }

          choiceSpan = WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: CustomCard(
                radius: 4,
                color: /*currentSelectIndex == i+1 ? Colors.blue.withAlpha(40) :*/ Colors.transparent,
                child: RichText(
                  text: TextSpan(
                    text: choiceText,
                    style: questionNormalStyle.copyWith(color: choiceColor),
                    recognizer: tapRecognizer,
                  ),
                ),
              )
          );
        }

        spans.add(choiceSpan);
      }
    }

    return spans;
  }

  Widget buildWords(ExamModel model) {
    final list = model.shuffleWords.map((w) {
      var isPicked = false;

      for (final k in model.userAnswers) {
        if (k.id == w.id) {
          isPicked = true;
          break;
        }
      }

      Color bColor = Colors.grey.shade200;

      if (/*currentSelectIndex > 0 && */!isPicked) {
        bColor = Colors.lightBlueAccent;
      }

      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () {
            onWordClick(model, w);
          },
          child: CustomCard(
              color: bColor,
              radius: 2,
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              child: Text(w.text,
                style: isPicked ? pickedStyle : AppThemes.baseTextStyle(),
              ).fsR(2)
          ),
        ),
      );
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: list.toList(),
      ),
    );
  }

  void onWordClick(ExamModel model, ExamOptionModel ec) {
    setUserAnswer(model, currentSpaceOrder, ec);

    List<String> selectedWordIds = [];

    for (final k in model.userAnswers) {
      if (k.text.isNotEmpty) {
        selectedWordIds.add(k.id);
      }
    }

    if (selectedWordIds.length + 1 == model.options.length) {
      for (final k in model.userAnswers) {
        if (k.text.isEmpty) {
          ExamOptionModel? examChoiceModel;

          for (final kk in model.options) {
            if (!selectedWordIds.contains(kk.id)) {
              examChoiceModel = kk;
              currentSpaceOrder++;
              break;
            }
          }

          k.id = examChoiceModel!.id;
          k.text = examChoiceModel.text;
          break;
        }
      }
    }

    assistCtr.updateHead();
  }

  void setUserAnswer(ExamModel model, int order, ExamOptionModel? ec) {
    final u = model.getUserChoiceByOrder(order);

    if (ec != null) {
      u!.text = ec.text;
      u.id = ec.id;
      currentSpaceOrder++;
    }
    else {
      u!.text = '';
      u.id = '';
      currentSpaceOrder--;
    }
  }

  @override
  void showAnswer(String id, bool state) {
    for (final model in examList) {
      if(model.id == id){
        model.showAnswer = state;
        break;
      }
    }
  }

  @override
  void showAnswers(bool state) {
    for (final element in examList) {
      element.showAnswer = state;
    }

    assistCtr.updateHead();
  }

  @override
  bool isAnswerToAll(){
    for(final k in examList){
      for(final x in k.userAnswers) {
        if (x.text.isEmpty || x.id.isEmpty) {
          return false;
        }
      }
    }

    return true;
  }
}
