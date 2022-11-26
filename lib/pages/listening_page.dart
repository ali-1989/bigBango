import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/injectors/examInjector.dart';
import 'package:app/models/lessonModels/lessonModel.dart';
import 'package:app/models/lessonModels/listeningSegmentModel.dart';
import 'package:app/models/listeningModel.dart';
import 'package:app/system/enums.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/views/components/appbarLesson.dart';
import 'package:app/views/components/examBlankSpaseComponent.dart';
import 'package:app/views/components/examOptionComponent.dart';
import 'package:app/views/components/examSelectWordComponent.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:app/views/widgets/customCard.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:just_audio/just_audio.dart';
import 'package:iris_tools/api/duration/durationFormater.dart';

class ListeningPageInjector {
  late LessonModel lessonModel;
  late ListeningSegmentModel segment;
}
///-----------------------------------------------------
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
  int currentItemIdx = 0;
  bool voiceIsOk = false;
  bool isInPlaying = false;
  List<ListeningModel> itemList = [];
  ListeningModel? currentItem;
  AudioPlayer player = AudioPlayer();
  Duration totalTime = Duration();
  Duration currentTime = Duration();
  String timerViewId = 'timerViewId';
  String playIconViewId = 'playIconViewId';

  @override
  void initState(){
    super.initState();

    assistCtr.addState(AssistController.state$loading);

    player.playbackEventStream.listen(eventListener);
    player.positionStream.listen(durationListener);

    requestListening();
  }

  @override
  void dispose(){
    requester.dispose();
    player.stop();

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
      return ErrorOccur(onRefresh: onRefresh);
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

              Directionality(
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
                      child: Text('777'),
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

              SizedBox(height: 20),

              DecoratedBox(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Assist(
                                      controller: assistCtr,
                                      id: timerViewId,
                                      builder: (_, ctr, data) {
                                        return CustomCard(
                                            color: Colors.pinkAccent,
                                            radius: 4,
                                            padding: EdgeInsets.symmetric(horizontal: 14, vertical:4),
                                            child: Column(
                                              children: [
                                                Text(DurationFormatter.duration(currentTime, showSuffix: false), style: TextStyle(fontSize: 10, color: Colors.white)),
                                                Text(DurationFormatter.duration(totalTime, showSuffix: false), style: TextStyle(fontSize: 10, color: Colors.white)),
                                              ],
                                            )
                                        );
                                      }
                                    ),
                                  ],
                                ),
                              )
                          ),

                          Expanded(
                            flex: 3,
                            child: Assist(
                              controller: assistCtr,
                              id: playIconViewId,
                              builder: (_, ctr, data) {
                                return Row(
                                  textDirection: TextDirection.ltr,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 14),

                                    SizedBox(width: 10),

                                    GestureDetector(
                                      onTap: playSound,
                                      child: CustomCard(
                                          color: Colors.white,
                                          radius: 25,
                                          padding: EdgeInsets.all(5),
                                          child: isPlaying() ?
                                            Icon(AppIcons.pause, size: 35)
                                          : Icon(AppIcons.playArrow, size: 35)
                                      ),
                                    ),

                                    SizedBox(width: 10),
                                  ],
                                );
                              }
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
              ),

              SizedBox(height: 20),

              Text('با توجه به فایل صوتی به سوالات جواب دهید. '),

              buildExamView()
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

  Widget buildExamView(){
    ExamInjector examComponentInjector = ExamInjector();
    examComponentInjector.lessonModel = widget.injector.lessonModel;
    examComponentInjector.segment = widget.injector.lessonModel.grammarModel!;

    Widget component = SizedBox();
    String desc = '';
print('==========${currentItem!.quiz.choices.length}');
    if(currentItem!.quiz.quizType == QuizType.fillInBlank){
      component = ExamBlankSpaceComponent(injector: examComponentInjector);
      desc = 'جای خالی را پر کنید';
    }
    else if(currentItem!.quiz.quizType == QuizType.recorder){
      component = ExamSelectWordComponent(injector: examComponentInjector);
      desc = 'کلمه ی مناسب را انتخاب کنید';
    }
    else if(currentItem!.quiz.quizType == QuizType.multipleChoice){
      component = ExamOptionComponent(injector: examComponentInjector);
      desc = 'گزینه ی مناسب را انتخاب کنید';
    }

    return component;
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

      assistCtr.updateMain();
    }
  }

  void onPreClick() async {
    if(currentItemIdx > -1){
      currentItemIdx--;
      currentItem = itemList[currentItemIdx];

      await player.stop();
      await prepareVoice();

      assistCtr.updateMain();
    }
  }

  bool isPlaying() {
    return player.playing && player.position.inMilliseconds < totalTime.inMilliseconds;
  }

  void durationListener(Duration dur) {
    currentTime = dur;
    assistCtr.update(timerViewId);
  }

  void eventListener(PlaybackEvent event){
    assistCtr.update(playIconViewId);
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

  void onRefresh(){
    voiceIsOk = false;
    assistCtr.clearStates();
    assistCtr.addStateAndUpdate(AssistController.state$loading);
    requestListening();
  }

  void requestListening(){
    requester.httpRequestEvents.onFailState = (req, res) async {
      assistCtr.clearStates();
      assistCtr.addStateAndUpdate(AssistController.state$error);
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
        assistCtr.addStateAndUpdate(AssistController.state$emptyData);
      }
      else {
        currentItem = itemList[0];
        prepareVoice();
        assistCtr.updateMain();
      }
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/listening?LessonId=${widget.injector.lessonModel.id}');
    requester.request(context);
  }
}

