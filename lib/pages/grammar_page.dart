import 'dart:async';

import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/examModel.dart';
import 'package:app/models/grammarModel.dart';
import 'package:app/models/injectors/examInjector.dart';
import 'package:app/models/lessonModels/grammarSegmentModel.dart';
import 'package:app/models/lessonModels/lessonModel.dart';
import 'package:app/pages/exam_page.dart';
import 'package:app/system/enums.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/views/components/appbarLesson.dart';
import 'package:app/views/components/examBlankSpaseComponent.dart';
import 'package:app/views/components/examOptionComponent.dart';
import 'package:app/views/components/examSelectWordComponent.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxHeight.dart';
import 'package:video_player/video_player.dart';

class GrammarPageInjector {
  late LessonModel lessonModel;
  late GrammarSegmentModel segment;
}
///-----------------------------------------------------
class GrammarPage extends StatefulWidget {
  final GrammarPageInjector injection;

  const GrammarPage({
    required this.injection,
    Key? key
  }) : super(key: key);

  @override
  State<GrammarPage> createState() => _GrammarPageState();
}
///======================================================================================================================
class _GrammarPageState extends StateBase<GrammarPage> {
  Requester requester = Requester();
  List<GrammarModel> itemList = [];
  GrammarModel? currentItem;
  VideoPlayerController? playerController;
  ChewieController? chewieVideoController;
  bool isVideoInit = false;
  int currentItemIdx = 0;

  @override
  void initState(){
    super.initState();

    assistCtr.addState(AssistController.state$loading);
    requestIdioms();
  }

  @override
  void dispose(){
    requester.dispose();
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
      return ErrorOccur(onRefresh: onRefresh);
    }

    if(assistCtr.hasState(AssistController.state$loading)){
      return WaitToLoad();
    }

    if(assistCtr.hasState(AssistController.state$emptyData)){
      return Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
              child: BackButton()
          ),
          Expanded(
              child: EmptyData()
          ),
        ],
      );
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

                      AppbarLesson(title: widget.injection.lessonModel.title),

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
      assistCtr.updateMain();
    }
  }

  void onPreClick(){
    if(currentItemIdx > -1){
      chewieVideoController?.pause();
      currentItemIdx--;

      currentItem = itemList[currentItemIdx];
      initVideo();
      assistCtr.updateMain();
    }
  }

  void gotoNextPart(){
    /*if(widget.injection.segment.hasIdioms){
      final inject = IdiomsSegmentPageInjector();
      inject.lessonModel = widget.injection.lessonModel;
      inject.segment = widget.injection.segment;

      AppRoute.replace(context, IdiomsSegmentPage(injection: inject));
    }*/
  }

  void startExercise() async{
    showLoading();
    await requestExercise();
    await hideLoading();
  }

  void initVideo() async {
    isVideoInit = false;
    playerController = VideoPlayerController.network(currentItem?.media?.fileLocation?? '');

    await playerController!.initialize();
    isVideoInit = playerController!.value.isInitialized;

    if(mounted) {
      onVideoInit();
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

    assistCtr.updateMain();
  }

  void gotoExam(ExamModel examModel){
    ExamInjector examComponentInjector = ExamInjector();
    examComponentInjector.lessonModel = widget.injection.lessonModel;
    examComponentInjector.segment = widget.injection.lessonModel.grammarModel!;

    Widget component = SizedBox();
    String desc = '';

    if(examModel.quizType == QuizType.fillInBlank){
      component = ExamBlankSpaceComponent(injector: examComponentInjector);
      desc = 'جای خالی را پر کنید';
    }
    else if(examModel.quizType == QuizType.recorder){
      component = ExamSelectWordComponent(injector: examComponentInjector);
      desc = 'کلمه ی مناسب را انتخاب کنید';
    }
    else if(examModel.quizType == QuizType.multipleChoice){
      component = ExamOptionComponent(injector: examComponentInjector);
      desc = 'گزینه ی مناسب را انتخاب کنید';
    }


    final pageInjector = ExamPageInjector();
    pageInjector.lessonModel = widget.injection.lessonModel;
    pageInjector.segment = widget.injection.lessonModel.grammarModel!;
    pageInjector.examPage = component;
    pageInjector.description = desc;
    final examPage = ExamPage(injector: pageInjector);

    AppRoute.push(context, examPage);
  }

  void onRefresh(){
    assistCtr.clearStates();
    assistCtr.addStateAndUpdate(AssistController.state$loading);
    requestIdioms();
  }

  void requestIdioms(){
    requester.httpRequestEvents.onFailState = (req, res) async {
      assistCtr.clearStates();
      assistCtr.addStateAndUpdate(AssistController.state$error);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final List? data = res['data'];

      if(data is List){
        for(final m in data){
          final g = GrammarModel.fromMap(m);
          itemList.add(g);
        }
      }

      assistCtr.clearStates();

      if(itemList.isEmpty){
        assistCtr.addStateAndUpdate(AssistController.state$emptyData);
      }
      else {
        currentItem = itemList[0];

        assistCtr.updateMain();
        initVideo();
      }
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/grammars?LessonId=${widget.injection.lessonModel.id}');
    requester.request(context);
  }

  Future<void> requestExercise() async {
    Completer c = Completer();

    requester.httpRequestEvents.onFailState = (req, res) async {
      c.complete(null);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final List? data = res['data'];
print(res);
      if(data is List){
        for(final m in data){
          final g = GrammarModel.fromMap(m);
          itemList.add(g);
        }
      }

      c.complete();
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/grammars/quizzes?GrammarId=${currentItem!.id}');
    requester.debug = true;
    requester.request(context);

    return c.future;
  }
}