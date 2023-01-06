import 'package:app/structures/enums/quizType.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/injectors/examPageInjector.dart';
import 'package:app/structures/interfaces/examStateInterface.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/views/widgets/customCard.dart';

class ExamSelectWordComponent extends StatefulWidget {
  final ExamPageInjector injector;

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
  List<ExamModel> examList = [];

  @override
  void initState() {
    super.initState();

    widget.injector.state = this;
    examList.addAll(widget.injector.examList.where((element) => element.exerciseType == QuizType.recorder));
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
                      childCount: examList.length * 2 - 1,
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

    final item = examList[idx ~/ 2];
    final List<InlineSpan> spans = generateSpans(item);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),

          ///=== number box
          Visibility(
            visible: examList.length > 1,
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

            assistCtr.updateHead();
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
      for (final k in model.userAnswers){
        if(k.id == ec.id){
          return;
        }
      }

      AppToast.showToast(context, 'ابتدا جای خالی را انتخاب کنید');
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

    assistCtr.updateHead();
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
  bool isAllAnswer(){
    for(final k in examList){
      for(final x in k.userAnswers) {
        if (x.text.isEmpty) {
          return false;
        }
      }
    }

    return true;
  }

  @override
  void checkAnswers() {
    bool isAllSelected = true;

    for (final model in examList) {
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
    assistCtr.updateHead();
  }
}