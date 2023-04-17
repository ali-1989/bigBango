import 'dart:async';

import 'package:flutter/material.dart';

import 'package:chewie/chewie.dart';
import 'package:iris_tools/api/callAction/taskQueueCaller.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/attribute.dart';
import 'package:video_player/video_player.dart';

import 'package:app/services/review_service.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/injectors/vocabPagesInjector.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/vocabModels/idiomModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/views/components/appbarLesson.dart';
import 'package:app/views/components/greetingView.dart';
import 'package:app/views/states/backBtn.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:iris_tools/widgets/customCard.dart';

class IdiomsPage extends StatefulWidget {
  final VocabIdiomsPageInjector injector;

  const IdiomsPage({
    required this.injector,
    Key? key
  }) : super(key: key);

  @override
  State<IdiomsPage> createState() => _IdiomsPageState();
}
///======================================================================================================================
class _IdiomsPageState extends StateBase<IdiomsPage> {
  Requester requester = Requester();
  bool showTranslate = false;
  bool isVideoInit = false;
  bool isVideoError = false;
  bool showGreeting = false;
  bool regulatorIsCall = false;
  List<IdiomModel> idiomsList = [];
  int currentIdiomIdx = 0;
  late IdiomModel currentIdiom;
  VideoPlayerController? playerController;
  ChewieController? chewieVideoController;
  AttributeController atrCtr1 = AttributeController();
  AttributeController atrCtr2 = AttributeController();
  double regulator = 200;
  TaskQueueCaller<Set<String>, dynamic> reviewTaskQue = TaskQueueCaller();
  Timer? reviewSendTimer;
  Set<String> reviewIds = {};

  @override
  void initState(){
    super.initState();

    currentIdiomIdx = widget.injector.lessonModel.vocabSegmentModel?.idiomReviewCount?? 0;

    if(currentIdiomIdx > 0){
      currentIdiomIdx--;
    }

    reviewTaskQue.setFn((Set<String> lis, value){
      requestSetReview(lis);
    });

    if(widget.injector.idiomModel != null) {
      idiomsList.add(widget.injector.idiomModel!);
      currentIdiom = widget.injector.idiomModel!;

      initVideo();
    }
    else {
      assistCtr.addState(AssistController.state$loading);
      requestIdioms();
    }
  }

  @override
  void dispose(){
    reviewSendTimer?.cancel();
    reviewTaskQue.dispose();
    requester.dispose();
    chewieVideoController?.dispose();
    playerController?.dispose();

    if(reviewIds.isNotEmpty){
      ReviewService.addReviews(ReviewSection.idioms, reviewIds);
    }

    PublicAccess.requestGetLessonProgress(widget.injector.lessonModel);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
        builder: (ctx, ctr, data){
          return Scaffold(
            //appBar: buildAppbar(),
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

    if(currentIdiomIdx == 0 && !showGreeting){
      preColor = Colors.grey;
    }

    if(currentIdiomIdx >= idiomsList.length || showGreeting){
      nextColor = Colors.grey;
    }

    return Column(
      children: [
        Expanded(
          child: Attribute(
            controller: atrCtr1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Attribute(
                  controller: atrCtr2,
                  child: Column(
                    children: [
                      SizedBox(height: 20),

                      AppbarLesson(title: widget.injector.lessonModel.title),

                      SizedBox(height: 14),

                      /// 7/20
                      Visibility(
                        visible: idiomsList.length > 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Chip(
                                  label: Text('اصطلاحات').bold().color(Colors.white),//widget.injection.segment.title
                                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                                  visualDensity: VisualDensity.compact,
                                ),

                                SizedBox(width: 10),
                              ],
                            ),

                            Row(
                              children: [
                                Text('${idiomsList.length}').englishFont().fsR(4),

                                SizedBox(width: 10),
                                Text('/').englishFont().fsR(5),

                                SizedBox(width: 10),
                                CustomCard(
                                  color: Colors.grey.shade200,
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    child: Text('${currentIdiomIdx+1}').englishFont().bold().fsR(4)
                                )
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 14),

                      /// progressbar
                      Visibility(
                        visible: idiomsList.length > 1,
                        child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: LinearProgressIndicator(
                                value: calcProgress(),
                                backgroundColor: AppColors.red.withAlpha(50)
                            )
                        ),
                      ),

                      SizedBox(height: 14),

                     Builder(
                         builder: (ctx){
                           if(showGreeting){
                             addPostOrCall(subContext: ctx, fn: () {
                               final dif = atrCtr1.getHeight()! - atrCtr2.getHeight()!;

                               if(dif > 0 && !regulatorIsCall) {
                                 regulatorIsCall = true;
                                 regulator += dif;
                                 assistCtr.updateHead();
                               }});

                             return SizedBox(
                                 height: regulator,
                                 child: FittedBox(
                                     child: Column(
                                       mainAxisSize: MainAxisSize.min,
                                       children: [
                                         buildGreetingView(),
                                         SizedBox(height: 20),

                                         Row(
                                           children: [
                                             ElevatedButton.icon(
                                                 onPressed: gotoNextPart,
                                                 label: Image.asset(AppImages.arrowRight2),
                                                 icon: Text('بخش بعدی')
                                             ),

                                             SizedBox(width: 30),
                                             OutlinedButton.icon(
                                                 style: OutlinedButton.styleFrom(
                                                     side: BorderSide(color: AppColors.red)
                                                 ),
                                                 onPressed: resetVocab,
                                                 label: Image.asset(AppImages.returnArrow),
                                                 icon: Text('شروع مجدد')
                                             ),
                                           ],
                                         )
                                       ],
                                     )
                                 )
                             );
                           }
                           else {
                             return Column(
                               children: [
                                 SizedBox(
                                   height: 200,
                                   child: Builder(
                                     builder: (_){
                                       if(currentIdiom.video?.fileLocation != null){
                                         if(isVideoInit){
                                           return Chewie(controller: chewieVideoController!);
                                         }
                                         else if(isVideoError){
                                           return Column(
                                             children: [
                                               Image.asset(AppImages.falseCheckIco, width: 100, height: 100,),
                                               SizedBox(height: 20),
                                               Text('متاسفانه فایل قابل پخش نیست'),
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
                                     },
                                   ),
                                 ),

                                 SizedBox(height: 14),
                                 DecoratedBox(
                                   decoration: BoxDecoration(
                                       borderRadius: BorderRadius.circular(20),
                                       border: Border.all(color: Colors.black, width: 1, style: BorderStyle.solid)
                                   ),
                                   child: Padding(
                                     padding: const EdgeInsets.all(12.0),
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         Row(
                                           mainAxisAlignment: MainAxisAlignment.start,
                                           textDirection: TextDirection.ltr,
                                           children: [
                                             Flexible(
                                                 child: Text(currentIdiom.content, textDirection: TextDirection.ltr).englishFont()
                                                     .bold(weight: FontWeight.w400).fsR(4)),
                                           ],
                                         ),

                                         AnimatedCrossFade(
                                             firstChild: InputChip(
                                               onPressed: (){
                                                 showTranslate = !showTranslate;
                                                 assistCtr.updateHead();
                                               },
                                               label: Text('مشاهده ترجمه'),
                                             ),
                                             secondChild: Padding(
                                               padding: const EdgeInsets.symmetric(vertical: 8.0),
                                               child: Text(currentIdiom.translation),
                                             ),
                                             crossFadeState: showTranslate? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                             duration: Duration(milliseconds: 300)
                                         ),

                                         SizedBox(height: 10),
                                       ],
                                     ),
                                   ),
                                 ),
                               ],
                             );
                           }
                         }
                     ),

                      SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        Row(
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
      ],
    );
  }

  Widget buildGreetingView(){
    return GreetingView();
  }

  void gotoNextPart(){
    final page = PublicAccess.getNextPartOfLesson(widget.injector.lessonModel);

    if(page != null) {
      RouteTools.pushReplacePage(context, page);
    }
  }

  void resetVocab(){
    showGreeting = false;
    currentIdiomIdx = 0;
    isVideoInit = false;

    currentIdiom = idiomsList[currentIdiomIdx];
    showTranslate = currentIdiom.showTranslation;
    assistCtr.updateHead();
    initVideo();
  }

  double calcProgress(){
    int r = ((currentIdiomIdx+1) * 100) ~/ idiomsList.length;
    return r/100;
  }

  void onNextClick(){
    chewieVideoController?.pause();

    if(currentIdiomIdx < idiomsList.length-1) {
      currentIdiomIdx++;

      currentIdiom = idiomsList[currentIdiomIdx];
      showTranslate = currentIdiom.showTranslation;

      if(!widget.injector.lessonModel.vocabSegmentModel!.reviewIds.contains(currentIdiom.id)) {
        sendReview(currentIdiom.id);
      }
    }
    else {
      showGreeting = true;
    }

    assistCtr.updateHead();
    isVideoInit = false;
    initVideo();
  }

  void onPreClick(){
    if(showGreeting){
      showGreeting = false;
    }
    else {
      chewieVideoController?.pause();
      currentIdiomIdx--;

      currentIdiom = idiomsList[currentIdiomIdx];
      showTranslate = currentIdiom.showTranslation;
    }

    assistCtr.updateHead();
    isVideoInit = false;
    initVideo();
  }

  void initVideo() async {
    if(isVideoInit || currentIdiom.video?.fileLocation == null){
      return;
    }

    isVideoInit = false;
    playerController = VideoPlayerController.network(currentIdiom.video!.fileLocation!);

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
    );

    assistCtr.updateHead();
  }

  void onRefresh(){
    assistCtr.clearStates();
    assistCtr.addStateAndUpdateHead(AssistController.state$loading);
    requestIdioms();
  }

  void requestIdioms(){
    requester.httpRequestEvents.onFailState = (req, res) async {
      assistCtr.clearStates();
      assistCtr.addStateAndUpdateHead(AssistController.state$error);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final List? data = res['data'];
      assistCtr.clearStates();

      if(data is List){
        for(final k in data){
          final vo = IdiomModel.fromMap(k);

          idiomsList.add(vo);
        }
      }
      else {
        assistCtr.addStateAndUpdateHead(AssistController.state$error);
        return;
      }

      if(idiomsList.isEmpty){
        assistCtr.addStateAndUpdateHead(AssistController.state$noData);
      }
      else {
        currentIdiom = idiomsList[currentIdiomIdx];
        showTranslate = currentIdiom.showTranslation;

        assistCtr.updateHead();
        initVideo();

        if(!widget.injector.lessonModel.vocabSegmentModel!.reviewIds.contains(currentIdiom.id)) {
          sendReview(currentIdiom.id);
        }
      }
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/idioms?LessonId=${widget.injector.lessonModel.id}');
    requester.request(context);
  }

  void sendReview(String id){
    reviewIds.add(id);

    if(reviewSendTimer == null || !reviewSendTimer!.isActive){
      reviewSendTimer = Timer(Duration(seconds: 5), (){
        reviewTaskQue.addObject({...reviewIds});
      });
    }
  }

  void requestSetReview(Set<String> ids) async {
    final status = await ReviewService.requestSetReview(ReviewSection.idioms, ids.toList());

    if(status){
      reviewIds.removeAll(ids);
      widget.injector.lessonModel.vocabSegmentModel!.reviewIds.addAll(ids);
      widget.injector.lessonModel.vocabSegmentModel!.reviewCount++;

      ReviewService.requestUpdateReviews(widget.injector.lessonModel);
    }

    reviewTaskQue.callNext(null);
  }
}
