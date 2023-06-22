import 'package:app/tools/app/appDecoration.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';

import 'package:app/structures/abstract/examStateMethods.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/controllers/examController.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appThemes.dart';

class ExamSelectWordBuilder extends StatefulWidget {
  static const questionTitle = 'کلمات را در جای مناسب قرار دهید';
  final ExamModel exam;

  const ExamSelectWordBuilder({
    required this.exam,
    Key? key
  }) : super(key: key);

  @override
  State<ExamSelectWordBuilder> createState() => _ExamSelectWordBuilderState();
}
///===============================================================================================================
class _ExamSelectWordBuilderState extends StateBase<ExamSelectWordBuilder> with ExamStateMethods {
  late TextStyle questionNormalStyle;
  late TextStyle falseStyle;
  late TextStyle pickedStyle;
  int currentSpaceOrder = 1;
  late ExamModel exam;

  @override
  void initState() {
    super.initState();

    exam = widget.exam;

    questionNormalStyle = const TextStyle(fontSize: 16, color: Colors.black);
    falseStyle = const TextStyle(fontSize: 16,
        color: Colors.red,
        decorationStyle: TextDecorationStyle.solid,
        decoration: TextDecoration.lineThrough,
        decorationColor: Colors.red
    );
    pickedStyle = const TextStyle(
      decorationStyle: TextDecorationStyle.solid,
      decoration: TextDecoration.lineThrough,
      decorationColor: Colors.red,
    );

    ExamController(widget.exam, this);
  }

  @override
  void dispose(){
    ExamController.removeControllerFor(widget.exam);
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
    final List<InlineSpan> spans = generateSpans(exam);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            ///=== question
            RichText(
              text: TextSpan(children: spans),
              textDirection: TextDirection.ltr,
            ),

            const SizedBox(height: 20),

            ///=== words
            Builder(
                builder: (context) {
                  if(exam.showAnswer){
                    return const SizedBox();
                  }

                  return buildWords(exam);
                }
            ),

            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  List<InlineSpan> generateSpans(ExamModel model) {
    final List<InlineSpan> spans = [];

    for (int i = 0; i < model.getExamItem().questionSplit.length; i++) {
      final q = TextSpan(text: model.getExamItem().questionSplit[i], style: questionNormalStyle);
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

      if (i < model.getExamItem().questionSplit.length - 1) {
        InlineSpan choiceSpan;
        String choiceText = '';
        Color choiceColor;

        final tapRecognizer = TapGestureRecognizer()..onTapUp = onSpanClick;

        if (model.showAnswer) {
          final correctAnswer = model.getExamItem().getTeacherOptionByOrder(i+1)!.text;
          var userAnswer = model.getExamItem().getUserOptionByOrder(i+1)?.text;
          Color trueColor = Colors.green;
          Color falseColor = Colors.red;

          if(userAnswer?.isEmpty?? false){
            userAnswer = null;
          }

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
                    Text(userAnswer?? '--', style: falseStyle.copyWith(color: falseColor)),
                    const SizedBox(width: 5),
                    Text('[$correctAnswer]', style: questionNormalStyle.copyWith(color: trueColor))
                  ],
                )
            );
          }
        }
        else {
          final userAnswer = model.getExamItem().getUserOptionByOrder(i+1)?.text ?? '';

          if (userAnswer.isNotEmpty) {
            choiceText = userAnswer;
            choiceColor = AppDecoration.blue;
          }
          else {
            choiceText = '\u00A0_____\u00A0';
            choiceColor = Colors.grey.shade200;
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
    final list = model.getExamItem().shuffleWords.map((w) {
      var isPicked = false;

      for (final k in model.getExamItem().userAnswers) {
        if (k.id == w.id) {
          isPicked = true;
          break;
        }
      }

      Color bColor = Colors.grey.shade200;

      if (/*currentSelectIndex > 0 && */!isPicked) {
        bColor = Colors.grey.shade300;
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
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
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
    if(model.showAnswer){
      return;
    }
    /*if (currentSelectIndex < 1) {
      for (final k in model.userAnswers){
        if(k.id == ec.id){
          return;
        }
      }

      AppToast.showToast(context, 'ابتدا جای خالی را انتخاب کنید');
      return;
    }*/

    setUserAnswer(model, currentSpaceOrder, ec);

    List<String> selectedWordIds = [];

    for (final k in model.getExamItem().userAnswers) {
      if (k.text.isNotEmpty) {
        selectedWordIds.add(k.id);
      }
    }

    if (selectedWordIds.length + 1 == model.getExamItem().teacherOptions.length) {
      for (final k in model.getExamItem().userAnswers) {
        if (k.text.isEmpty) {
          ExamOptionModel? examChoiceModel;

          for (final kk in model.getExamItem().teacherOptions) {
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
    final u = model.getExamItem().getUserOptionByOrder(order);

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
  void showAnswer(bool state) {
    exam.showAnswer = state;

    assistCtr.updateHead();
  }
}
