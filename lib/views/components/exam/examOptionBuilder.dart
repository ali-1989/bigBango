import 'package:flutter/material.dart';

import 'package:iris_tools/api/duration/durationFormatter.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/custom_card.dart';
import 'package:just_audio/just_audio.dart';

import 'package:app/structures/abstract/examStateMethods.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/controllers/examController.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/views/components/custom_slider.dart';

class ExamOptionBuilder extends StatefulWidget {
  static const questionTitle = 'با توجه به سوال گزینه ی مناسب را انتخاب کنید';
  final ExamModel examModel;

  const ExamOptionBuilder({
    required this.examModel,
    Key? key
  }) : super(key: key);

  @override
  State<ExamOptionBuilder> createState() => _ExamOptionBuilderState();
}
///==============================================================================================================
class _ExamOptionBuilderState extends StateSuper<ExamOptionBuilder> with ExamStateMethods {
  late ExamModel exam;
  late TextStyle questionNormalStyle;
  AudioPlayer player = AudioPlayer();
  Duration totalTime = const Duration();
  Duration currentTime = const Duration();
  bool voiceIsOk = false;
  bool isInPlaying = false;
  double playerSliderValue = 0;
  String id$playViewId = 'playViewId';

  @override
  void initState(){
    super.initState();

    exam = widget.examModel;

    ExamController(widget.examModel, this);
    questionNormalStyle = const TextStyle(fontSize: 16, color: Colors.black);
  }

  @override
  void dispose(){
    player.stop();
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          key: ValueKey(exam.getExamItem().id),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            /// question
            Builder(
                builder: (_){
                  if(exam.voice != null){
                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: DecoratedBox(
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Assist(
                              controller: assistCtr,
                              id: id$playViewId,
                              builder: (_, ctr, data) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CustomCard(
                                                color: Colors.pinkAccent,
                                                radius: 4,
                                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical:4),
                                                child: Column(
                                                  children: [
                                                    Text(DurationFormatter.duration(currentTime, showSuffix: false), style: const TextStyle(fontSize: 10, color: Colors.white)),
                                                    Text(DurationFormatter.duration(totalTime, showSuffix: false), style: const TextStyle(fontSize: 10, color: Colors.white)),
                                                  ],
                                                )
                                            ),
                                          ],
                                        ),

                                        Expanded(
                                            child: Directionality(
                                              textDirection: TextDirection.ltr,
                                              child: SliderTheme(
                                                data: SliderTheme.of(context).copyWith(
                                                  thumbShape: CustomSlider(),
                                                  valueIndicatorShape: CustomSlider(),
                                                  valueIndicatorColor: Colors.transparent,
                                                  overlayColor: Colors.transparent,
                                                ),
                                                child: Slider(
                                                  value: playerSliderValue,
                                                  max: 100,
                                                  min: 0,
                                                  onChanged: (double value) {
                                                    if(totalTime.inMilliseconds < 2){
                                                      return;
                                                    }

                                                    int sec = totalTime.inSeconds * value ~/100;
                                                    player.seek(Duration(seconds: sec));
                                                    playerSliderValue = value;
                                                    assistCtr.updateAssist(id$playViewId);
                                                  },
                                                ),
                                              ),
                                            )
                                        ),

                                        Row(
                                          textDirection: TextDirection.ltr,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(width: 14),

                                            GestureDetector(
                                              onTap: (){
                                                playSound(exam);
                                              },
                                              child: CustomCard(
                                                  color: Colors.white,
                                                  radius: 20,
                                                  padding: const EdgeInsets.all(5),
                                                  child: isPlaying() ?
                                                  const Icon(AppIcons.pause, size: 20)
                                                      : const Icon(AppIcons.playArrow, size: 20)
                                              ),
                                            ),

                                            const SizedBox(width: 10),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                          )
                      ),
                    );
                  }

                  return DecoratedBox(
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Text(
                        exam.getExamItem().question,
                        style: const TextStyle(fontSize: 12, height: 1.7),
                        textAlign: TextAlign.justify,
                      ),
                    ).wrapDotBorder(
                      color: Colors.grey.shade600,
                      radius: 5,
                    ),
                  );
                }
            ),

            const SizedBox(height: 10),
            ...buildOptions(exam),
            const SizedBox(height: 10)
          ],
        ),
      ),
    );
  }
  
  /*List<Widget> buildOptions(ExamModel exam){
    List<Widget> res = [];

    for(final opt in exam.items[0].teacherOptions){
      final w = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          if(exam.showAnswer){
            return;
          }

          bool isSelected = exam.getExamItem().getUserOptionById(opt.id) != null;

          if(isSelected){
            exam.getExamItem().userAnswers.removeWhere((element) => element.id == opt.id);
          }
          else {
            final ex = ExamOptionModel()..order = opt.order;
            ex.id = opt.id;

            exam.getExamItem().userAnswers.clear();
            exam.getExamItem().userAnswers.add(ex);
          }

          assistCtr.updateHead();
        },
        child: AnimateWidget(
          resetOnRebuild: true,
          triggerOnRebuild: true,
          duration: const Duration(milliseconds: 400),
          cycles: 1,
          builder: (_, animate){
            final optionIdx = exam.items[0].teacherOptions.indexOf(opt);
            bool isSelected = exam.getExamItem().getUserOptionById(opt.id) != null;
            bool isCorrect = optionIdx == exam.getExamItem().getIndexOfCorrectOption();

            Color backColor;

            if(exam.showAnswer){
              if(isCorrect){
                backColor = Colors.green;
              }
              else {
                backColor = Colors.redAccent;
              }
            }
            else {
              backColor = animate.fromTween((v) => ColorTween(begin: Colors.teal, end:Colors.lightBlueAccent))!;
            }

            TextStyle selectStl = const TextStyle(color: Colors.white, fontWeight: FontWeight.w700);
            TextStyle unSelectStl = const TextStyle(color: Colors.black87);

            return DecoratedBox(
              decoration: BoxDecoration(
                  color: (isSelected || (!isSelected && exam.showAnswer && isCorrect))? backColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(5)
              ),
              child: Row(
                children: [
                  Text('  ${optionIdx+1} -  ', style: (isSelected || (!isSelected && exam.showAnswer && isCorrect))? selectStl : unSelectStl).englishFont(),
                  Text(opt.text, style: (isSelected || (!isSelected && exam.showAnswer && isCorrect))? selectStl : unSelectStl).englishFont(),
                ],
              ).wrapBoxBorder(
                  color: Colors.black,
                  alpha: 100,
                  radius: 5,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5)
              ),
            );
          },
        ),
      );

      res.add(const SizedBox(height: 10));
      res.add(w);
    }

    return res;
  }
*/

  List<Widget> buildOptions(ExamModel exam){
    List<Widget> res = [];

    for(final opt in exam.items[0].teacherOptions){
      final w = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          if(exam.showAnswer){
            return;
          }

          bool isSelected = exam.getExamItem().getUserOptionById(opt.id) != null;

          if(isSelected){
            exam.getExamItem().userAnswers.removeWhere((element) => element.id == opt.id);
          }
          else {
            final ex = ExamOptionModel()..order = opt.order;
            ex.id = opt.id;

            exam.getExamItem().userAnswers.clear();
            exam.getExamItem().userAnswers.add(ex);
          }

          assistCtr.updateHead();
        },
        child: Builder(
          builder: (_){
            final optionIdx = exam.getExamItem().teacherOptions.indexOf(opt);
            bool isSelected = exam.getExamItem().getUserOptionById(opt.id) != null;
            bool isCorrect = optionIdx == exam.getExamItem().getIndexOfCorrectOption();

            const trueColor = AppDecoration.green;
            const falseColor = AppDecoration.red;
            //final borderColor = isSelected? (exam.showAnswer? (isCorrect? trueColor: falseColor) : Colors.black): Colors.black;
            final borderColor = exam.showAnswer? (isSelected? (isCorrect? trueColor: falseColor): (isCorrect? trueColor:Colors.black)) : Colors.black;
            //final checkboxColor = exam.showAnswer? (isSelected? (isCorrect? trueColor: falseColor): (isCorrect? trueColor:Colors.black)) : Colors.black;

            TextStyle selectStl = const TextStyle(color: Colors.black, fontWeight: FontWeight.w700);
            TextStyle unSelectStl = const TextStyle(color: Colors.black87);

            return DecoratedBox(
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                border: Border.all(color: borderColor)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('  ${optionIdx+1} -  ', style: (isSelected || (!isSelected && exam.showAnswer && isCorrect))? selectStl : unSelectStl).englishFont(),
                      Text(opt.text, style: (isSelected || (!isSelected && exam.showAnswer && isCorrect))? selectStl : unSelectStl).englishFont(),
                    ],
                  ),

                  Builder(
                      builder: (_){
                        if(exam.showAnswer){
                          if(isSelected){
                            if(isCorrect){
                              return getSelectedGreenBox();
                            }
                            else {
                              return getSelectedRedBox();
                            }
                          }
                          else {
                            if(isCorrect){
                              return getSelectedGreenBox();
                            }
                            else {
                              return getEmptyBox();
                            }
                          }
                        }
                        else {
                          if(isSelected){
                            return getSelectedBlackBox();
                          }

                          return getEmptyBox();
                        }
                      }
                  ),
                  /*Checkbox(
                      value: exam.showAnswer? (isCorrect || isSelected) : isSelected,
                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      activeColor: borderColor,
                      fillColor: MaterialStateProperty.all(checkboxColor),
                      onChanged: (v){}
                  )*/
                ],
              ).wrapBoxBorder(
                  color: Colors.black,
                  alpha: 100,
                  radius: 5,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5)
              ),
            );
          },
        ),
      );

      res.add(const SizedBox(height: 10));
      res.add(w);
    }

    return res;
  }

  Widget getEmptyBox(){
    return Image.asset(AppImages.emptyBoxIco, color: Colors.grey.shade100);
  }

  Widget getSelectedRedBox(){
    return Image.asset(AppImages.selectLevelIco);
  }

  Widget getSelectedGreenBox(){
    return Image.asset(AppImages.selectLevelGreenIco);
  }

  Widget getSelectedBlackBox(){
    return Image.asset(AppImages.selectLevelBlackIco);
  }

  bool isPlaying() {
    return player.playing && player.position.inMilliseconds < totalTime.inMilliseconds;
  }

  void playSound(ExamModel exam) async {
    if(!voiceIsOk){
      AppToast.showToast(context, 'در حال آماده سازی صوت');
      await prepareVoice(exam);
    }

    if(isPlaying()){
      await player.pause();
    }
    else {
      if(player.position.inMilliseconds < totalTime.inMilliseconds) {
        await player.play();
      }
      else {
        await player.pause();
        await player.seek(const Duration());
        await player.play();
      }
    }
  }

  Future<void> prepareVoice(ExamModel exam) async {
    voiceIsOk = false;

    if(exam.voice?.fileLocation == null){
      return;
    }

    return player.setUrl(exam.voice?.fileLocation?? '').then((dur) {
      voiceIsOk = true;

      if(dur != null){
        totalTime = dur;
        //assistCtr.update(timerViewId);
      }

    }).onError((error, stackTrace) {
      if(error is PlayerException){
        if(error.toString().contains('Source error')){
          AppToast.showToast(context, 'آماده سازی صوت انجام نشد');
          return;
        }
      }
    });
  }

  @override
  void showAnswer(bool state) {
    exam.showAnswer = state;
    assistCtr.updateHead();
  }
}
