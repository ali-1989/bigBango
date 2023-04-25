import 'package:flutter/material.dart';

import 'package:iris_tools/api/duration/durationFormatter.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';
import 'package:just_audio/just_audio.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/builders/examBuilderContent.dart';
import 'package:app/structures/controllers/examController.dart';
import 'package:app/structures/enums/quizType.dart';
import 'package:app/structures/injectors/listeningPagesInjector.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/listeningModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/views/components/appbarLesson.dart';
import 'package:app/views/components/exam/examBlankSpaseBuilder.dart';
import 'package:app/views/components/exam/examOptionBuilder.dart';
import 'package:app/views/components/exam/examSelectWordBuilder.dart';
import 'package:app/views/states/backBtn.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:app/views/widgets/sliders.dart';

class ListeningPage extends StatefulWidget {
  final ListeningPageInjector injector;

  const ListeningPage({
    required this.injector,
    Key? key
  }) : super(key: key);

  @override
  State<ListeningPage> createState() => _ListeningPageState();
}
///======================================================================================================================
class _ListeningPageState extends StateBase<ListeningPage> {
  Requester requester = Requester();
  AudioPlayer player = AudioPlayer();
  Duration totalTime = Duration();
  Duration currentTime = Duration();
  ExamBuilderContent examContent = ExamBuilderContent();
  Widget examComponent = SizedBox();
  ExamController? examController;
  int currentItemIdx = 0;
  bool voiceIsOk = false;
  bool isInPlaying = false;
  List<ListeningModel> itemList = [];
  ListeningModel? currentItem;
  String id$playViewId = 'playViewId';
  String? description;
  double playerSliderValue = 0;

  @override
  void initState(){
    super.initState();

    examContent.showSendButton = false;
    assistCtr.addState(AssistController.state$loading);

    player.playbackEventStream.listen(eventListener);
    player.positionStream.listen(durationListener);

    requestListening();
  }

  @override
  void dispose(){
    requester.dispose();
    player.stop();

    PublicAccess.requestGetLessonProgress(widget.injector.lessonModel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
        builder: (ctx, ctr, data) {
          return Scaffold(
              body: SafeArea(
                  child: buildBody()
              )
          );
        }
    );
  }

  Widget buildBody(){
    if(assistCtr.hasState(AssistController.state$error)){
      return ErrorOccur(onTryAgain: onTryAgain, backButton: BackBtn());
    }

    if(assistCtr.hasState(AssistController.state$loading)){
      return WaitToLoad();
    }

    Color preColor = Colors.black;
    Color nextColor = Colors.black;

    if(currentItemIdx == 0){
      preColor = Colors.grey;
    }

    if(currentItemIdx == itemList.length-1){
      nextColor = Colors.grey;
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              SizedBox(height: 10),
              AppbarLesson(title: widget.injector.segment.title),
              SizedBox(height: 14),

              DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(15)
                  ),
                child: Center(
                  child: Text('Listening').color(Colors.white),
                ),
              ),

              SizedBox(height: 20),

              /// title
              Visibility(
                visible: currentItem?.title != null,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: SizedBox(
                    width: sw,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${currentItem?.title}'),
                      ).wrapDotBorder(
                        padding: EdgeInsets.zero,
                        color: Colors.black12,
                        alpha: 120,
                        radius: 6,
                        dashPattern: [5, 7]
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              DecoratedBox(
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
                                    onTap: playSound,
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

              SizedBox(height: 20),

              Visibility(
                visible: description != null,
                  child: Text('$description')
              ),

              examComponent,

              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
                    ),
                    onPressed: registerExerciseResult,
                    child: Text('ثبت')
                ),
              )
            ],
          ),
        ),

        Visibility(
          visible: itemList.length > 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                  onPressed: onNextClick,
                  icon: RotatedBox(
                      quarterTurns: 2,
                      child: Image.asset(AppImages.arrowLeftIco, color: nextColor)
                  ),
                  label: Text('next').englishFont().color(nextColor)
              ),

              TextButton.icon(
                  style: TextButton.styleFrom(),
                  onPressed: onPreClick,
                  icon: Text('pre').englishFont().color(preColor),
                  label: Image.asset(AppImages.arrowLeftIco, color: preColor)
              ),
            ],
          ),
        ),
      ],
    );
  }

  void buildExamView() {
    if (currentItem!.quiz.quizType == QuizType.fillInBlank) {
      examComponent = ExamBlankSpaceBuilder(
        key: ValueKey(currentItem?.id),
        content: examContent,
        controllerId: currentItem!.id,
        index: 0,
        showTitle: false,
      );
      description = 'با توجه به صوت جای خالی را پر کنید';
    }
    else if (currentItem!.quiz.quizType == QuizType.recorder) {
      examComponent = ExamSelectWordBuilder(
        key: ValueKey(currentItem?.id),
        content: examContent,
        controllerId: currentItem!.id,
        index: 0,
        showTitle: false,
      );
      description = 'با توجه به صوت کلمه ی مناسب را انتخاب کنید';
    }
    else if (currentItem!.quiz.quizType == QuizType.multipleChoice) {
      examComponent = ExamOptionBuilder(
        key: ValueKey(currentItem?.id),
        builder: examContent,
        controllerId: currentItem!.id,
        index: 0,
        showTitle: false,
      );
      description = 'با توجه به صوت گزینه ی مناسب را انتخاب کنید';
    }
  }

  void playSound() async {
    if(!voiceIsOk){
      AppToast.showToast(context, 'در حال آماده سازی صوت');
      await prepareVoice();
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

  void onNextClick() async {
    if(currentItemIdx < itemList.length-1) {
      currentItemIdx++;
      currentItem = itemList[currentItemIdx];

      await player.stop();
      await prepareVoice();
      playerSliderValue = 0;

      examContent.prepareExamList([currentItem!.quiz]);
      buildExamView();

      assistCtr.updateHead();
    }
  }

  void onPreClick() async {
    if(currentItemIdx > -1){
      currentItemIdx--;
      currentItem = itemList[currentItemIdx];

      await player.stop();
      await prepareVoice();
      playerSliderValue = 0;

      examContent.prepareExamList([currentItem!.quiz]);
      buildExamView();

      assistCtr.updateHead();
    }
  }

  bool isPlaying() {
    return player.playing && player.position.inMilliseconds < totalTime.inMilliseconds;
  }

  void durationListener(Duration dur) {
    currentTime = dur;

    if(totalTime.inMilliseconds > 100 && dur.inMilliseconds > 100) {
      playerSliderValue = dur.inSeconds * 100 / totalTime.inSeconds;
    }

    assistCtr.updateAssist(id$playViewId);
  }

  void eventListener(PlaybackEvent event){
    assistCtr.updateAssist(id$playViewId);
  }

  Future<void> prepareVoice() async {
    voiceIsOk = false;

    if(currentItem?.voice?.fileLocation == null){
      return;
    }

    return player.setUrl(currentItem?.voice?.fileLocation?? '').then((dur) {
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

  void onTryAgain(){
    voiceIsOk = false;
    assistCtr.clearStates();
    assistCtr.addStateAndUpdateHead(AssistController.state$loading);
    requestListening();
  }

  void requestListening(){
    requester.httpRequestEvents.onFailState = (req, res) async {
      assistCtr.clearStates();
      assistCtr.addStateAndUpdateHead(AssistController.state$error);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final List? data = res['data'];

      if(data is List){
        for(final m in data){
          final g = ListeningModel.fromMap(m);
          itemList.add(g);
        }
      }

      assistCtr.clearStates();

      if(itemList.isEmpty){
        assistCtr.addStateAndUpdateHead(AssistController.state$noData);
      }
      else {
        currentItem = itemList[0];
        prepareVoice();
        examContent.prepareExamList([currentItem!.quiz]);
        buildExamView();
        assistCtr.updateHead();
      }
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/listening?CategoryId=${widget.injector.categoryId}');
    requester.request(context);
  }

  void registerExerciseResult() {
    examController = ExamController.getControllerFor(currentItem!.id);

    if(examController != null){
      if(!examController!.isAnswerToAll()){
        AppToast.showToast(context, 'لطفا تمرین را انجام دهید ');
        return;
      }

      requestSendAnswer();
    }
  }

  void requestSendAnswer(){
    requester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, res) async {
      AppSnack.showSnack$errorCommunicatingServer(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      examController?.showAnswers(true);

      final message = res['message']?? 'پاسخ شما ثبت شد';
      AppSnack.showInfo(context, message);
    };

    final js = <String, dynamic>{};
    final tempList = [];

    if(currentItem!.quiz.items.length < 2) {
      tempList.add({
        'exerciseId': currentItem!.quiz.getFirst().id,
        'answer': currentItem!.quiz.getFirst().getUserAnswerText(),
        'isCorrect': currentItem!.quiz.getFirst().isUserAnswerCorrect(),
      });
    }
    else {
      for (final itm in currentItem!.quiz.items){
        tempList.add({
          'exerciseId': itm.id,
          'answer': itm.getUserAnswerText(),
          'isCorrect': itm.isUserAnswerCorrect(),
        });
      }
    }

    js['items'] = tempList;

    requester.methodType = MethodType.post;
    requester.prepareUrl(pathUrl: '/listening/exercises/solving');
    requester.bodyJson = js;

    showLoading();
    requester.request(context);
  }
}

