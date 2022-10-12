import 'dart:math';

import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/examBlankModel.dart';
import 'package:app/models/lessonModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appOverlay.dart';
import 'package:app/views/animationPositionScale.dart';
import 'package:app/views/customCard.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

class ExamBlankSpacePageInjection {
  late LessonModel lessonModel;
  late String segmentTitle;
}
///-----------------------------------------------------
class ExamBlankSpacePage extends StatefulWidget {
  final ExamBlankSpacePageInjection injection;

  const ExamBlankSpacePage({
    required this.injection,
    Key? key
  }) : super(key: key);

  @override
  State<ExamBlankSpacePage> createState() => _ExamBlankSpacePageState();
}
///======================================================================================================================
class _ExamBlankSpacePageState extends StateBase<ExamBlankSpacePage> {
  List<ExamBlankModel> examItems = [];
  bool showAnswers = false;

  @override
  void initState(){
    super.initState();

    List.generate(10, (index) {
      final m = ExamBlankModel()..id = index;
      m.question = generateWords(20, 2, 10);

      examItems.add(m);
    });

    for(final k in examItems){
      final splits = k.question.split('*****');

      for(final f in splits) {
        k.userAnswers.add('');
      }
    }
  }

  String generateWords(int wordCount, int minWordLen, int maxWordLean){
    final List<String> words = [];
    words.add('hi');
    words.add('and');
    words.add('good');
    words.add('goodBy');
    words.add('good morning');
    words.add('hello');
    words.add('what');
    words.add('is');
    words.add('not');
    words.add('same');
    words.add('some');
    words.add('where');
    words.add('*****');
    words.add('who');
    words.add('mr');
    words.add('miss');
    words.add('book');
    words.add('flower');
    words.add('computer');
    words.add('wallet');
    words.add('device');
    words.add('go');
    words.add('back');
    words.add('next');

    List<String> res = [];
    final r = Random();

    while(res.length < wordCount){
      final w = words[r.nextInt(words.length)];

      if(w.length >= minWordLen && w.length <= maxWordLean) {
        res.add(w);
      }
    }

    return res.join(' ');
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
          return Scaffold(
            body: SafeArea(
                child: buildBody()
            ),
          );
        }
    );
  }

  Widget buildBody(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(height: 20),

          DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
              ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 4,
                        height: 26,
                        child: ColoredBox(color: Colors.red),
                      ),

                      SizedBox(width: 7),
                      Text('تمرین').bold().fsR(4),
                    ],
                  ),

                  GestureDetector(
                    onTap: (){
                      AppNavigator.pop(context);
                    },
                    child: Row(
                      children: [
                        Text(AppMessages.back),
                        SizedBox(width: 10),
                        CustomCard(
                            color: Colors.white,
                            padding: EdgeInsets.all(5),
                            child: Image.asset(AppImages.arrowLeftIco)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 10),
          Row(
            children: [
              Text(' جای خالی را پر کنید')
            ],
          ),
          SizedBox(height: 14),

          /// exam
          Expanded(
              child: ListView.separated(
                itemCount: examItems.length,
                itemBuilder: listItemBuilder,
                separatorBuilder: (ctx, idx){
                  return Divider(color: Colors.black, height: 2);
                },
              )
          ),



          SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
              ),
              onPressed: (){
                showAnswers = !showAnswers;
                assistCtr.updateMain();
              },
              child: Text('ثبت و بررسی'),
            ),
          ),
          SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget listItemBuilder(ctx, idx){
    final item = examItems[idx];
    final List<String> splits = item.question.split('*****');
    final List<InlineSpan> spans = [];

    for(int i = 0; i < splits.length; i++){
      spans.add(TextSpan(text: splits[i], style: TextStyle(fontSize: 16, color: Colors.black)));

      if(i < splits.length-1) {
        String t = '';
        bool hasUserAnswer = item.userAnswers[i] != '';

        if(showAnswers){
          if(item.userAnswers[i] == 'hi'){
            spans.add(WidgetSpan(child: Image.asset(AppImages.trueCheckIco)));
          }
          else {
            spans.add(WidgetSpan(child: Image.asset(AppImages.falseCheckIco)));
          }
        }

        // ‍ \u2060
        if(hasUserAnswer){
          t = '${showAnswers? '\u00A0' : ' '}${item.userAnswers[i]} ';
        }
        else {
          t = ' [\u00A0____\u00A0] ';
        }



        final s = TextSpan(
            text: t,
            style: TextStyle(fontSize: 16, color: hasUserAnswer? Colors.blue: Colors.blue.shade200),
            recognizer: TapGestureRecognizer()..onTapUp = (de){

              late final OverlayEntry over;
              TextEditingController tControl = TextEditingController();
              FocusNode focusNode = FocusNode();
              tControl.text = item.userAnswers[i];

              over = OverlayEntry(
                  builder: (BuildContext context) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: (){
                              over.remove();
                              over.dispose();
                              tControl.dispose();
                            },
                          ),
                        ),

                        Positioned(
                          top: 60,
                          left: 0,
                          right: 0,
                          child: AnimationPositionScale(
                            x: de.globalPosition.dx,
                            y: de.globalPosition.dy,
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
                                          item.userAnswers[i] = t.trim();
                                          assistCtr.updateMain();
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

              AppOverlay.showOverlay(context, over);
              Future.delayed(Duration(milliseconds: 700), (){
                tControl.selection = TextSelection.collapsed(offset: item.userAnswers[i].length);
                focusNode.requestFocus();
              });
          },
        );

        spans.add(s);
      }
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          CustomCard(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text('${idx + 1}').bold(weight: FontWeight.w900).fsR(1),
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
}


