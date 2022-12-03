import 'package:app/pages/grammar_page.dart';
import 'package:app/pages/listening_page.dart';
import 'package:app/pages/reading_page.dart';
import 'package:app/structures/injectors/grammarPagesInjector.dart';
import 'package:app/structures/injectors/listeningPagesInjector.dart';
import 'package:app/structures/injectors/readingPagesInjector.dart';
import 'package:app/structures/injectors/vocabPagesInjector.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:flutter/material.dart';

import 'package:chewie/chewie.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/attribute.dart';
import 'package:video_player/video_player.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/structures/models/vocabModels/idiomModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/views/components/appbarLesson.dart';
import 'package:app/views/components/greetingView.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:app/views/widgets/customCard.dart';


class IdiomsPage extends StatefulWidget {
  final VocabPageInjector injector;

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
      return Column(
        children: [
          Align(
              alignment: Alignment.topRight,
              child: BackButton()
          ),
          Expanded(
              child: ErrorOccur(onRefresh: onRefresh)
          ),
        ],
      );
    }

    if(assistCtr.hasState(AssistController.state$loading)){
      return WaitToLoad();
    }

    if(assistCtr.hasState(AssistController.state$emptyData)){
      return Column(
        children: [
          Align(
              alignment: Alignment.topRight,
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
    initVideo();

    if(currentIdiomIdx == 0){
      preColor = Colors.grey;
    }

    if(currentIdiomIdx == idiomsList.length){
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
                      Row(
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

                      SizedBox(height: 14),

                      /// progressbar
                      Directionality(
                          textDirection: TextDirection.ltr,
                          child: LinearProgressIndicator(value: calcProgress(), backgroundColor: AppColors.red.withAlpha(50))
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
                                 assistCtr.updateMain();
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
                                 Builder(
                                   builder: (_){
                                     if(currentIdiom.video?.fileLocation != null){
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
                                   },
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
    Widget? page;

    if (widget.injector.lessonModel.grammarModel != null){
      page = GrammarPage(injection: GrammarPageInjector(widget.injector.lessonModel));
    }
    else if (widget.injector.lessonModel.readingModel != null){
      page = ReadingPage(injector: ReadingPageInjector(widget.injector.lessonModel));
    }
    else if (widget.injector.lessonModel.listeningModel != null){
      page = ListeningPage(injector: ListeningPageInjector(widget.injector.lessonModel));
    }

    if(page != null) {
      AppRoute.replace(context, page);
    }
  }

  void resetVocab(){
    showGreeting = false;
    currentIdiomIdx = 0;

    assistCtr.updateMain();
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
    }
    else {
      showGreeting = true;
    }

    assistCtr.updateMain();
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

    assistCtr.updateMain();
  }

  void initVideo() async {
    if(currentIdiom.video?.fileLocation == null){
      return;
    }

    isVideoInit = false;
    //playerController = VideoPlayerController.network(currentIdiom.video!.fileLocation!);
    playerController = VideoPlayerController.network('https://bigbangofiles.nicode.org/2022/11/a2e160133ef64cc1b9f6c7dcf885fba8.mp4');

    await playerController!.initialize();
    isVideoInit = playerController!.value.isInitialized;

    if(mounted) {
      if(isVideoInit) {
        onVideoInit();
      }
      else {
        assistCtr.updateMain();
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

      if(data is List){
        for(final k in data){
          final vo = IdiomModel.fromMap(k);

          idiomsList.add(vo);
        }
      }
      else {
        assistCtr.addStateAndUpdate(AssistController.state$error);
        return;
      }

      if(idiomsList.isEmpty){
        assistCtr.addStateAndUpdate(AssistController.state$emptyData);
      }
      else {
        //todo currentIdiom = idiomsList[0];
        currentIdiom = idiomsList[1];
        showTranslate = currentIdiom.showTranslation;

        assistCtr.updateMain();
        initVideo();
      }
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/idioms?LessonId=${widget.injector.lessonModel.id}');
    requester.request(context);
  }
}
