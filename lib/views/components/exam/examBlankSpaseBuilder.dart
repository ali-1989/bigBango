import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/examStateMethods.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/builders/examBuilderContent.dart';
import 'package:app/structures/controllers/examController.dart';
import 'package:app/structures/enums/quizType.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/tools/app/appOverlay.dart';
import 'package:app/views/widgets/animationPositionScale.dart';

class ExamBlankSpaceBuilder extends StatefulWidget {
  final ExamBuilderContent content;
  final String controllerId;
  final int? index;
  final bool showTitle;

  const ExamBlankSpaceBuilder({
    required this.content,
    required this.controllerId,
    this.showTitle = true,
    this.index,
    Key? key
  }) : super(key: key);

  @override
  State<ExamBlankSpaceBuilder> createState() => ExamBlankSpaceBuilderState();
}
///======================================================================================================================
class ExamBlankSpaceBuilderState extends StateBase<ExamBlankSpaceBuilder> with ExamStateMethods {
  late TextStyle questionNormalStyle;
  late TextStyle falseStyle;
  List<ExamModel> examList = [];

  @override
  void initState(){
    super.initState();

    if(widget.index == null) {
      examList.addAll(widget.content.examList.where((element) => element.quizType == QuizType.fillInBlank));
    }
    else {
      examList.add(widget.content.examList[widget.index!]);
    }

    examList.removeWhere((element) {
      for(var x in element.items){
        final starLen = x.question.split('**').length;
        if(x.options.length != starLen-1){
          return true;
        }
      }

      return false;
    });

    questionNormalStyle = TextStyle(fontSize: 16, color: Colors.black);
    falseStyle = TextStyle(fontSize: 16,
        color: Colors.red,
        decorationStyle: TextDecorationStyle.solid,
        decoration: TextDecoration.lineThrough,
        decorationColor: Colors.red
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
        builder: (ctx, ctr, data){
          return buildBody();
        }
    );
  }

  Widget buildBody(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomScrollView(
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        slivers: [
          SliverVisibility(
              visible: widget.showTitle,
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text('جای خالی را با کلمه مناسب پر کنید'),
                ),
              )
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              listItemBuilder,
              childCount: examList.length *2 -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget listItemBuilder(ctx, idx){
    ///=== Divider
    if(idx % 2 != 0){
      return Divider(color: Colors.black38, height: 1);
    }

    final item = examList[idx~/2];
    final List<InlineSpan> spans = generateSpans(item);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),

          ///=== number box
          /*Visibility(
            visible: examList.length > 1,
            child: CustomCard(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text('${idx~/2 + 1}').bold(weight: FontWeight.w900).fsR(1),
            ).wrapBoxBorder(
              padding: EdgeInsets.all(2),
              radius: 9,
              stroke: 1.0,
              color: Colors.black
            ),
          ),*/

          //SizedBox(height: 15),
          RichText(
            text: TextSpan(children: spans),
          ),

          SizedBox(height: 14),
        ],
      ),
    );
  }

  List<InlineSpan> generateSpans(ExamModel exam){
    final List<InlineSpan> spans = [];

    for(int i = 0; i < exam.getFirst().questionSplit.length; i++) {
      spans.add(TextSpan(text: exam.getFirst().questionSplit[i], style: questionNormalStyle));

      if(i < exam.getFirst().questionSplit.length-1) {
        InlineSpan blankSpan;
        InlineSpan? correctSpan;
        String blankText = '';
        bool hasUserAnswer = exam.getFirst().userAnswers[i].text.isNotEmpty;

        final tapRecognizer = TapGestureRecognizer()..onTapUp = (gesDetail){
          if(exam.showAnswer){
            return;
          }

          TextEditingController tControl = TextEditingController();
          FocusNode focusNode = FocusNode();
          tControl.text = exam.getFirst().userAnswers[i].text;
          late final OverlayEntry txtFieldOver;

          txtFieldOver = OverlayEntry(
              builder: (_) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: (){
                          txtFieldOver.remove();
                          txtFieldOver.dispose();
                          focusNode.dispose();
                          tControl.dispose();
                        },
                      ),
                    ),

                    Positioned(
                      top: 60,
                      left: 0,
                      right: 0,
                      child: AnimationPositionScale(
                        x: gesDetail.globalPosition.dx,
                        y: gesDetail.globalPosition.dy,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Card(
                              color: Colors.blue.shade200,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: TextField(
                                    controller: tControl,
                                    focusNode: focusNode,
                                    style: TextStyle(fontSize: 16),
                                    onChanged: (t){
                                      exam.getFirst().userAnswers[i].text = t.trim();
                                      assistCtr.updateHead();
                                    },
                                    onSubmitted: (t){
                                      txtFieldOver.remove();
                                      txtFieldOver.dispose();
                                      focusNode.dispose();
                                      //tControl.dispose();
                                    },
                                  ),
                                ),
                              )
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
          );

          /// show TextField
          AppOverlay.showOverlay(context, txtFieldOver);

          /// request focus
          Future.delayed(Duration(milliseconds: 400), (){
            tControl.selection = TextSelection.collapsed(offset: exam.getFirst().userAnswers[i].text.length);
            focusNode.requestFocus();
          });
        };

        if(exam.showAnswer){
          Color trueColor = Colors.green;
          Color falseColor = Colors.red;

          ///answer is correct

          if(exam.getFirst().userAnswers[i].text == exam.getFirst().options[i].text){
            blankSpan = WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //Image.asset(AppImages.trueCheckIco),
                    //SizedBox(width: 2),
                    Text(exam.getFirst().userAnswers[i].text, style: questionNormalStyle.copyWith(color: trueColor))
                  ],
                )
            );
          }
          /// answer is wrong
          else {
            if(hasUserAnswer) {
              blankText = exam.getFirst().userAnswers[i].text;
              blankSpan = WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //Image.asset(AppImages.falseCheckIco),
                      //SizedBox(width: 2),
                      Text(blankText, style: falseStyle.copyWith(color: falseColor, ))
                    ],
                  )
              );

              correctSpan = WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 4),
                      //Image.asset(AppImages.trueCheckIco),
                      SizedBox(width: 2),
                      Text(exam.items[0].options[i].text,
                          style: questionNormalStyle.copyWith(
                            color: trueColor,
                            decorationStyle: TextDecorationStyle.solid,
                            decoration: TextDecoration.underline,
                            decorationColor: trueColor,
                          )
                      )
                    ],
                  )
              );
            }
            else {
              blankText = exam.items[0].options[i].text;// '[\u00A0_\u00A0]';

              /// answer is wrong
              blankSpan = WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //Image.asset(AppImages.falseCheckIco),
                      //SizedBox(width: 2),
                      Text(blankText, style: questionNormalStyle.copyWith(color: falseColor))
                    ],
                  )
              );
            }
          }
        }
        else {
          Color blankColor = Colors.blue;

          if(hasUserAnswer){
            blankText = ' ${exam.getFirst().userAnswers[i].text} ';
          }
          else {
            blankText = ' [\u00A0____\u00A0] '; // \u202F , \u2007
            blankColor = Colors.blue.shade200;
          }

          /// blank space ==> [xxx]
          blankSpan = TextSpan(
            text: blankText,
            style: questionNormalStyle.copyWith(color: blankColor),
            recognizer: tapRecognizer,
          );
        }

        spans.add(blankSpan);

        if(correctSpan != null){
          spans.add(correctSpan);
        }
      }
    }

    return spans;
  }

  @override
  bool isAnswerToAll(){
    for(final k in examList){
      for(final x in k.getFirst().userAnswers) {
        if (x.text.isEmpty) {
          return false;
        }
      }
    }

    return true;
  }

  @override
  void showAnswers(bool state) {
    for (final element in examList) {
      element.showAnswer = state;
    }

    assistCtr.updateHead();
  }

  @override
  void showAnswer(String examId, bool state) {
    for (final element in examList) {
      if(element.items[0].id == examId){
        element.showAnswer = state;
        break;
      }
    }

    assistCtr.updateHead();
  }
}