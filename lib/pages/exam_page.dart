import 'package:app/tools/app/appDecoration.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';

import 'package:app/pages/autodidact_builder.dart';
import 'package:app/pages/exam_builder.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/builders/examBuilderContent.dart';
import 'package:app/structures/controllers/examController.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appSnack.dart';

class ExamPage extends StatefulWidget {
  final ExamBuilderContent builder;
  final bool groupSameTypes;

  const ExamPage({
    required this.builder,
    this.groupSameTypes = true,
    Key? key
  }) : super(key: key);

  @override
  State<ExamPage> createState() => _ExamPageState();
}
///======================================================================================================================
class _ExamPageState extends StateBase<ExamPage> with TickerProviderStateMixin {
  Requester requester = Requester();
  late TabController tabController;


  @override
  void initState(){
    super.initState();

    tabController = TabController(length: 2, vsync: this);
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
          SizedBox(height: 20),

          /// page header
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 4,
                        height: 26,
                        child: ColoredBox(color: AppDecoration.red),
                      ),

                      SizedBox(width: 7),
                      Text('تمرین').bold().fsR(4),
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
                            color: Colors.white,
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

          SizedBox(height: 10),

          /// tabBar view
          Builder(
            builder: (ctx){
              if(widget.builder.autodidactList.isNotEmpty){
                return TabBar(
                  controller: tabController,
                  tabs: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('تمرین'),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('خودآموز'),
                    ),
                  ],
                );
              }

              return SizedBox();
            },
          ),


          /// body view
          Expanded(
            child: TabBarView(
                controller: tabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  buildPage1(),

                  buildPage2(),
                ]
            ),
          ),
        ],
      ),
    );
  }


  Widget buildPage1(){
    return Column(
      children: [
        SizedBox(height: 10),

        /// exams
        Expanded(child: ExamBuilder(builder: widget.builder, groupSameTypes: widget.groupSameTypes)),

        /// send button
        Visibility(
            visible: widget.builder.showSendButton && !widget.builder.examList.any((element) => element.showAnswer),
            child: ElevatedButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(200, 40),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity(horizontal: 0, vertical: -2),
                //shape: StadiumBorder()
              ),
              onPressed: sendAnswer,
              child: Text(widget.builder.sendButtonText).englishFont().color(Colors.white),
            )
        ),

        SizedBox(height: 10),
      ],
    );
  }

  Widget buildPage2(){
    return Column(
      children: [
        SizedBox(height: 20),

        /// exams
        Expanded(child: AutodidactBuilder(builder: widget.builder)),

        SizedBox(height: 10),
      ],
    );
  }

  void sendAnswer(){
    AppDialogIris.instance.showYesNoDialog(
      context,
      yesFn: (ctx) {
        Future.delayed(Duration(milliseconds: 500)).then((value) {
          requestSendAnswer();
        });
      },
      desc: 'آیا جواب تمرین ارسال شود؟',
    );
  }

  void requestSendAnswer(){
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
      //bool sentResult = false; sentResult = true;

      final message = res['message']?? 'پاسخ تمرین ثبت شد';

      AppSnack.showInfo(context, message);

      for(final x in widget.builder.examList){
        ExamController.getControllerFor(x.getFirst().id)?.showAnswers(true);
      }

      assistCtr.updateHead();
    };

    final tempList = [];
    final js = <String, dynamic>{};

    for(final x in widget.builder.examList){
      if(x.items.length < 2) {
        tempList.add({
          'exerciseId': x.getFirst().id,
          'answer': x.getFirst().getUserAnswerText(),
          'isCorrect': x.getFirst().isUserAnswerCorrect(),
        });
      }
      else {
        for (final itm in x.items){
          tempList.add({
            'exerciseId': itm.id,
            'answer': itm.getUserAnswerText(),
            'isCorrect': itm.isUserAnswerCorrect(),
          });
        }
      }
    }

    js['items'] = tempList;

    requester.methodType = MethodType.post;
    requester.prepareUrl(pathUrl: widget.builder.answerUrl);
    requester.bodyJson = js;

    showLoading();
    requester.request(context);
  }
}


