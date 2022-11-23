import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/examBlankSpaceModel.dart';
import 'package:app/models/lessonModels/iSegmentModel.dart';
import 'package:app/models/lessonModels/lessonModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appOverlay.dart';
import 'package:app/views/widgets/animationPositionScale.dart';
import 'package:app/views/widgets/customCard.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

class ExamBlankSpaceInjector {
  late LessonModel lessonModel;
  late ISegmentModel segment;
}
///-----------------------------------------------------
class ExamBlankSpacePage extends StatefulWidget {
  final ExamBlankSpaceInjector injector;

  const ExamBlankSpacePage({
    required this.injector,
    Key? key
  }) : super(key: key);

  @override
  State<ExamBlankSpacePage> createState() => _ExamBlankSpacePageState();
}
///======================================================================================================================
class _ExamBlankSpacePageState extends StateBase<ExamBlankSpacePage> {
  List<ExamBlankSpaceModel> examItems = [];
  bool showAnswers = false;
  late TextStyle questionNormalStyle;

  @override
  void initState(){
    super.initState();

    questionNormalStyle = TextStyle(fontSize: 16, color: Colors.black);

    List.generate(10, (index) {
      final m = ExamBlankSpaceModel()..id = index;
      m.question = Generator.generateWords(20, 2, 10);
      //m.question = '*****${m.question}';

      examItems.add(m);
    });

    for(final k in examItems){
      k.doSplitQuestion();
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

        /*
        ListView.separated(
                itemCount: examItems.length,
                itemBuilder: listItemBuilder,
                separatorBuilder: (ctx, idx){
                  return Divider(color: Colors.black, height: 2);
                },
              )
         */
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
          RichText(
            text: TextSpan(children: spans),
            textDirection: TextDirection.ltr,
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  void onCheckClick(){
    showAnswers = !showAnswers;
    assistCtr.updateMain();
  }

  List<InlineSpan> generateSpans(ExamBlankSpaceModel model){
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
            blankColor = AppColors.red;
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
            blankText = ' [\u00A0____\u00A0] '; // \u202F , \u2007
            blankColor = Colors.blue.shade200;
          }

          /// blank space ==> []
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
}


