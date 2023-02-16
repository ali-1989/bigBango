import 'dart:async';

import 'package:flutter/material.dart';

import 'package:chewie/chewie.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxHeight.dart';
import 'package:video_player/video_player.dart';

import 'package:app/pages/exam_page.dart';
import 'package:app/services/review_service.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/injectors/examPageInjector.dart';
import 'package:app/structures/injectors/grammarPagesInjector.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/structures/models/grammarModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/views/components/appbarLesson.dart';
import 'package:app/views/states/backBtn.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';

class GrammarPage extends StatefulWidget {
  final GrammarPageInjector injector;

  const GrammarPage({
    required this.injector,
    Key? key
  }) : super(key: key);

  @override
  State<GrammarPage> createState() => _GrammarPageState();
}
///===========================================================================================================
class _GrammarPageState extends StateBase<GrammarPage> {
  Requester requester = Requester();
  Requester reviewRequester = Requester();
  List<GrammarModel> itemList = [];
  List<ExamModel> examList = [];
  GrammarModel? currentItem;
  VideoPlayerController? playerController;
  ChewieController? chewieVideoController;
  Duration lastPos = Duration();
  bool isVideoInit = false;
  int currentItemIdx = 0;
  Timer? reviewSendTimer;

  @override
  void initState(){
    super.initState();

    assistCtr.addState(AssistController.state$loading);

    requestGrammars();
  }

  @override
  void dispose(){
    reviewSendTimer?.cancel();
    requester.dispose();
    reviewRequester.dispose();
    chewieVideoController?.dispose();
    playerController?.dispose();

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
    if(assistCtr.hasState(AssistController.state$error)){
      return ErrorOccur(onTryAgain: onRefresh, backButton: BackBtn());
    }

    if(assistCtr.hasState(AssistController.state$loading)){
      return WaitToLoad();
    }

    if(assistCtr.hasState(AssistController.state$noData)){
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
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 10),

                      AppbarLesson(title: widget.injector.lessonModel.title),

                      SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text('${currentItem?.title}', style:TextStyle(color: Colors.black)),
                            backgroundColor: Colors.grey.shade400,
                            elevation: 0,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            labelPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                          ),

                          Chip(
                            label: Text('گرامر'),
                            backgroundColor: AppColors.red,
                            elevation: 0,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            labelPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                     SizedBox(
                       height: 200,
                       child: Builder(
                           builder: (ctx){
                             if(currentItem?.media?.fileLocation != null){
                               if(isVideoInit){
                                 return Chewie(controller: chewieVideoController!);
                               }
                               else {
                                 return const Center(child: CircularProgressIndicator());
                               }
                             }
                             else {
                               return Image.asset(AppImages.noImage);
                             }
                           }
                       ),
                     ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),

              ColoredBox(
                color: Colors.grey.shade200,
                child: Row(
                  children: [
                    SizedBox(width: 16),

                    SizedBox(
                      height: 30,
                      width: 3,
                      child: ColoredBox(
                        color: AppColors.red,
                      ),
                    ),

                    SizedBox(width: 5),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('تمرین', style: TextStyle(fontSize: 14)),
                          SizedBox(height: 4),
                          Text('بعد از نمایش ویدیو ، شروع به تمرین کنید و خودتون را محک بزنید',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
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
                            backgroundColor: AppColors.red,
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

              SizedBox(height: 14),
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

  void onNextClick(){
    if(currentItemIdx < itemList.length-1) {
      chewieVideoController?.pause();
      currentItemIdx++;

      currentItem = itemList[currentItemIdx];
      initVideo();
      assistCtr.updateHead();
    }
  }

  void onPreClick(){
    if(currentItemIdx > -1){
      chewieVideoController?.pause();
      currentItemIdx--;

      currentItem = itemList[currentItemIdx];
      initVideo();
      assistCtr.updateHead();
    }
  }

  void startReviewTimer(){
    if(reviewSendTimer == null || !reviewSendTimer!.isActive){
      reviewSendTimer = Timer.periodic(Duration(seconds: 5), (t) async {
        if(isVideoInit) {
          final dur = chewieVideoController?.videoPlayerController.value.duration;
          final pos = await chewieVideoController?.videoPlayerController.position;

          if(dur == null || pos == null || pos <= lastPos){
            return;
          }

          lastPos = pos;
          int per = pos.inMilliseconds * 100 ~/ (dur.inMilliseconds - 1000);

          if(per > 100){
            per = 100;
          }
          //requestSetReview(currentItem!.id, MathHelper.percentInt(dur.inMilliseconds, pos.inMilliseconds));
          requestSetReview(currentItem!.id, per);
        }
      });
    }
  }

  void startExercise() async{
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

  void initVideo() async {
    isVideoInit = false;
    lastPos = Duration();

    if(currentItem?.media?.fileLocation == null){
      return;
    }

    playerController = VideoPlayerController.network(currentItem!.media!.fileLocation!);

    await playerController!.initialize();
    isVideoInit = playerController!.value.isInitialized;

    if(mounted) {
      if(isVideoInit) {
        onVideoInit();
      }
      else {
        assistCtr.updateHead();
      }
    }
  }

  void onVideoInit(){
    chewieVideoController = ChewieController(
      videoPlayerController: playerController!,
      autoPlay: false,
      allowFullScreen: true,
      allowedScreenSleep: false,
      allowPlaybackSpeedChanging: true,
      allowMuting: true,
      autoInitialize: true,
      fullScreenByDefault: false,
      looping: false,
      isLive: false,
      zoomAndPan: false,
      showControls: true,
      showControlsOnInitialize: true,
      showOptions: true,
      playbackSpeeds: [1, 1.5, 2],
      placeholder: const Center(child: CircularProgressIndicator()),
      materialProgressColors: ChewieProgressColors(
        handleColor: AppThemes.instance.currentTheme.differentColor,
        playedColor: AppThemes.instance.currentTheme.differentColor,
        backgroundColor: Colors.green, bufferedColor: AppThemes.instance.currentTheme.primaryColor,
      ),
    );

    assistCtr.updateHead();
  }

  void gotoExamPage() async {
    final examPageInjector = ExamPageInjector();
    examPageInjector.lessonModel = widget.injector.lessonModel;
    examPageInjector.examList = examList;
    examPageInjector.answerUrl = '/grammars/exercises/solving';

    final examPage = ExamPage(injector: examPageInjector);
    await AppRoute.push(context, examPage);
  }

  void onRefresh(){
    assistCtr.clearStates();
    assistCtr.addStateAndUpdateHead(AssistController.state$loading);
    requestGrammars();
  }

  void requestGrammars(){
    requester.httpRequestEvents.onFailState = (req, res) async {
      assistCtr.clearStates();
      assistCtr.addStateAndUpdateHead(AssistController.state$error);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final List? data = res['data'];
      assistCtr.clearStates();

      if(data is List){
        for(final m in data){
          final g = GrammarModel.fromMap(m);
          itemList.add(g);
        }
      }
      else {
        assistCtr.addStateAndUpdateHead(AssistController.state$error);
        return;
      }

      if(itemList.isEmpty){
        assistCtr.addStateAndUpdateHead(AssistController.state$noData);
      }
      else {
        if(widget.injector.id != null){
          for(final x in itemList){
            if(x.id == widget.injector.id){
              currentItem = x;
              break;
            }
          }
        }
        else {
          currentItem = itemList[currentItemIdx];
        }

        assistCtr.updateHead();
        initVideo();

        startReviewTimer();
      }
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/grammars?LessonId=${widget.injector.lessonModel.id}');
    requester.request(context);
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
    requester.prepareUrl(pathUrl: '/grammars/exercises?GrammarId=${currentItem!.id}');
    requester.request(context);

    return c.future;
  }

  void requestSetReview(String id, int progress) async {
    reviewRequester.httpRequestEvents.onFailState = (req, res) async {
    };

    reviewRequester.httpRequestEvents.onStatusOk = (req, res) async {
      ReviewService.requestUpdateReviews(widget.injector.lessonModel);
    };

    final js = <String, dynamic>{};
    js['grammarId'] = id;
    js['percentage'] = progress;

    reviewRequester.bodyJson = js;
    reviewRequester.methodType = MethodType.post;
    reviewRequester.prepareUrl(pathUrl: '/grammars/review');
    reviewRequester.request();
  }
}
