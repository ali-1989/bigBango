import 'dart:async';

import 'package:flutter/material.dart';

import 'package:iris_tools/api/callAction/taskQueueCaller.dart';
import 'package:iris_tools/api/duration/durationFormatter.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';
import 'package:iris_tools/widgets/maxHeight.dart';
import 'package:just_audio/just_audio.dart';

import 'package:app/managers/api_manager.dart';
import 'package:app/services/review_service.dart';
import 'package:app/services/vocab_clickable_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/injectors/examPageInjector.dart';
import 'package:app/structures/injectors/readingPagesInjector.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/structures/models/readingModel.dart';
import 'package:app/structures/models/vocabModels/clickableVocabModel.dart';
import 'package:app/structures/models/vocabModels/idiomModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/components/appbarLesson.dart';
import 'package:app/views/components/backBtn.dart';
import 'package:app/views/components/idiomClickableComponent.dart';
import 'package:app/views/components/vocabClickableComponent.dart';
import 'package:app/views/pages/exam_page.dart';
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
class _ReadingPageState extends StateSuper<ReadingPage> with TickerProviderStateMixin {
  Requester requester = Requester();
  Requester reviewRequester = Requester();
  AudioPlayer player = AudioPlayer();
  Duration totalTime = const Duration();
  Duration currentTime = const Duration();
  Duration lastPos = const Duration();
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
  TextStyle normalStyle = const TextStyle(height: 1.7, color: Colors.black);
  TextStyle readStyle = const TextStyle(height: 1.7, color: Colors.deepOrange);
  TextStyle clickableStyle = const TextStyle(
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
    anim1Ctr.duration = const Duration(milliseconds: 400);
    anim2Ctr.duration = const Duration(milliseconds: 400);
    anim2Ctr.animateTo(30);

    assistCtr.addState(AssistController.state$loading);

    player.playbackEventStream.listen(eventListener);
    player.positionStream.listen(durationListener);

    currentItemIdx = 0;
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
      return ErrorOccur(onTryAgain: onRefresh, backButton: const BackBtn());
    }

    if(assistCtr.hasState(AssistController.state$loading)){
      return const WaitToLoad();
    }

    if(itemList.isEmpty){
      return const EmptyData(backButton: BackBtn());
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
              const SizedBox(height: 10),
              AppbarLesson(title: widget.injector.segment.title),
              const SizedBox(height: 14),

              DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppDecoration.red,
                    borderRadius: BorderRadius.circular(15)
                  ),
                child: Center(
                  child: const Text('Reading').color(Colors.white),
                ),
              ),


              const SizedBox(height: 20),
              Visibility(
                visible: currentItem?.title != null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// title
                    Chip(
                      label: Text('${showTranslate? currentItem?.titleTranslation: currentItem?.title}',
                          style:const TextStyle(color: Colors.black)
                      ),
                      backgroundColor: Colors.grey.shade400,
                      elevation: 0,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
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
                        child: const Icon(AppIcons.translate, color: Colors.red, size: 20)
                    )
                  ],
                ),
              ),

              /// content
              const SizedBox(height: 10),
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

              const SizedBox(height: 20),

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
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical:4),
                                            child: Column(
                                              children: [
                                                Text(DurationFormatter.duration(currentTime, showSuffix: false), style: const TextStyle(fontSize: 10, color: Colors.white)),
                                                Text(DurationFormatter.duration(totalTime, showSuffix: false), style: const TextStyle(fontSize: 10, color: Colors.white)),
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
                                    const SizedBox(width: 14),

                                    GestureDetector(
                                      onTap: onPreSegmentClick,
                                      child: const CustomCard(
                                          color: Colors.white,
                                          radius: 25,
                                          padding: EdgeInsets.all(5),
                                          child: RotatedBox(
                                              quarterTurns: 2,
                                              child: Icon(AppIcons.playArrow, size: 15)
                                          )
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    GestureDetector(
                                      onTap: playSound,
                                      child: CustomCard(
                                          color: Colors.white,
                                          radius: 25,
                                          padding: const EdgeInsets.all(5),
                                          child: isPlaying() ?
                                          const Icon(AppIcons.pause, size: 35)
                                              : const Icon(AppIcons.playArrow, size: 35)
                                      ),
                                    ),

                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: onNextSegmentClick,
                                      child: const CustomCard(
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
                                      padding: const EdgeInsets.all(2),
                                      child: Text(
                                          '${currentSegmentIdx+1}/${currentItem?.segments.length}',
                                          style: const TextStyle(fontSize: 11, color: Colors.white)
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
              const SizedBox(height: 20,),
              const Divider(indent: 20, endIndent: 20, color: Colors.grey),

              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  const Text('تمرینها', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('بعد از خواندن متن ، شروع به تمرین کنید و خودتون را محک بزنید',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600)
                  ),

                  const SizedBox(height: 10),

                  MaxHeight(
                      maxHeight: 120,
                      child: AspectRatio(
                          aspectRatio: 2/1,
                          child: Image.asset(AppImages.examManMen)
                      )
                  ),

                  const SizedBox(height: 14),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                        onPressed: onStartExamsClick,
                        child: Text('شروع')
                    ),
                  ),

                  const SizedBox(height: 8),

                  ///...buildExerciseList()
                ],
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
                  label: const Text('next').englishFont().color(nextColor)
              ),

              TextButton.icon(
                  style: TextButton.styleFrom(),
                  onPressed: onPreClick,
                  icon: const Text('prev').englishFont().color(preColor),
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
        await player.seek(const Duration());
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
    lastPos = const Duration();

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

  void onStartExerciseClick(ExamModel model) async {
    showLoading();
    await requestExercise(model);
    await hideLoading();

    if(examList.isNotEmpty){
      gotoExamPage();
    }
    else {
      AppToast.showToast(context, 'تمرینی ثبت نشده است');
    }
  }

  void gotoExamPage() async {
    final examPageInjector = ExamPageInjector();
    examPageInjector.prepareExamList(examList);
    examPageInjector.answerUrl = '/reading/exercises/solving';
    examPageInjector.showSendButton = true;
    examPageInjector.askConfirmToSend = false;

    final examPage = ExamPage(injector: examPageInjector);
    await RouteTools.pushPage(context, examPage);
    requestReading();
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
    requester.prepareUrl(pathUrl: '/reading?CategoryId=${widget.injector.categoryId}');
    requester.request(context);
  }

  void requestSetReview(String id, int progress) async {
    reviewRequester.httpRequestEvents.onFailState = (req, res) async {
    };

    reviewRequester.httpRequestEvents.onStatusOk = (req, res) async {
      ReviewService.requestUpdateLesson(widget.injector.lessonModel);
    };

    final js = <String, dynamic>{};
    js['readingId'] = id;
    js['percentage'] = progress;

    reviewRequester.bodyJson = js;
    reviewRequester.methodType = MethodType.post;
    reviewRequester.prepareUrl(pathUrl: '/reading/review');
    reviewRequester.request();
  }

  Future<void> requestExercise(ExamModel model) async {
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
    requester.prepareUrl(pathUrl: '/reading/exercises?ReadingExerciseCategoryId=${model.id}');
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
        AppSnack.showSnackText(context, AppMessages.operationFailed);
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
        AppSnack.showSnackText(context, AppMessages.operationFailed);
      }
    }
  }

  void onStartExamsClick() {
    if(currentItem!.exerciseList.isEmpty){
      AppToast.showToast(context, 'تمرینی ثبت نشذه است');
      return;
    }

    final inject = ExamPageInjector();
    inject.prepareExamList(currentItem!.exerciseList);
    inject.answerUrl = '/reading/exercises/solving';
    inject.askConfirmToSend = false;

    final p = ExamPage(injector: inject);

    RouteTools.pushPage(context, p);
  }
}


/*
List<Widget> buildExerciseList(){
    final res = <Widget>[];

    for(int i = 0; i < currentItem!.exerciseList.length; i++){
      final itm = currentItem!.exerciseList[i];

      final w = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          onStartExerciseClick(itm);
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(
                  height: 22,
                  child: VerticalDivider(color: AppDecoration.red, width: 3, thickness: 3)
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 10),

                              CustomCard(
                                  color: Colors.grey.shade200,
                                  radius: 3,
                                  padding: const EdgeInsets.symmetric(horizontal:10 , vertical: 3),
                                  child: Text('${i+1}')
                              ),

                              const SizedBox(width: 10),
                              Text(itm.title).fsR(-2),
                            ],
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Row(
                              children: [
                                Text('${itm.count * itm.progress ~/100} / ${itm.count}', textDirection: TextDirection.ltr,)
                                    .alpha().fsR(-2),
                              ],
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 12),

                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.greenAccent.withAlpha(40),
                            color: Colors.greenAccent,
                            value: itm.progress / 100,
                            minHeight: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );

      res.add(w);
    }

    return res;
  }
 */
