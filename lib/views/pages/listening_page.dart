import 'package:flutter/material.dart';

import 'package:iris_tools/api/duration/durationFormatter.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/custom_card.dart';

import 'package:app/managers/api_manager.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/controllers/examController.dart';
import 'package:app/structures/injectors/listeningPagesInjector.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/listeningModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/views/components/appbarLesson.dart';
import 'package:app/views/components/backBtn.dart';
import 'package:app/views/components/listening_exam_builder.dart';
import 'package:app/views/components/playVoiceView.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';

class ListeningPage extends StatefulWidget {
  final ListeningPageInjector injector;

  const ListeningPage({
    required this.injector,
    Key? key
  }) : super(key: key);

  @override
  State<ListeningPage> createState() => _ListeningPageState();
}
///======================================================================================================================
class _ListeningPageState extends StateSuper<ListeningPage> {
  Requester requester = Requester();
  Duration totalTime = const Duration();
  Duration currentTime = const Duration();
  ExamController? examController;
  List<ListeningModel> itemList = [];
  int currentItemIdx = 0;
  ListeningModel? currentItem;
  String? description;
  String id$playViewId = 'playViewId';
  PlayVoiceController voiceController = PlayVoiceController();

  @override
  void initState(){
    super.initState();

    assistCtr.addState(AssistController.state$loading);

    voiceController.onPrepareEvent = eventListener;
    voiceController.onDurationChange = durationListener;

    requestListening();
  }

  @override
  void dispose(){
    requester.dispose();
    voiceController.stop();

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
      return ErrorOccur(onTryAgain: onTryAgain, backButton: const BackBtn());
    }

    if(assistCtr.hasState(AssistController.state$loading)){
      return const WaitToLoad();
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
                  child: const Text('Listening').color(Colors.white),
                ),
              ),

              const SizedBox(height: 20),

              /// title
              Visibility(
                visible: currentItem?.title != null,
                child: Directionality(
                  textDirection: LocaleHelper.autoDirection(currentItem?.title?? ''),
                  child: SizedBox(
                    width: sw,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${currentItem?.title}'),
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
              ),

              const SizedBox(height: 20),

              /// player
              DecoratedBox(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Assist(
                      controller: assistCtr,
                      id: id$playViewId,
                      builder: (_, ctr, data) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
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
                                  ),
                                ],
                              ),

                              Expanded(
                                child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: PlayVoiceView(
                                    controller: voiceController,
                                    address: currentItem?.voice?.fileLocation?? '',
                                    isUrl: true,
                                    autoPrepare: true,
                                    buttonPadding: const EdgeInsets.all(8),
                                  ),
                                )
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  )
              ),

              const SizedBox(height: 20),

              Visibility(
                visible: description != null,
                  child: Text('$description')
              ),

              const SizedBox(height: 10),
              ListeningExamBuilder(examModelList: currentItem!.exams),

              const SizedBox(height: 20),
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

  void onNextClick() async {
    if(currentItemIdx < itemList.length-1) {
      currentItemIdx++;
      currentItem = itemList[currentItemIdx];

      await voiceController.stop();

      assistCtr.updateHead();
    }
  }

  void onPreClick() async {
    if(currentItemIdx > 0){
      currentItemIdx--;
      currentItem = itemList[currentItemIdx];

      await voiceController.stop();

      assistCtr.updateHead();
    }
  }

  void durationListener(Duration dur) {
    currentTime = dur;
    assistCtr.updateAssist(id$playViewId);
  }

  void eventListener(bool? prepare, Object? event){
    if(prepare == true) {
      totalTime = voiceController.totalTime;
      assistCtr.updateAssist(id$playViewId);
    }
    else {
      totalTime = Duration.zero;
    }
  }

  void onTryAgain(){
    assistCtr.clearStates();
    assistCtr.addStateAndUpdateHead(AssistController.state$loading);
    requestListening();
  }

  void requestListening(){
    requester.httpRequestEvents.onFailState = (req, res) async {
      assistCtr.clearStates();
      assistCtr.addStateAndUpdateHead(AssistController.state$error);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final List? data = res['data'];

      if(data is List){
        for(final m in data){
          final g = ListeningModel.fromMap(m);
          itemList.add(g);
        }
      }

      assistCtr.clearStates();

      if(itemList.isEmpty){
        assistCtr.addStateAndUpdateHead(AssistController.state$noData);
      }
      else {
        currentItem = itemList[0];

        assistCtr.updateHead();
      }
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/listening?CategoryId=${widget.injector.categoryId}');
    requester.request(context);
  }
}

