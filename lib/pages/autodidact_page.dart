import 'package:animate_do/animate_do.dart';
import 'package:app/structures/models/examModels/autodidactModel.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/views/components/exam/autodidactVoiceComponent.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appSnack.dart';

class AutodidactPage extends StatefulWidget {
  final LessonModel lesson;

  const AutodidactPage({
    required this.lesson,
    Key? key
  }) : super(key: key);

  @override
  State<AutodidactPage> createState() => _AutodidactPageState();
}
///======================================================================================================================
class _AutodidactPageState extends StateBase<AutodidactPage> with TickerProviderStateMixin {
  Requester requester = Requester();
  late TabController tabController;
  List<AutodidactModel> writingList = [];
  List<AutodidactModel> speakingList = [];
  late AutodidactModel currentWriting;
  late AutodidactModel currentSpeaking;
  int currentWritingIndex = 0;
  int currentSpeakingIndex = 0;
  late AnimationController writingAnimController;
  late AnimationController speakingAnimController;

  @override
  void initState(){
    super.initState();

    tabController = TabController(length: 2, vsync: this);

    addPostOrCall(fn: (){
      if(writingList.isEmpty){
        tabController.animateTo(1);
      }
    });
  }

  @override
  void dispose(){
    super.dispose();

    requester.dispose();

    /*if(widget.injector.clearUserAnswerOnExit){
      for (final exam in widget.injector.examList) {
        exam.clearUserAnswers();todo.
      }
    }*/
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),

          /// page header
          buildHeader(),

          const SizedBox(height: 10),

          /// tabBar view
          Builder(
            builder: (ctx){
              if(writingList.isNotEmpty && speakingList.isNotEmpty){
                return TabBar(
                  controller: tabController,
                  tabs: const [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('نوشتن'),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('صحبت کردن'),
                    ),
                  ],
                );
              }

              return const SizedBox();
            },
          ),

          /// body view
          Expanded(
            child: TabBarView(
                controller: tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  buildWritingPage(),

                  buildSpeakingPage(),
                ]
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeader(){
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 4,
                  height: 26,
                  child: ColoredBox(color: AppDecoration.red),
                ),

                const SizedBox(width: 7),
                const Text('نوشتن و صحبت کردن').bold().fsR(4),
              ],
            ),

            GestureDetector(
              onTap: (){
                AppNavigator.pop(context);
              },
              child: Row(
                children: [
                  Text(AppMessages.back),
                  const SizedBox(width: 10),
                  CustomCard(
                      color: Colors.white,
                      padding: const EdgeInsets.all(5),
                      child: Image.asset(AppImages.arrowLeftIco)
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWritingPage(){
    if(writingList.isEmpty){
      return const SizedBox();
    }
    
    return Column(
      children: [
        const SizedBox(height: 10),

        /// writing
        Expanded(
            child: buildWritingView(),
        ),

        /// send button
        buildBottomSectionForWriting(),

        const SizedBox(height: 10),
      ],
    );
  }

  Widget buildSpeakingPage(){
    if(speakingList.isEmpty){
      return const SizedBox();
    }

    return Column(
      children: [
        const SizedBox(height: 20),

        /// speaking
        Expanded(child: buildSpeakingView()),

        buildBottomSectionForSpeaking(),

        const SizedBox(height: 10),
      ],
    );
  }

  /*Widget buildBottomSectionForWriting() {
    if(answeredExamList.length == writingList.length *//*|| !widget.injector.showSendButton*//*){
      return const SizedBox();
    }

    return Builder(
      builder: (context) {
        if (writingList.length < 2) {
          return ElevatedButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(200, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(
                  horizontal: 0, vertical: -2),
              //shape: StadiumBorder()
            ),
            onPressed: onSendExamAnswerClick,
            child: const Text('ثبت و بررسی')
                .englishFont().color(Colors.white),
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Expanded(
              child: ElevatedButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(100, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                  //shape: StadiumBorder()
                ),
                onPressed: onSendExamAnswerClick,
                child: Text(answeredExamList.contains(currentExam.id) ? AppMessages.next : 'ثبت و بررسی')
                    .englishFont().color(Colors.white),
              ),
            ),

            Expanded(
                child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: TextDirection.ltr,
                      children: [
                        CustomCard(
                            color: Colors.grey.shade200,
                            padding: const EdgeInsets.symmetric(horizontal:6, vertical: 2),
                            radius: 4,
                            child: Text('${currentExamIndex+1}').bold().ltr()
                        ),

                        Text('  /  ${widget.injector.examList.length}').ltr(),
                      ],
                    )
                )
            ),

            Expanded(
              child: Visibility(
                visible: hasNextExam(),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black87,
                    ),
                      onPressed: onExamSkipClick,
                      child: const Text('skip')
                  ),
                ),
              ),
            ),
          ],
        );
      }
    );
  }
*/
  Widget buildBottomSectionForSpeaking() {
    if(speakingList.length < 2){
      return const SizedBox();
    }

    return Builder(
      builder: (context) {
        return Row(
          mainAxisSize: MainAxisSize.max,
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: hasNextSpeaking()? Colors.black : Colors.grey,
                    ),
                    onPressed: onSpeakingNextClick,
                    icon: const Icon(AppIcons.arrowLeftIos, size: 16),
                    label: const Text('Next')
                ),
              )
            ),

            Expanded(
                child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: TextDirection.ltr,
                      children: [
                        CustomCard(
                          color: Colors.grey.shade200,
                            padding: const EdgeInsets.symmetric(horizontal:6, vertical: 2),
                            radius: 4,
                            child: Text('${currentSpeakingIndex+1}').bold().ltr()
                        ),

                        Text('  /  ${speakingList.length}').ltr(),
                      ],
                    )
                )
            ),

            //answeredAutodidactList.contains(currentAutodidact.id)?
            Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: canPrevSpeaking()? Colors.black : Colors.grey,
                    ),
                  onPressed: onSpeakingPrevClick,
                  icon: const Text('Prev'),
                  label: const RotatedBox(
                    quarterTurns: 2,
                      child: Icon(AppIcons.arrowLeftIos, size: 16)
                  )
                ),
                )
            ),
          ],
        );
      }
    );
  }

  Widget buildBottomSectionForWriting() {
    if(speakingList.length < 2){
      return const SizedBox();
    }

    return Builder(
      builder: (context) {
        return Row(
          mainAxisSize: MainAxisSize.max,
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: hasNextSpeaking()? Colors.black : Colors.grey,
                    ),
                    onPressed: onSpeakingNextClick,
                    icon: const Icon(AppIcons.arrowLeftIos, size: 16),
                    label: const Text('Next')
                ),
              )
            ),

            Expanded(
                child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: TextDirection.ltr,
                      children: [
                        CustomCard(
                          color: Colors.grey.shade200,
                            padding: const EdgeInsets.symmetric(horizontal:6, vertical: 2),
                            radius: 4,
                            child: Text('${currentSpeakingIndex+1}').bold().ltr()
                        ),

                        Text('  /  ${speakingList.length}').ltr(),
                      ],
                    )
                )
            ),

            //answeredAutodidactList.contains(currentAutodidact.id)?
            Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: canPrevSpeaking()? Colors.black : Colors.grey,
                    ),
                  onPressed: onSpeakingPrevClick,
                  icon: const Text('Prev'),
                  label: const RotatedBox(
                    quarterTurns: 2,
                      child: Icon(AppIcons.arrowLeftIos, size: 16)
                  )
                ),
                )
            ),
          ],
        );
      }
    );
  }

  bool hasNextWriting(){
    return currentWritingIndex < writingList.length-1;
  }

  bool hasNextSpeaking(){
    return currentSpeakingIndex < speakingList.length-1;
  }

  bool canPrevWriting(){
    return currentWritingIndex > 0;
  }

  bool canPrevSpeaking(){
    return currentSpeakingIndex > 0;
  }

  void onWritingSkipClick() {
    if(hasNextWriting()){
      //answeredExamList.add(currentExam.id); todo.

      currentWritingIndex++;
      currentWriting = writingList[currentWritingIndex];

      writingAnimController.reset();
      assistCtr.updateHead();
      writingAnimController.forward();
    }
  }

  void onSpeakingSkipClick() {
    if(hasNextSpeaking()){
      //answeredExamList.add(currentExam.id); todo.

      currentSpeakingIndex++;
      currentSpeaking = speakingList[currentSpeakingIndex];

      speakingAnimController.reset();
      assistCtr.updateHead();
      speakingAnimController.forward();
    }
  }

  void onWritingPrevClick() {
    if(canPrevWriting()){
      //answeredAutodidactList.add(currentAutodidact.id);

      currentWritingIndex--;
      currentWriting = writingList[currentWritingIndex];

      writingAnimController.reset();
      assistCtr.updateHead();
      writingAnimController.forward();
    }
  }

  void onSpeakingPrevClick() {
    if(canPrevSpeaking()){
      //answeredAutodidactList.add(currentAutodidact.id);

      currentSpeakingIndex--;
      currentSpeaking = speakingList[currentSpeakingIndex];

      speakingAnimController.reset();
      assistCtr.updateHead();
      speakingAnimController.forward();
    }
  }

  void onWritingNextClick() {
    if(hasNextWriting()){
      //answeredAutodidactList.add(currentAutodidact.id);

      currentWritingIndex++;
      currentWriting = writingList[currentWritingIndex];

      writingAnimController.reset();
      assistCtr.updateHead();
      writingAnimController.forward();
    }
  }

  void onSpeakingNextClick() {
    if(hasNextSpeaking()){
      //answeredAutodidactList.add(currentAutodidact.id);

      currentSpeakingIndex++;
      currentSpeaking = speakingList[currentSpeakingIndex];

      speakingAnimController.reset();
      assistCtr.updateHead();
      speakingAnimController.forward();
    }
  }

  void onWriteSendAnswer() {
    //todo. answeredAutodidactList.add(currentAutodidact.id);
    assistCtr.updateHead();
  }

  Widget buildWritingView(){
    return FadeIn(
      animate: true,
      manualTrigger: true,
      controller: (animCtr){
        writingAnimController = animCtr;
      },
      duration: const Duration(milliseconds: 500),
      child: Builder(
          builder: (_){
            return AutodidactVoiceComponent(model: currentWriting, onSendAnswer: onWriteSendAnswer);
          }
      ),
    );
  }

  Widget buildSpeakingView(){
    return FadeIn(
      animate: true,
      manualTrigger: true,
      controller: (animCtr){
        speakingAnimController = animCtr;
      },
      duration: const Duration(milliseconds: 500),
      child: Builder(
          builder: (_){
            return AutodidactVoiceComponent(model: currentSpeaking, onSendAnswer: onWriteSendAnswer);
          }
      ),
    );
  }

  void requestSendExamAnswer(){
    /*if(!examController.isAnswerToAll()){
        AppToast.showToast(context, 'لطفا به سوالات پاسخ دهید');
        return;
      }*/

    requester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, res) async {
      AppSnack.showSnack$errorCommunicatingServer(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      //answeredExamList.add(currentExam.id); todo.
      final message = res['message']?? 'پاسخ تمرین ثبت شد';

      AppSnack.showInfo(context, message, millis: 1600);

      assistCtr.updateHead();
    };

    final tempList = [];
    final js = <String, dynamic>{};

    /*if(currentExam.items.length < 2) {
      tempList.add({
        'exerciseId': currentExam.getExamItem().id,
        'answer': currentExam.getExamItem().getUserAnswerText(),
        'isCorrect': currentExam.getExamItem().isUserAnswerCorrect(),
      });
    }
    else {
      for (final itm in currentExam.items){
        tempList.add({
          'exerciseId': itm.id,
          'answer': currentExam.sentenceExtra!.joinUserAnswerById(itm.id),
          'isCorrect': currentExam.sentenceExtra!.isCorrectById(itm.id),
        });
      }
    }*/

    js['items'] = tempList;

    requester.methodType = MethodType.post;
    requester.prepareUrl(pathUrl: '');
    requester.bodyJson = js;

    showLoading();
    requester.request(context);
  }

  void requestWriting(){
    final requester = Requester();

    requester.httpRequestEvents.onAnyState = (req) async {
      requester.dispose();
    };

    requester.httpRequestEvents.onFailState = (req, res) async {
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final data = res['data'];

      if(data is List){
        List<AutodidactModel> itemList = [];

        for (final k in data) {
          final exam = AutodidactModel.fromMap(k);
          itemList.add(exam);
        }
      }
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/writing?LessonId=${widget.lesson.id}');
    requester.request(context);
  }

  void requestSpeaking(){
    final requester = Requester();

    requester.httpRequestEvents.onAnyState = (req) async {
      requester.dispose();
    };

    requester.httpRequestEvents.onFailState = (req, res) async {
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final data = res['data'];

      if(data is List){
        List<AutodidactModel> itemList = [];

        for (final k in data) {
          final exam = AutodidactModel.fromMap(k);
          itemList.add(exam);
        }
      }
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/speaking?LessonId=${widget.lesson.id}');
    requester.request(context);
  }

}