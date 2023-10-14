import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/custom_card.dart';

import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/examModels/writingModel.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_navigator.dart';
import 'package:app/views/components/exam/writingComponent.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';

class WritingPage extends StatefulWidget {
  final LessonModel lesson;
  final String categoryId;

  const WritingPage({
    required this.lesson,
    required this.categoryId,
    Key? key
  }) : super(key: key);

  @override
  State<WritingPage> createState() => _WritingPageState();
}
///======================================================================================================================
class _WritingPageState extends StateSuper<WritingPage> with TickerProviderStateMixin {
  Requester requester = Requester();
  List<WritingModel> examList = [];
  late WritingModel currentItem;
  int currentIndex = 0;
  late AnimationController animController;

  @override
  void initState(){
    super.initState();

    assistCtr.addStateAndUpdateHead(AssistController.state$loading);
    requestWriting();
  }

  @override
  void dispose(){
    super.dispose();

    requester.dispose();
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
          Expanded(
              child: buildContent()
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
                const Text('نوشتن').bold().fsR(1),
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

  Widget buildContent(){
    if(assistCtr.hasState(AssistController.state$error)){
      return ErrorOccur(onTryAgain: onRefresh);
    }

    if(assistCtr.hasState(AssistController.state$loading)){
      return const WaitToLoad();
    }

    if(examList.isEmpty){
      return const EmptyData();
    }
    
    return Column(
      children: [
        const SizedBox(height: 10),

        /// writing exam
        Expanded(
            child: FadeIn(
                animate: true,
                manualTrigger: false,
                controller: (animCtr){
                  animController = animCtr;
                },
                duration: const Duration(milliseconds: 500),
                child: WritingComponent(
                  key: ValueKey(currentIndex),
                    writingModel: currentItem,
                    onSendAnswer: onSendAnswerClick
                )
            ),
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

  void onRefresh(){
    assistCtr.clearStates();
    assistCtr.addStateAndUpdateHead(AssistController.state$loading);
    requestWriting();
  }

  bool hasNext(){
    return currentIndex < examList.length-1;
  }

  bool canPrev(){
    return currentIndex > 0;
  }

  void onPrevClick() {
    if(canPrev()){
      currentIndex--;
      currentItem = examList[currentIndex];

      animController.reset();
      assistCtr.updateHead();
      animController.forward();
    }
  }

  void onNextClick() {
    if(hasNext()){
      currentIndex++;
      currentItem = examList[currentIndex];

      animController.reset();
      assistCtr.updateHead();
      animController.forward();
    }
  }

  void onSendAnswerClick() {
    assistCtr.updateHead();
  }

  void requestWriting(){
    final requester = Requester();

    requester.httpRequestEvents.onAnyState = (req) async {
      requester.dispose();
    };

    requester.httpRequestEvents.onFailState = (req, res) async {
      assistCtr.clearStates();
      assistCtr.addStateAndUpdateHead(AssistController.state$error);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final data = res['data'];

      if(data is List){
        List<WritingModel> itemList = [];

        for (final k in data) {
          final exam = WritingModel.fromMap(k);
          itemList.add(exam);
        }

        examList.addAll(itemList);

        if(examList.isNotEmpty) {
          currentItem = examList[currentIndex];
        }

        assistCtr.clearStates();
        assistCtr.updateHead();
      }
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/writing?CategoryId=${widget.categoryId}');
    requester.request(context);
  }
}
