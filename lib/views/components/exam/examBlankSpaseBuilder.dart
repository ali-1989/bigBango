import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/examStateMethods.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/controllers/examController.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/tools/app/appOverlay.dart';
import 'package:app/views/widgets/animationPositionScale.dart';

class ExamBlankSpaceBuilder extends StatefulWidget {
  static const questionTitle = 'در جای خالی کلمه ی مناسب بنویسید';

  final ExamModel examModel;

  const ExamBlankSpaceBuilder({
    required this.examModel,
    Key? key
  }) : super(key: key);

  @override
  State<ExamBlankSpaceBuilder> createState() => ExamBlankSpaceBuilderState();
}
///======================================================================================================================
class ExamBlankSpaceBuilderState extends StateBase<ExamBlankSpaceBuilder> with ExamStateMethods {
  late TextStyle questionNormalStyle;
  late TextStyle falseStyle;
  late ExamModel exam;

  @override
  void initState(){
    super.initState();

    exam = widget.examModel;

    /*final starLen = x.question.split('**').length;
    if(x.teacherOptions.length != starLen-1){
      return true;
    }*/
    
    questionNormalStyle = const TextStyle(fontSize: 16, color: Colors.black);
    falseStyle = const TextStyle(fontSize: 16,
        color: AppDecoration.red,
        decorationStyle: TextDecorationStyle.solid,
        decoration: TextDecoration.lineThrough,
        decorationColor: AppDecoration.red
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
        builder: (ctx, ctr, data){
          return buildBody();
        }
    );
  }

  Widget buildBody(){
    final List<InlineSpan> spans = generateSpans(exam);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

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

            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
  
  List<InlineSpan> generateSpans(ExamModel exam){
    final List<InlineSpan> spans = [];

    for(int i = 0; i < exam.getExamItem().questionSplit.length; i++) {
      spans.add(TextSpan(text: exam.getExamItem().questionSplit[i], style: questionNormalStyle));

      if(i < exam.getExamItem().questionSplit.length-1) {
        InlineSpan blankSpan;
        InlineSpan? correctSpan;
        String blankText = '';
        bool hasUserAnswer = exam.getExamItem().userAnswers[i].text.isNotEmpty;

        final tapRecognizer = TapGestureRecognizer()..onTapUp = (gesDetail){
          if(exam.showAnswer){
            return;
          }

          TextEditingController tControl = TextEditingController();
          FocusNode focusNode = FocusNode();
          tControl.text = exam.getExamItem().userAnswers[i].text;
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
                      top: 80,
                      left: 0,
                      right: 0,
                      child: AnimationPositionScale(
                        x: gesDetail.globalPosition.dx,
                        y: gesDetail.globalPosition.dy,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Card(
                              color: Colors.grey.shade200,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: TextField(
                                    controller: tControl,
                                    focusNode: focusNode,
                                    style: const TextStyle(fontSize: 16),
                                    onChanged: (t){
                                      exam.getExamItem().userAnswers[i].text = t.trim();
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
          Future.delayed(const Duration(milliseconds: 400), (){
            tControl.selection = TextSelection.collapsed(offset: exam.getExamItem().userAnswers[i].text.length);
            focusNode.requestFocus();
          });
        };

        if(exam.showAnswer){
          Color trueColor = Colors.green;
          Color falseColor = AppDecoration.red;

          ///answer is correct

          if(exam.getExamItem().userAnswers[i].text == exam.getExamItem().teacherOptions[i].text){
            blankSpan = WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //Image.asset(AppImages.trueCheckIco),
                    //SizedBox(width: 2),
                    Text(exam.getExamItem().userAnswers[i].text, style: questionNormalStyle.copyWith(color: trueColor))
                  ],
                )
            );
          }
          /// answer is wrong
          else {
            if(hasUserAnswer) {
              blankText = exam.getExamItem().userAnswers[i].text;
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
                      const SizedBox(width: 4),
                      //Image.asset(AppImages.trueCheckIco),
                      const SizedBox(width: 2),
                      Text(exam.items[0].teacherOptions[i].text,
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
              blankText = exam.items[0].teacherOptions[i].text;// '[\u00A0_\u00A0]';

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
          Color blankColor = Colors.grey;

          if(hasUserAnswer){
            blankText = ' ${exam.getExamItem().userAnswers[i].text} ';
          }
          else {
            blankText = ' [\u00A0____\u00A0] '; // \u202F , \u2007
            blankColor = Colors.grey.shade200;
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
  void showAnswer(bool state) {
    exam.showAnswer = state;

    assistCtr.updateHead();
  }
}
