import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/examSelectWordModel.dart';
import 'package:app/models/lessonModels/iSegmentModel.dart';
import 'package:app/models/lessonModels/lessonModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appOverlay.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/views/widgets/animationPositionScale.dart';
import 'package:app/views/widgets/customCard.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

class ExamSelectWordInjector {
  late LessonModel lessonModel;
  late ISegmentModel segment;
}
///-----------------------------------------------------
class ExamSelectWordPage extends StatefulWidget {
  final ExamSelectWordInjector injector;

  const ExamSelectWordPage({
    required this.injector,
    Key? key
  }) : super(key: key);

  @override
  State<ExamSelectWordPage> createState() => _ExamSelectWordPageState();
}
///======================================================================================================================
class _ExamSelectWordPageState extends StateBase<ExamSelectWordPage> {
  List<ExamSelectWordModel> examItems = [];
  Map<int, List<int>> selectedWords = {};
  bool showAnswers = false;
  late TextStyle questionNormalStyle;

  @override
  void initState(){
    super.initState();

    questionNormalStyle = TextStyle(fontSize: 16, color: Colors.black);

    List.generate(10, (index) {
      final m = ExamSelectWordModel()..id = index;
      m.question = Generator.generateWords(10, 3, 10);
      m.words = List.generate(4, (index) {return Generator.generateWords(1, 3, 8);});

      examItems.add(m);
    });

    for(final k in examItems){
      k.doSplitQuestion();
      selectedWords[k.id] = [];
    }
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
      child: Column(
        children: [

          /// exam
          Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                        listItemBuilder,
                      childCount: examItems.length *2 -1,
                    ),
                  ),

                  SliverToBoxAdapter(
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
                  )
                ],
              )
          ),
        ],
      ),
    );
  }

  Widget listItemBuilder(ctx, idx){
    ///=== Divider
    if(idx % 2 != 0){
      return Divider(color: Colors.black, height: 2);
    }

    final item = examItems[idx~/2];
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

  List<InlineSpan> generateSpans(ExamSelectWordModel model){
    final List<InlineSpan> spans = [];

    for(int i = 0; i < model.questionSplit.length; i++) {
      spans.add(TextSpan(text: model.questionSplit[i], style: questionNormalStyle));

      if(i < model.questionSplit.length-1) {
        InlineSpan blankSpan;
        String blankText = '';
        Color blankColor;
        bool hasUserAnswer = model.userAnswers[i].isNotEmpty;
        final tapRecognizer = TapGestureRecognizer()..onTapUp = (gesDetail){

          if(showAnswers){
            return;
          }

          TextEditingController tControl = TextEditingController();
          FocusNode focusNode = FocusNode();
          tControl.text = model.userAnswers[i];
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
                                      model.userAnswers[i] = t.trim();
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

          AppOverlay.showOverlay(context, over);
          Future.delayed(Duration(milliseconds: 600), (){
            tControl.selection = TextSelection.collapsed(offset: model.userAnswers[i].length);
            focusNode.requestFocus();
          });
        };

        if(showAnswers){
          if(model.userAnswers[i] == 'hi'){
            blankColor = Colors.green;
            /// correct span
            blankSpan = WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(AppImages.trueCheckIco),
                    SizedBox(width: 5),
                    Text(model.userAnswers[i], style: questionNormalStyle.copyWith(color: blankColor))
                  ],
                )
            );
          }
          else {
            blankColor = Colors.red;
            blankText = model.userAnswers[i].isNotEmpty? model.userAnswers[i]: '[\u00A0_\u00A0]';
            /// wrong span
            blankSpan = WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(AppImages.falseCheckIco),
                    SizedBox(width: 5),
                    Text(blankText, style: questionNormalStyle.copyWith(color: blankColor))
                  ],
                )
            );
          }
        }
        else {
          if(hasUserAnswer){
            blankText = ' ${model.userAnswers[i]} ';
            blankColor = Colors.blue;
          }
          else {
            blankText = '\u00A0_____\u00A0';
            blankColor = Colors.blue.shade200;
          }

          blankSpan = TextSpan(
            text: blankText,
            style: questionNormalStyle.copyWith(color: blankColor),
            recognizer: tapRecognizer,
          );
        }

        spans.add(blankSpan);
      }
    }

    return spans;
  }

  Widget buildWords(ExamSelectWordModel model){
    int lastIndex = -1;

    return Row(
      children: [
        ...model.shuffleWords.map((w){
          final idx = model.shuffleWords.indexOf(w, lastIndex);
          final isSelected = selectedWords[model.id]!.contains(idx);
          lastIndex++;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: (){
                onWordClick(model.id, idx);
              },
              child: CustomCard(
                color: isSelected? Colors.lightBlueAccent : Colors.grey.shade200,
                  radius: 2,
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  child: Text(w)
              ),
            ),
          );
        }),
      ],
    );

  }

  void onWordClick(int questionId, int wordIdx){
    if(selectedWords[questionId]!.contains(wordIdx)) {
      selectedWords[questionId]!.remove(wordIdx);
    }
    else {
      selectedWords[questionId]!.add(wordIdx);
    }

    assistCtr.updateMain();
  }

  void onCheckClick(){
    bool isAllSelected = true;

    for(final exam in examItems){
      final selected = selectedWords[exam.id]!;

      if(exam.words.length > selected.length){
        isAllSelected = false;
        break;
      }
    }

    if(!isAllSelected){
      AppSnack.showError(context, 'لطفا همه ی گزینه ها را انتخاب کنید');
      return;
    }

    showAnswers = !showAnswers;
    assistCtr.updateMain();
  }
}


