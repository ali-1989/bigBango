import 'package:app/tools/app/appThemes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/injectors/examInjector.dart';
import 'package:app/structures/interfaces/examStateInterface.dart';
import 'package:app/structures/models/examModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/views/widgets/customCard.dart';

class ExamSelectWordComponent extends StatefulWidget {
  final ExamInjector injector;

  const ExamSelectWordComponent({
    required this.injector,
    Key? key
  }) : super(key: key);

  @override
  State<ExamSelectWordComponent> createState() => _ExamSelectWordComponentState();
}
///===============================================================================================================
class _ExamSelectWordComponentState extends StateBase<ExamSelectWordComponent> implements ExamStateInterface {
  bool showAnswers = false;
  late TextStyle questionNormalStyle;
  int currentSelectIndex = -1;

  @override
  void initState() {
    super.initState();

    questionNormalStyle = TextStyle(fontSize: 16, color: Colors.black);
  }

  @override
  void dispose() {
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [

          /// exam
          Expanded(
              child: CustomScrollView(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      listItemBuilder,
                      childCount: widget.injector.examList.length * 2 - 1,
                    ),
                  ),
                ],
              )
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

    final item = widget.injector.examList[idx ~/ 2];
    final List<InlineSpan> spans = generateSpans(item);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),

          ///=== number box
          Visibility(
            visible: widget.injector.examList.length > 1,
            child: CustomCard(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text('${idx ~/ 2 + 1}').bold(weight: FontWeight.w900).fsR(1),
            ).wrapBoxBorder(
                padding: EdgeInsets.all(2),
                radius: 9,
                stroke: 1.0,
                color: Colors.black
            ),
          ),

          SizedBox(height: 15),

          ///=== question
          RichText(
            text: TextSpan(children: spans),
            textDirection: TextDirection.ltr,
          ),

          SizedBox(height: 10),

          ///=== words
          buildWords(item),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  List<InlineSpan> generateSpans(ExamModel model) {
    final List<InlineSpan> spans = [];

    for (int i = 0; i < model.questionSplit.length; i++) {
      final q = TextSpan(text: model.questionSplit[i], style: questionNormalStyle);
      spans.add(q);

      if (i < model.questionSplit.length - 1) {
        InlineSpan choiceSpan;
        String choiceText = '';
        Color choiceColor;

        final tapRecognizer = TapGestureRecognizer()
          ..onTapUp = (gesDetail) {
            if (showAnswers) {
              return;
            }

            setUserAnswer(model, i, null);

            if (currentSelectIndex > -1) {
              if (currentSelectIndex == i) {
                currentSelectIndex = -1;
              }
              else {
                currentSelectIndex = i;
              }
            }
            else {
              currentSelectIndex = i;
            }

            assistCtr.updateMain();
          };

        if (showAnswers) {
          final correctAnswer = model.getChoiceByOrder(i)!.text;
          final userAnswer = model.getUserChoiceByOrder(i)!.text;

          if (correctAnswer == userAnswer) {
            /// correct span
            choiceSpan = WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(AppImages.trueCheckIco),
                    SizedBox(width: 5),
                    Text(userAnswer, style: questionNormalStyle.copyWith(color: Colors.green))
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
                    Image.asset(AppImages.falseCheckIco),
                    SizedBox(width: 5),
                    Text(userAnswer, style: questionNormalStyle.copyWith(color: AppColors.red)),
                    SizedBox(width: 5),
                    Text('[$correctAnswer]', style: questionNormalStyle.copyWith(color: Colors.green))
                  ],
                )
            );
          }
        }
        else {
          final userAnswer = model.getUserChoiceByOrder(i)!.text;

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
                color: currentSelectIndex == i ? Colors.blue.withAlpha(40) : Colors.transparent,
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

  void onWordClick(ExamModel model, ExamChoiceModel ec) {
    if (currentSelectIndex < 0) {
      return;
    }

    setUserAnswer(model, currentSelectIndex, ec);
    currentSelectIndex = -1;

    List<String> selectedWordIds = [];

    for (final k in model.userAnswers) {
      if (k.id.isNotEmpty) {
        selectedWordIds.add(k.id);
      }
    }

    if (selectedWordIds.length + 1 == model.choices.length) {
      for (final k in model.userAnswers) {
        if (k.id.isEmpty) {
          ExamChoiceModel? examChoiceModel;

          for (final kk in model.choices) {
            if (!selectedWordIds.contains(kk.id)) {
              examChoiceModel = kk;
              break;
            }
          }

          k.id = examChoiceModel!.id;
          k.text = examChoiceModel.text;
          break;
        }
      }
    }

    assistCtr.updateMain();
  }

  void setUserAnswer(ExamModel model, int order, ExamChoiceModel? ec) {
    if (ec != null) {
      model.getUserChoiceByOrder(order)!.text = ec.text;
      model.getUserChoiceByOrder(order)!.id = ec.id;
    }
    else {
      model.getUserChoiceByOrder(order)!.text = '';
      model.getUserChoiceByOrder(order)!.id = '';
    }
  }

  Widget buildWords(ExamModel model) {
    return Row(
      children: [
        ...model.shuffleWords.map((w) {
          var isSelected = false;

          for (final k in model.userAnswers) {
            if (k.id == w.id) {
              isSelected = true;
              break;
            }
          }

          Color bColor = Colors.grey.shade200;

          if (currentSelectIndex > -1 && !isSelected) {
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
                    style: isSelected
                        ? TextStyle(
                      decorationStyle: TextDecorationStyle.solid,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Colors.red,
                    )
                        : AppThemes.baseTextStyle(),
                  )
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  void checkAnswers() {
    bool isAllSelected = true;

    for (final model in widget.injector.examList) {
      for (final k in model.userAnswers) {
        if (k.id.isEmpty) {
          isAllSelected = false;
          break;
        }
      }

      if (!isAllSelected) {
        break;
      }
    }

    if (!isAllSelected) {
      AppSnack.showError(context, 'لطفا همه ی گزینه ها را انتخاب کنید');
      return;
    }

    showAnswers = !showAnswers;
    assistCtr.updateMain();
  }
}



/*
void gotoExam(LessonModel model){

    ExamModel ee = ExamModel();
    ee.question = 'gggggg ** ffff ** ssss ** dddd';
    ee.id = 'fdfff fgfg ffgg';
    ee.quizType = QuizType.recorder;

    ee.choices = [
      ExamChoiceModel()..text = 'yes'..order=2,
      ExamChoiceModel()..text = 'no'..order = 1,
      ExamChoiceModel()..text = 'ok'..order = 0,
    ];

    ee.doSplitQuestion();
    ExamInjector examComponentInjector = ExamInjector();
    examComponentInjector.lessonModel = model;
    examComponentInjector.segmentModel = model.grammarModel!;
    examComponentInjector.examList.add(ee);

    final component = ExamSelectWordComponent(injector: examComponentInjector);

    final pageInjector = ExamPageInjector();
    pageInjector.lessonModel = model;
    pageInjector.segment = model.grammarModel!;
    pageInjector.examPage = component;
    pageInjector.description = 'ddd dff dfdf';
    final examPage = ExamPage(injector: pageInjector);

    AppRoute.push(context, examPage);
  }
 */
