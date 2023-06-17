import 'dart:async';

import 'package:app/managers/api_manager.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/callAction/taskQueueCaller.dart';
import 'package:iris_tools/api/duration/durationFormatter.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';
import 'package:iris_tools/widgets/maxHeight.dart';
import 'package:just_audio/just_audio.dart';

import 'package:app/pages/exam_page.dart';
import 'package:app/services/review_service.dart';
import 'package:app/services/vocab_clickable_service.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/builders/examBuilderContent.dart';
import 'package:app/structures/injectors/readingPagesInjector.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/structures/models/readingModel.dart';
import 'package:app/structures/models/vocabModels/clickableVocabModel.dart';
import 'package:app/structures/models/vocabModels/idiomModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/components/appbarLesson.dart';
import 'package:app/views/components/idiomClickableComponent.dart';
import 'package:app/views/components/vocabClickableComponent.dart';
import 'package:app/views/states/backBtn.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';

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
class _ReadingPageState extends StateBase<ReadingPage> with TickerProviderStateMixin {
  Requester requester = Requester();
  Requester reviewRequester = Requester();
  AudioPlayer player = AudioPlayer();
  Duration totalTime = Duration();
  Duration currentTime = Duration();
  Duration lastPos = Duration();
  List<ExamModel> examList = [];
  int currentItemIdx = 0;
  int currentSegmentIdx = 0;
  bool showTranslate = false;
  bool voiceIsOk = false;
  bool isInPlaying = false;
  late AnimationController anim1Ctr;
  late AnimationController anim2Ctr;
  List<ReadingModel> itemList = [];
  ReadingModel? currentItem;
  String id$playerViewId = 'playerViewId';
  TextStyle normalStyle = TextStyle(height: 1.7, color: Colors.black);
  TextStyle readStyle = TextStyle(height: 1.7, color: Colors.deepOrange);
  TextStyle clickableStyle = TextStyle(
    height: 1.7,
    color: Colors.blue,
    decorationStyle: TextDecorationStyle.solid,
    //decoration: TextDecoration.underline
  );
  TaskQueueCaller<Set<String>, dynamic> reviewTaskQue = TaskQueueCaller();
  Timer? reviewSendTimer;

  @override
  void initState(){
    super.initState();

    anim1Ctr = AnimationController(vsync: this, lowerBound: 0, upperBound: 30.0);
    anim2Ctr = AnimationController(vsync: this, lowerBound: 0, upperBound: 30.0);
    anim1Ctr.duration = Duration(milliseconds: 400);
    anim2Ctr.duration = Duration(milliseconds: 400);
    anim2Ctr.animateTo(30);

    assistCtr.addState(AssistController.state$loading);

    player.playbackEventStream.listen(eventListener);
    player.positionStream.listen(durationListener);

    currentItemIdx = widget.injector.index?? 0;
    requestReading();
  }

  @override
  void dispose(){
    reviewSendTimer?.cancel();
    reviewTaskQue.dispose();
    requester.dispose();
    reviewRequester.dispose();

    try {
      player.dispose();
    }
    catch (e){/**/}

    ApiManager.requestGetLessonProgress(widget.injector.lessonModel);
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
      return ErrorOccur(onTryAgain: onRefresh, backButton: BackBtn());
    }

    if(assistCtr.hasState(AssistController.state$loading)){
      return WaitToLoad();
    }

    if(itemList.isEmpty){
      return EmptyData(backButton: BackBtn());
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
                    color: AppDecoration.red,
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
                    /// title
                    Chip(
                      label: Text('${showTranslate? currentItem?.titleTranslation: currentItem?.title}',
                          style:TextStyle(color: Colors.black)
                      ),
                      backgroundColor: Colors.grey.shade400,
                      elevation: 0,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      labelPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                    ),

                    /// translate button
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: (){
                        showTranslate = !showTranslate;

                        if(anim1Ctr.isCompleted){
                          anim1Ctr.reverse();
                        }
                        else {
                          anim1Ctr.forward();
                        }

                        if(anim2Ctr.isCompleted){
                          anim2Ctr.reverse();
                        }
                        else {
                          anim2Ctr.forward();
                        }

                        assistCtr.updateHead();
                      },
                        child: Icon(AppIcons.translate, color: Colors.red, size: 20)
                    )
                  ],
                ),
              ),

              /// content
              SizedBox(height: 10),
              SizedBox(
                width: sw,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6)
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: sw,
                        child: Stack(
                          textDirection: showTranslate? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            AnimatedBuilder(
                              animation: anim1Ctr,
                              builder: (_, c){
                                return Transform.translate(
                                  offset: Offset(0, anim1Ctr.value),
                                  child: Opacity(
                                    opacity: (anim1Ctr.value/30 -1).abs(),
                                    child: RichText(
                                      textAlign: TextAlign.justify,
                                      key: ValueKey(Generator.generateKey(4)),
                                      textDirection: showTranslate? TextDirection.rtl : TextDirection.ltr,
                                      text: TextSpan(
                                          children: currentItem!.genSpans(
                                              currentItem!.segments[currentSegmentIdx].id,
                                              normalStyle,
                                              readStyle,
                                              clickableStyle,
                                              onVocabClick
                                          )
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            IgnorePointer(
                                ignoring: true,
                                child: AnimatedBuilder(
                                  animation: anim2Ctr,
                                  builder: (_, c){
                                    return Transform.translate(
                                      offset: Offset(0, anim2Ctr.value),
                                      child: Opacity(
                                        opacity: (anim2Ctr.value/30 -1).abs(),
                                        child: RichText(
                                          key: ValueKey(Generator.generateKey(4)),
                                          text: TextSpan(
                                              children: currentItem!.genTranslateSpans(
                                                  currentItem!.segments[currentSegmentIdx].id,
                                                  normalStyle,
                                                  readStyle
                                              )
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                            ),
                          ],
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

              /// buttons
              DecoratedBox(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IntrinsicHeight(
                      child: Assist(
                          controller: assistCtr,
                          id: id$playerViewId,
                          builder: (_, ctr, data) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                  child: Center(
                                    child: Column(
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
                                        )
                                      ],
                                    ),
                                  )
                              ),

                              Expanded(
                                flex: 3,
                                child: Row(
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
                                ),
                              ),

                              /// progress
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: CustomCard(
                                      color: Colors.deepOrange,
                                      radius: 4,
                                      padding: EdgeInsets.all(2),
                                      child: Text(
                                          '${currentSegmentIdx+1}/${currentItem?.segments.length}',
                                          style: TextStyle(fontSize: 11, color: Colors.white)
                                      )
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      ),
                    ),
                  )
              ),

              /// exam
              SizedBox(height: 20,),
              Stack(
                children: [
                  MaxHeight(
                      maxHeight: 150,
                      child: AspectRatio(
                          aspectRatio: 2/1,
                          child: Image.asset(AppImages.examManMen)
                      )
                  ),

                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: startExercise,
                        child: Chip(
                            backgroundColor: AppDecoration.red,
                            elevation: 0,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            labelPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                            label: Text('شروع تمرین', style: TextStyle(fontSize: 14))
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 20,),
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

      assistCtr.updateHead();
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

      assistCtr.updateHead();
    }
  }

  void onNextClick() async {
    if(currentItemIdx < itemList.length-1) {
      currentItemIdx++;
      currentItem = itemList[currentItemIdx];

      await player.stop();
      currentSegmentIdx = 0;
      await prepareVoice();

      assistCtr.updateHead();
    }
  }

  void onPreClick() async {
    if(currentItemIdx > -1){
      currentItemIdx--;
      currentItem = itemList[currentItemIdx];

      await player.stop();
      currentSegmentIdx = 0;
      await prepareVoice();

      assistCtr.updateHead();
    }
  }

  bool isPlaying() {
    return player.playing && player.position.inMilliseconds < totalTime.inMilliseconds;
  }

  void durationListener(Duration pos) async {
    currentTime = pos;
    assistCtr.updateAssist(id$playerViewId);
    ///............................
    final dur = player.duration;

    if(dur != null){
      if(pos > Duration(milliseconds: lastPos.inMilliseconds + 5000) || pos == dur){
        lastPos = pos;
        int per = pos.inMilliseconds * 100 ~/ (dur.inMilliseconds - 1000);

        if(per > 100){
          per = 100;
        }

        //requestSetReview(currentItem!.id, MathHelper.percentInt(dur.inMilliseconds, pos.inMilliseconds));
        requestSetReview(currentItem!.id, per);
      }
    }
    ///............................
    if(currentItem == null || currentSegmentIdx >= currentItem!.segments.length){
      return;
    }

    final segment = currentItem!.segments[currentSegmentIdx];

    if(pos > segment.end! && currentSegmentIdx+1 < currentItem!.segments.length){
      currentSegmentIdx++;
      assistCtr.updateHead();
    }
  }

  void eventListener(PlaybackEvent event){
    assistCtr.updateAssist(id$playerViewId);
  }

  Future<void> prepareVoice() async {
    voiceIsOk = false;
    lastPos = Duration();

    if(currentItem?.media?.fileLocation == null){
      return;
    }

    return player.setUrl(currentItem?.media?.fileLocation?? '').then((dur) {
      voiceIsOk = true;

      if(dur != null){
        totalTime = dur;
        assistCtr.updateAssist(id$playerViewId);
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
    assistCtr.addStateAndUpdateHead(AssistController.state$loading);
    requestReading();
  }

  void startExercise() async {
    if(examList.isEmpty){
      showLoading();
      await requestExercise();
      await hideLoading();
    }

    if(examList.isNotEmpty){
      gotoExamPage();
    }
    else {
      AppToast.showToast(context, 'تمرینی ثبت نشده است');
    }
  }

  void gotoExamPage() async {
    final content = ExamBuilderContent();
    content.prepareExamList(examList);
    content.answerUrl = '/reading/exercises/solving';

    final examPage = ExamPage(builder: content);
    await RouteTools.pushPage(context, examPage);
  }

  void requestReading(){
    requester.httpRequestEvents.onFailState = (req, res) async {
      assistCtr.clearStates();
      assistCtr.addStateAndUpdateHead(AssistController.state$error);
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
        assistCtr.addStateAndUpdateHead(AssistController.state$noData);
      }
      else {
        currentItem = itemList[currentItemIdx];
        prepareVoice();
        assistCtr.updateHead();
      }
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/reading?LessonId=${widget.injector.lessonModel.id}');
    requester.request(context);
  }

  void requestSetReview(String id, int progress) async {
    reviewRequester.httpRequestEvents.onFailState = (req, res) async {
    };

    reviewRequester.httpRequestEvents.onStatusOk = (req, res) async {
      ReviewService.requestUpdateReviews(widget.injector.lessonModel);
    };

    final js = <String, dynamic>{};
    js['readingId'] = id;
    js['percentage'] = progress;

    reviewRequester.bodyJson = js;
    reviewRequester.methodType = MethodType.post;
    reviewRequester.prepareUrl(pathUrl: '/reading/review');
    reviewRequester.request();
  }

  Future<void> requestExercise() async {
    Completer c = Completer();
    examList.clear();

    requester.httpRequestEvents.onFailState = (req, res) async {
      c.complete(null);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final List? data = res['data'];

      try{
        if(data is List){
          for(final m in data){
            final g = ExamModel.fromMap(m);
            examList.add(g);
          }
        }
      }
      catch (e){/**/}

      c.complete();
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/reading/exercises?ReadingId=${currentItem!.id}');
    requester.request(context);

    return c.future;
  }

  void onVocabClick(ReadingTextSplitHolder i) async {
    if(i.vocab != null){
      showLoading();
      final data = await VocabClickableService.requestVocab(i.vocab!.id);
      await hideLoading();

      if(data != null) {
        final v = ClickableVocabModel.fromMap(data);

        AppSheet.showSheetCustom(
            context,
          builder: (ctx){
              return VocabClickableComponent(clickableVocabModel: v);
          },
          routeName: 'ClickableVocab',
          isScrollControlled: true,
          contentColor: Colors.transparent,
        );
      }
      else {
        AppSnack.showSnack$OperationFailed(context);
      }
    }
    else {
      showLoading();
      final data = await VocabClickableService.requestIdioms(i.idiom!.id);
      await hideLoading();

      if(data != null) {
        final i = IdiomModel.fromMap(data);

        AppSheet.showSheetCustom(
          context,
          builder: (ctx){
            return IdiomClickableComponent(idiomModel: i);
          },
          routeName: 'ClickableIdiom',
          isScrollControlled: true,
          contentColor: Colors.transparent,
        );
      }
      else {
        AppSnack.showSnack$OperationFailed(context);
      }
    }
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
