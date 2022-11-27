import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/interfaces/examStateInterface.dart';
import 'package:app/structures/models/examModel.dart';
import 'package:app/structures/injectors/examInjector.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appOverlay.dart';
import 'package:app/views/widgets/animationPositionScale.dart';
import 'package:app/views/widgets/customCard.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';


class ExamBlankSpaceComponent extends StatefulWidget {
  final ExamInjector injector;

  const ExamBlankSpaceComponent({
    required this.injector,
    Key? key
  }) : super(key: key);

  @override
  State<ExamBlankSpaceComponent> createState() => ExamBlankSpaceComponentState();
}
///======================================================================================================================
class ExamBlankSpaceComponentState extends StateBase<ExamBlankSpaceComponent> implements ExamStateInterface {
  bool showAnswers = false;
  late TextStyle questionNormalStyle;

  @override
  void initState(){
    super.initState();

    widget.injector.state = this;
    questionNormalStyle = TextStyle(fontSize: 16, color: Colors.black);
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomScrollView(
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              listItemBuilder,
              childCount: widget.injector.examList.length *2 -1,
            ),
          ),

          /*SliverToBoxAdapter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
                    ),
                    onPressed: onCheckClick,
                    child: Text('ثبت و بررسی'),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          )*/
        ],
      ),
    );
  }

  Widget listItemBuilder(ctx, idx){
    ///=== Divider
    if(idx % 2 != 0){
      return Divider(color: Colors.black, height: 2);
    }

    final item = widget.injector.examList[idx~/2];
    final List<InlineSpan> spans = generateSpans(item);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          ///=== number box
          CustomCard(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text('${idx~/2 + 1}').bold(weight: FontWeight.w900).fsR(1),
          ).wrapBoxBorder(
            padding: EdgeInsets.all(2),
            radius: 9,
            stroke: 1.0,
            color: Colors.black
          ),

          SizedBox(height: 15),
          RichText(
            text: TextSpan(children: spans),
            textDirection: TextDirection.ltr,
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  List<InlineSpan> generateSpans(ExamModel exam){
    final List<InlineSpan> spans = [];

    for(int i = 0; i < exam.questionSplit.length; i++) {
      spans.add(TextSpan(text: exam.questionSplit[i], style: questionNormalStyle));

      if(i < exam.questionSplit.length-1) {
        InlineSpan blankSpan;
        InlineSpan? correctSpan;
        String blankText = '';
        bool hasUserAnswer = exam.userAnswers[i].text.isNotEmpty;

        final tapRecognizer = TapGestureRecognizer()..onTapUp = (gesDetail){
          if(showAnswers){
            return;
          }

          TextEditingController tControl = TextEditingController();
          FocusNode focusNode = FocusNode();
          tControl.text = exam.userAnswers[i].text;
          late final OverlayEntry over;

          over = OverlayEntry(
              builder: (_) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: (){
                          over.remove();
                          over.dispose();
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
                                      exam.userAnswers[i].text = t.trim();
                                      assistCtr.updateMain();
                                    },
                                    onSubmitted: (t){
                                      over.remove();
                                      over.dispose();
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
          AppOverlay.showOverlay(context, over);

          /// request focus
          Future.delayed(Duration(milliseconds: 600), (){
            tControl.selection = TextSelection.collapsed(offset: exam.userAnswers[i].text.length);
            focusNode.requestFocus();
          });
        };

        if(showAnswers){
          Color trueColor = Colors.green;
          Color falseColor = Colors.red;

          if(exam.userAnswers[i].text == exam.choices[i].text){

            ///answer is correct
            blankSpan = WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(AppImages.trueCheckIco),
                    SizedBox(width: 2),
                    Text(exam.userAnswers[i].text, style: questionNormalStyle.copyWith(color: trueColor))
                  ],
                )
            );
          }
          else {
            if(hasUserAnswer) {
              blankText = exam.userAnswers[i].text;

              /// answer is wrong
              blankSpan = WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(AppImages.falseCheckIco),
                      SizedBox(width: 2),
                      Text(blankText, style: questionNormalStyle.copyWith(color: falseColor))
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
                      Text(exam.choices[i].text,
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
              blankText = exam.choices[i].text;// '[\u00A0_\u00A0]';

              /// answer is wrong
              blankSpan = WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(AppImages.falseCheckIco),
                      SizedBox(width: 2),
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
            blankText = ' ${exam.userAnswers[i].text} ';
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
  void checkAnswers() {
    showAnswers = !showAnswers;
    assistCtr.updateMain();
  }
}


