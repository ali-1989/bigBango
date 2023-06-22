import 'dart:async';

import 'package:app/managers/api_manager.dart';
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
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/structures/models/grammarModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/tools/routeTools.dart';
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
  Duration lastPos = const Duration();
  bool isVideoInit = false;
  bool isVideoError = false;
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

    ApiManager.requestGetLessonProgress(widget.injector.lessonModel);

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
      return ErrorOccur(onTryAgain: onRefresh, backButton: const BackBtn());
    }

    if(assistCtr.hasState(AssistController.state$loading)){
      return const WaitToLoad();
    }

    if(assistCtr.hasState(AssistController.state$noData)){
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
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      AppbarLesson(title: widget.injector.lessonModel.title),

                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text('${currentItem?.title}', style:const TextStyle(color: Colors.black)),
                            backgroundColor: Colors.grey.shade400,
                            elevation: 0,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                          ),

                          const Chip(
                            label: Text('گرامر'),
                            backgroundColor: AppDecoration.red,
                            elevation: 0,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            labelPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                     SizedBox(
                       height: 200,
                       child: Builder(
                           builder: (ctx){
                             if(currentItem?.media?.fileLocation != null){
                               if(isVideoInit){
                                 return Chewie(controller: chewieVideoController!);
                               }
                               else if(isVideoError){
                                 return Column(
                                   children: [
                                     Image.asset(AppImages.falseCheckIco, width: 100, height: 100,),
                                     const SizedBox(height: 20),
                                     const Text('متاسفانه فایل قابل پخش نیست'),
                                   ],
                                 );
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

              const SizedBox(height: 30),

              ColoredBox(
                color: Colors.grey.shade200,
                child: Row(
                  children: [
                    const SizedBox(width: 16),

                    const SizedBox(
                      height: 30,
                      width: 3,
                      child: ColoredBox(
                        color: AppDecoration.red,
                      ),
                    ),

                    const SizedBox(width: 5),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('تمرین', style: TextStyle(fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('بعد از نمایش ویدیو ، شروع به تمرین کنید و خودتون را محک بزنید',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              GestureDetector(
                onTap: onStartExerciseClick,
                behavior: HitTestBehavior.translucent,
                child: Stack(
                  children: [
                    MaxHeight(
                      maxHeight: 150,
                        child: AspectRatio(
                          aspectRatio: 2/1,
                            child: Image.asset(AppImages.examManMen)
                        )
                    ),

                    const Positioned(
                      bottom: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: const Chip(
                            backgroundColor: AppDecoration.red,
                              elevation: 0,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              labelPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                              label: Text('شروع تمرین', style: TextStyle(fontSize: 14))
                          ),
                        ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 14),
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
      reviewSendTimer = Timer.periodic(const Duration(seconds: 5), (t) async {
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

  void onStartExerciseClick() async{
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
    isVideoError = false;
    lastPos = const Duration();

    if(currentItem?.media?.fileLocation == null){
      return;
    }

    playerController = VideoPlayerController.network(currentItem!.media!.fileLocation!);

    await playerController!.initialize().catchError((e){
      isVideoError = true;
    });

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
      errorBuilder: (_, s){
        return const SizedBox(
          child: Center(
              child: Text('Can not load media.')
          ),
        );
      }
    );

    assistCtr.updateHead();
  }

  void gotoExamPage() async {
    final examPageInjector = ExamPageInjector();
    examPageInjector.prepareExamList(examList);
    examPageInjector.answerUrl = '/grammars/exercises/solving';
    examPageInjector.showSendButton = true;

    final examPage = ExamPage(injector: examPageInjector);
    await RouteTools.pushPage(context, examPage);
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
          for(int i=0; i<itemList.length; i++){
            final x = itemList[i];

            if(x.id == widget.injector.id){
              currentItem = x;
              currentItemIdx = i;
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
