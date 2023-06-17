import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/views/widgets/sliders.dart';
import 'package:flutter/material.dart';

import 'package:animator/animator.dart';
import 'package:iris_tools/api/duration/durationFormatter.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/examStateMethods.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/builders/examBuilderContent.dart';
import 'package:app/structures/controllers/examController.dart';
import 'package:app/structures/enums/quizType.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/system/extensions.dart';
import 'package:iris_tools/widgets/customCard.dart';
import 'package:just_audio/just_audio.dart';

class ExamOptionBuilder extends StatefulWidget {
  final ExamBuilderContent builder;
  final String controllerId;
  final int? index;
  final bool showTitle;

  const ExamOptionBuilder({
    required this.builder,
    required this.controllerId,
    this.showTitle = true,
    this.index,
    Key? key
  }) : super(key: key);

  @override
  State<ExamOptionBuilder> createState() => _ExamOptionBuilderState();
}
///==============================================================================================================
class _ExamOptionBuilderState extends StateBase<ExamOptionBuilder> with ExamStateMethods {
  List<ExamModel> examList = [];
  late TextStyle questionNormalStyle;
  AudioPlayer player = AudioPlayer();
  Duration totalTime = Duration();
  Duration currentTime = Duration();
  bool voiceIsOk = false;
  bool isInPlaying = false;
  double playerSliderValue = 0;
  String id$playViewId = 'playViewId';

  @override
  void initState(){
    super.initState();

    if(widget.index == null) {
      examList.addAll(widget.builder.examList.where((element) => element.quizType == QuizType.multipleChoice));
    }
    else {
      examList.add(widget.builder.examList[widget.index!]);
    }

    ExamController(widget.controllerId, this);
    questionNormalStyle = TextStyle(fontSize: 16, color: Colors.black);
  }

  @override
  void dispose(){
    player.stop();
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
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          itemCount: widget.showTitle ? examList.length *2 : (examList.length *2 -1),
          itemBuilder: buildQuestionAndOptions,
        ),
      ),
    );
  }

  Widget buildQuestionAndOptions(_, int idx){
    if(widget.showTitle && idx == 0){
      return Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text('با توجه به سوال گزینه ی مناسب را انتخاب کنید'),
        ),
      );
    }

    bool showDivider = widget.showTitle? (idx % 2 == 0) : (idx % 2 != 0);

    ///=== Divider
    if(showDivider){
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Divider(color: Colors.black12, height: 1),
      );
    }

    int itmIdx = widget.showTitle? ((idx-1) ~/2) : (idx~/2);
    final curExam = examList[itmIdx];

    return Column(
      key: ValueKey(curExam.getFirst().id),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),

        /// question
        Builder(
            builder: (_){
              if(curExam.voice != null){
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
                                            padding: EdgeInsets.symmetric(horizontal: 14, vertical:4),
                                            child: Column(
                                              children: [
                                                Text(DurationFormatter.duration(currentTime, showSuffix: false), style: TextStyle(fontSize: 10, color: Colors.white)),
                                                Text(DurationFormatter.duration(totalTime, showSuffix: false), style: TextStyle(fontSize: 10, color: Colors.white)),
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
                                              thumbShape: CustomThumb(),
                                              valueIndicatorShape: CustomThumb(),
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
                                        SizedBox(width: 14),

                                        GestureDetector(
                                          onTap: (){
                                            playSound(curExam);
                                          },
                                          child: CustomCard(
                                              color: Colors.white,
                                              radius: 20,
                                              padding: EdgeInsets.all(5),
                                              child: isPlaying() ?
                                              Icon(AppIcons.pause, size: 20)
                                                  : Icon(AppIcons.playArrow, size: 20)
                                          ),
                                        ),

                                        SizedBox(width: 10),
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
                    curExam.getFirst().question,
                    style: TextStyle(fontSize: 12, height: 1.7),
                    textAlign: TextAlign.justify,
                  ),
                ).wrapDotBorder(
                  color: Colors.grey.shade600,
                  radius: 5,
                ),
              );
            }
        ),

        SizedBox(height: 10),
        ...buildOptions(curExam),
        SizedBox(height: 10)
      ],
    );
  }

  List<Widget> buildOptions(ExamModel curExam){
    List<Widget> res = [];

    for(final opt in curExam.items[0].options){
      final w = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          if(curExam.showAnswer){
            return;
          }

          bool isSelected = curExam.getFirst().getUserChoiceById(opt.id) != null;

          if(isSelected){
            curExam.getFirst().userAnswers.removeWhere((element) => element.id == opt.id);
          }
          else {
            final ex = ExamOptionModel()..order = opt.order;
            ex.id = opt.id;

            curExam.getFirst().userAnswers.clear();
            curExam.getFirst().userAnswers.add(ex);
          }

          assistCtr.updateHead();
        },
        child: AnimateWidget(
          resetOnRebuild: true,
          triggerOnRebuild: true,
          duration: Duration(milliseconds: 400),
          cycles: 1,
          builder: (_, animate){
            final optionIdx = curExam.items[0].options.indexOf(opt);
            bool isSelected = curExam.getFirst().getUserChoiceById(opt.id) != null;
            bool isCorrect = optionIdx == curExam.getFirst().getIndexOfCorrectChoice();

            Color backColor;

            if(curExam.showAnswer){
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

            TextStyle selectStl = TextStyle(color: Colors.white, fontWeight: FontWeight.w700);
            TextStyle unSelectStl = TextStyle(color: Colors.black87);

            return DecoratedBox(
              decoration: BoxDecoration(
                  color: (isSelected || (!isSelected && curExam.showAnswer && isCorrect))? backColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(5)
              ),
              child: Row(
                children: [
                  Text('  ${optionIdx+1} -  ', style: (isSelected || (!isSelected && curExam.showAnswer && isCorrect))? selectStl : unSelectStl).englishFont(),
                  Text(opt.text, style: (isSelected || (!isSelected && curExam.showAnswer && isCorrect))? selectStl : unSelectStl).englishFont(),
                ],
              ).wrapBoxBorder(
                  color: Colors.black,
                  alpha: 100,
                  radius: 5,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 5)
              ),
            );
          },
        ),
      );

      res.add(SizedBox(height: 10));
      res.add(w);
    }

    return res;
  }

  @override
  bool isAnswerToAll(){
    for(final k in examList){
      if (k.getFirst().userAnswers.isEmpty) {
        return false;
      }
    }

    return true;
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
        await player.seek(Duration());
        await player.play();
      }
    }
  }

  Future<void> prepareVoice(ExamModel curExam) async {
    voiceIsOk = false;

    if(curExam.voice?.fileLocation == null){
      return;
    }

    return player.setUrl(curExam.voice?.fileLocation?? '').then((dur) {
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