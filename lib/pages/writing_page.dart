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

class WritingPage extends StatefulWidget {
  final LessonModel lesson;
  final int index;

  const WritingPage({
    required this.lesson,
    this.index = 0,
    Key? key
  }) : super(key: key);

  @override
  State<WritingPage> createState() => _WritingPageState();
}
///======================================================================================================================
class _WritingPageState extends StateBase<WritingPage> with TickerProviderStateMixin {
  Requester requester = Requester();
  List<AutodidactModel> examList = [];
  late AutodidactModel currentItem;
  int currentIndex = 0;
  late AnimationController animController;

  @override
  void initState(){
    super.initState();

    currentIndex = widget.index;
    requestWriting();
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
    if(examList.isEmpty){
      return const SizedBox();
    }
    
    return Column(
      children: [
        const SizedBox(height: 10),

        /// writing
        Expanded(
            child: buildView(),
        ),

        /// send button
        buildBottomSection(),

        const SizedBox(height: 10),
      ],
    );
  }

  Widget buildBottomSection() {
    if(examList.length < 2){
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
                      foregroundColor: hasNext()? Colors.black : Colors.grey,
                    ),
                    onPressed: onNextClick,
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
                            child: Text('${currentIndex+1}').bold().ltr()
                        ),

                        Text('  /  ${examList.length}').ltr(),
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
                      foregroundColor: canPrev()? Colors.black : Colors.grey,
                    ),
                  onPressed: onPrevClick,
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

  bool hasNext(){
    return currentIndex < examList.length-1;
  }

  bool canPrev(){
    return currentIndex > 0;
  }

  void onSkipClick() {
    if(hasNext()){
      //answeredExamList.add(currentExam.id); todo.

      currentIndex++;
      currentItem = examList[currentIndex];

      animController.reset();
      assistCtr.updateHead();
      animController.forward();
    }
  }

  void onPrevClick() {
    if(canPrev()){
      //answeredAutodidactList.add(currentAutodidact.id);

      currentIndex--;
      currentItem = examList[currentIndex];

      animController.reset();
      assistCtr.updateHead();
      animController.forward();
    }
  }

  void onNextClick() {
    if(hasNext()){
      //answeredAutodidactList.add(currentAutodidact.id);

      currentIndex++;
      currentItem = examList[currentIndex];

      animController.reset();
      assistCtr.updateHead();
      animController.forward();
    }
  }

  void onSendAnswer() {
    //todo. answeredAutodidactList.add(currentAutodidact.id);
    assistCtr.updateHead();
  }

  Widget buildView(){
    return FadeIn(
      animate: true,
      manualTrigger: true,
      controller: (animCtr){
        animController = animCtr;
      },
      duration: const Duration(milliseconds: 500),
      child: Builder(
          builder: (_){
            return AutodidactVoiceComponent(model: currentItem, onSendAnswer: onSendAnswer);
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
}