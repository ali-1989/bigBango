
import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/lessonModels/lessonModel.dart';
import 'package:app/models/lessonModels/readingSegmentModel.dart';
import 'package:app/models/readingModel.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/views/components/appbarLesson.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:app/views/widgets/customCard.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:just_audio/just_audio.dart';
import 'package:iris_tools/api/duration/durationFormater.dart';

class ReadingPageInjector {
  late LessonModel lessonModel;
  late ReadingSegmentModel segment;
}
///-----------------------------------------------------
class ReadingPage extends StatefulWidget {
  final ReadingPageInjector injector;

  const ReadingPage({
    required this.injector,
    Key? key
  }) : super(key: key);

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}
///======================================================================================================================
class _ReadingPageState extends StateBase<ReadingPage> {
  Requester requester = Requester();
  int currentItemIdx = 0;
  int currentSegmentIdx = 0;
  bool showTranslate = false;
  bool voiceIsOk = false;
  bool isInPlaying = false;
  List<ReadingModel> itemList = [];
  ReadingModel? currentItem;
  String timerViewId = 'timerViewId';
  String playIconViewId = 'playIconViewId';
  TextStyle normalStyle = TextStyle(height: 1.7, color: Colors.black);
  TextStyle readStyle = TextStyle(height: 1.7, color: Colors.deepOrange);
  AudioPlayer player = AudioPlayer();
  Duration totalTime = Duration();
  Duration currentTime = Duration();

  @override
  void initState(){
    super.initState();

    assistCtr.addState(AssistController.state$loading);

    player.playbackEventStream.listen(eventListener);
    player.positionStream.listen(durationListener);

    requestReading();
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

    currentItem?.prepareSpans(currentSegmentIdx, normalStyle, readStyle);

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
                  child: Text('Reading').color(Colors.white),
                ),
              ),

              SizedBox(height: 20),

              Visibility(
                visible: currentItem?.title != null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text('${showTranslate? currentItem?.titleTranslation: currentItem?.title}', style:TextStyle(color: Colors.black)),
                      backgroundColor: Colors.grey.shade400,
                      elevation: 0,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      labelPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),

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
                      child: RichText(
                        key: ValueKey(Generator.generateKey(4)),
                        text: TextSpan(
                            children: currentItem?.spans
                        ),
                      ),
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

                                    GestureDetector(
                                      onTap: onPreSegmentClick,
                                      child: CustomCard(
                                          color: Colors.white,
                                          radius: 25,
                                          padding: EdgeInsets.all(5),
                                          child: RotatedBox(
                                              quarterTurns: 2,
                                              child: Icon(AppIcons.playArrow, size: 15)
                                          )
                                      ),
                                    ),

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
                                    GestureDetector(
                                      onTap: onNextSegmentClick,
                                      child: CustomCard(
                                          color: Colors.white,
                                          radius: 25,
                                          padding: EdgeInsets.all(5),
                                          child: Icon(AppIcons.playArrow, size: 15)
                                      ),
                                    ),
                                  ],
                                );
                              }
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: CustomCard(
                                  color: Colors.deepOrange,
                                  radius: 4,
                                  padding: EdgeInsets.all(2),
                                  child: Text('${currentSegmentIdx+1}/${currentItem?.segments.length}', style: TextStyle(fontSize: 11, color: Colors.white))
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
              ),
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

  void onNextSegmentClick() async {
    if(!voiceIsOk){
      AppToast.showToast(context, 'در حال آماده سازی صوت');
      return;
    }

    if(currentSegmentIdx < currentItem!.segments.length-1) {
      currentSegmentIdx++;
      await player.seek(currentItem!.segments[currentSegmentIdx].start);

      assistCtr.updateMain();
    }
  }

  void onPreSegmentClick() async {
    if(!voiceIsOk){
      AppToast.showToast(context, 'در حال آماده سازی صوت');
      return;
    }

    if(currentSegmentIdx > 0) {
      currentSegmentIdx--;
      await player.seek(currentItem!.segments[currentSegmentIdx].start);

      assistCtr.updateMain();
    }
  }

  void onNextClick() async {
    if(currentItemIdx < itemList.length-1) {
      currentItemIdx++;
      currentSegmentIdx = 0;
      currentItem = itemList[currentItemIdx];

      await player.stop();
      await prepareVoice();

      assistCtr.updateMain();
    }
  }

  void onPreClick() async {
    if(currentItemIdx > -1){
      currentSegmentIdx = 0;
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

    if(currentItem == null  || currentSegmentIdx >= currentItem!.segments.length){
      return;
    }

    final segment = currentItem!.segments[currentSegmentIdx];

    if(dur > segment.end!){
      currentSegmentIdx++;
      assistCtr.updateMain();
    }
  }

  void eventListener(PlaybackEvent event){
    assistCtr.update(playIconViewId);
  }

  Future<void> prepareVoice() async {
    voiceIsOk = false;

    if(currentItem?.media?.fileLocation == null){
      return;
    }

    return player.setUrl(currentItem?.media?.fileLocation?? '').then((dur) {
      voiceIsOk = true;

      if(dur != null){
        totalTime = dur;
        assistCtr.update(timerViewId);
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
    requestReading();
  }

  void requestReading(){
    requester.httpRequestEvents.onFailState = (req, res) async {
      assistCtr.clearStates();
      assistCtr.addStateAndUpdate(AssistController.state$error);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final List? data = res['data'];

      if(data is List){
        for(final m in data){
          final g = ReadingModel.fromMap(m);
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
    requester.prepareUrl(pathUrl: '/reading?LessonId=${widget.injector.lessonModel.id}');
    requester.request(context);
  }
}


/*
htmlText = '''
    <body>
    <p>verb (used with object)</p>
    <p><strong>1 ali bagheri is very good:</strong></p>
    <p><span style="color: #ff0000;">&nbsp; &nbsp; she is not good</span></p>
    <p>noun</p>
    <p><strong>2 ali bagheri is very good ali bagheri is very good ali bagheri is very good:</strong></p>
    <p><span style="color: #ff0000;">&nbsp; &nbsp; she is not good</span></p>
    <p><strong>&nbsp;&nbsp;</strong></p>
    </body>
''';


Directionality(
                      textDirection: TextDirection.ltr,
                      child: HTML.toRichText(context, htmlText, defaultTextStyle: AppThemes.body2TextStyle())
                    ),
* */