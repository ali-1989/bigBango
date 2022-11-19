import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/lessonModels/grammarModel.dart';
import 'package:app/models/lessonModels/lessonModel.dart';
import 'package:app/system/requester.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/views/components/appbarLesson.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxHeight.dart';
import 'package:video_player/video_player.dart';

class GrammarPageInjector {
  late LessonModel lessonModel;
  late GrammarModel segment;
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
  VideoPlayerController? playerController;
  ChewieController? chewieVideoController;
  bool isVideoInit = false;

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

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),

                AppbarLesson(title: widget.injection.lessonModel.title),

                SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text('ضمایر شخصی در زبان انگلیسی', style:TextStyle(color: Colors.black)),
                      backgroundColor: Colors.grey.shade400,
                      elevation: 0,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      labelPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                    ),

                    Chip(
                      label: Text('گرامر'),
                      backgroundColor: Colors.red,
                      elevation: 0,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      labelPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                    ),
                  ],
                ),
                SizedBox(height: 14),

               Builder(
                   builder: (ctx){
                     if(widget.injection.segment.media?.fileLocation != null){
                       if(isVideoInit){
                         return Chewie(controller: chewieVideoController!);
                       }
                       else {
                         return SizedBox(
                             height: 190,
                             child: const Center(child: CircularProgressIndicator())
                         );
                       }
                     }
                     else {
                       return Image.asset(AppImages.noImage);
                     }
                   }
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
                  color: Colors.red,
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
                  child: Chip(
                    backgroundColor: Colors.red,
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

        SizedBox(height: 14),
      ],
    );
  }

  void gotoNextPart(){
    /*if(widget.injection.segment.hasIdioms){
      final inject = IdiomsSegmentPageInjector();
      inject.lessonModel = widget.injection.lessonModel;
      inject.segment = widget.injection.segment;

      AppRoute.replace(context, IdiomsSegmentPage(injection: inject));
    }*/
  }

  void initVideo() async {
    isVideoInit = false;
    playerController = VideoPlayerController.network(widget.injection.segment.media?.fileLocation?? '');

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

      assistCtr.clearStates();
      assistCtr.updateMain();
      initVideo();
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/idioms?LessonId=${widget.injection.lessonModel.id}');
    requester.request(context);
  }
}