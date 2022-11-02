import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/lessonModels/iSegmentModel.dart';
import 'package:app/models/lessonModels/lessonModel.dart';
import 'package:app/models/vocabModels/idiomModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/requester.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/views/customCard.dart';
import 'package:app/views/errorOccur.dart';
import 'package:app/views/waitToLoad.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/irisImageView.dart';
import 'package:video_player/video_player.dart';

class IdiomsSegmentPageInjector {
  late LessonModel lessonModel;
  late ISegmentModel segment;
}
///-----------------------------------------------------
class IdiomsSegmentPage extends StatefulWidget {
  final IdiomsSegmentPageInjector injection;

  const IdiomsSegmentPage({
    required this.injection,
    Key? key
  }) : super(key: key);

  @override
  State<IdiomsSegmentPage> createState() => _IdiomsSegmentPageState();
}
///======================================================================================================================
class _IdiomsSegmentPageState extends StateBase<IdiomsSegmentPage> {
  Requester requester = Requester();
  bool showTranslate = false;
  List<IdiomModel> idiomsList = [];
  int currentIdiomIdx = 0;
  late IdiomModel currentIdiom;
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
      return ErrorOccur(onRefresh: onRefresh);
    }

    if(assistCtr.hasState(AssistController.state$loading)){
      return WaitToLoad();
    }

    currentIdiom = idiomsList[currentIdiomIdx];
    Color preColor = Colors.black;
    Color nextColor = Colors.black;

    if(currentIdiomIdx == 0){
      preColor = Colors.grey;
    }

    if(currentIdiomIdx == idiomsList.length-1){
      nextColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),

            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              child: ColoredBox(
                color: Colors.red,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    child: ColoredBox(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(AppImages.lessonListIco),
                                SizedBox(width: 10),
                                Text(widget.injection.lessonModel.title).bold().fsR(3)
                              ],
                            ),

                            GestureDetector(
                              onTap: (){
                                AppNavigator.pop(context);
                              },
                              child: Row(
                                children: [
                                  Text(AppMessages.back),
                                  SizedBox(width: 10),
                                  CustomCard(
                                    color: Colors.grey.shade200,
                                      padding: EdgeInsets.all(5),
                                      child: Image.asset(AppImages.arrowLeftIco)
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 14),

            /// 7/20
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Chip(
                      label: Text(widget.injection.segment.title).bold().color(Colors.white),
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),

                    SizedBox(width: 10),

                    /*SizedBox(
                      height: 15,
                      width: 2,
                      child: ColoredBox(
                        color: Colors.black45,
                      ),
                    ),*/
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

            SizedBox(height: 14),
            /// progressbar
            Directionality(
                textDirection: TextDirection.ltr,
                child: LinearProgressIndicator(value: calcProgress(), backgroundColor: Colors.red.shade50)
            ),

            SizedBox(height: 14),

            Visibility(
              visible: currentIdiom.video?.fileLocation != null,
                child: isVideoInit? Chewie(controller: chewieVideoController!) : const Center(child: CircularProgressIndicator()),
            ),

            Visibility(
              visible: currentIdiom.video?.fileLocation == null,
                child: Image.asset(AppImages.noImage),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Flexible(child: Text(currentIdiom.content, textAlign: TextAlign.left).bold(weight: FontWeight.w400).fsR(4)),
                      ],
                    ),

                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 1,
                        child: ColoredBox(color: Colors.grey),
                      ),
                    ),

                    AnimatedCrossFade(
                        firstChild: InputChip(
                          onPressed: (){
                            showTranslate = !showTranslate;
                            assistCtr.updateMain();
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

            SizedBox(height: 14),
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
            SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  double calcProgress(){
    int r = ((currentIdiomIdx+1) * 100) ~/ idiomsList.length;
    return r/100;
  }

  void onNextClick(){
    chewieVideoController?.pause();
    currentIdiomIdx++;
    assistCtr.updateMain();
  }

  void onPreClick(){
    chewieVideoController?.pause();
    currentIdiomIdx--;
    assistCtr.updateMain();
  }

  void initVideo(){
    isVideoInit = false;
    playerController = VideoPlayerController.network('todo');

    playerController!.initialize().then((value) {
      isVideoInit = playerController!.value.isInitialized;
      onVideoInit();
    });
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

      if(data is List){
        for(final k in data){
          final vo = IdiomModel.fromMap(k);

          //todo: temp
          for(int i=0 ; i<20; i++){
            final temp = IdiomModel.fromMap(vo.toMap());
            temp.id = 'iddd-$i';
            idiomsList.add(temp);
          }
        }
      }

      assistCtr.clearStates();
      assistCtr.updateMain();
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/idioms?LessonId=${widget.injection.lessonModel.id}');
    requester.request(context);
  }
}