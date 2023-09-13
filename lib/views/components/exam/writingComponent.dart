import 'package:app/tools/app/app_messages.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';
import 'package:just_audio/just_audio.dart';

import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/examModels/writingModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/tools/route_tools.dart';

class WritingComponent extends StatefulWidget {
  final WritingModel writingModel;
  final VoidCallback onSendAnswer;

  const WritingComponent({
    required this.writingModel,
    required this.onSendAnswer,
    Key? key
  }) : super(key: key);

  @override
  State<WritingComponent> createState() => WritingComponentState();
}
///=================================================================================================================
class WritingComponentState extends StateSuper<WritingComponent> {
  late WritingModel writingModel;
  Requester requester = Requester();
  TextEditingController answerCtr = TextEditingController();

  @override
  void initState(){
    super.initState();

    writingModel = widget.writingModel;
  }

  @override
  void dispose(){
    requester.dispose();
    answerCtr.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
        builder: (ctx, ctr, data){
          return buildBody();
        }
    );
  }

  Widget buildBody(){
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(AppImages.doubleArrow),
              const SizedBox(width: 4),

              Expanded(child: Text(writingModel.question?? '', maxLines: 2)),
            ],
          ),
          const SizedBox(height: 20),

          Directionality(
            textDirection: LocaleHelper.autoDirection(writingModel.text!),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 15),
              child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: double.infinity,
                    minHeight: 50,
                  ),
                  child: Text(writingModel.text!).englishFont()),
            ).wrapDotBorder(
                color: Colors.black12,
                alpha: 100,
                dashPattern: [4,8]),
          ),

          const SizedBox(height: 30),
          const Divider(color: Colors.black26),
          const SizedBox(height: 15),

          const Align(
            alignment: Alignment.topRight,
              child: Row(
                children: [
                  SizedBox(
                    height: 15,
                    width: 2,
                    child: ColoredBox(color: Colors.black),
                  ),

                  SizedBox(width: 6),
                  Text('پاسخ شما:'),
                ],
              )
          ),
          const SizedBox(height: 15),

          buildTextReply(),

          const SizedBox(height: 20),
          buildCorrectAnswerView(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget buildTextReply(){
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: answerCtr,
          minLines: 4,
          maxLines: 6,
          decoration: const InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ).wrapDotBorder(
          color: Colors.black,
          alpha: 100,
          dashPattern: [4,8]
      ),
    );
  }

  Widget buildCorrectAnswerView(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: showAnswer,
            child: const Text('مشاهده پاسخ صحیح'),
          ),
        ),

        const SizedBox(width: 10),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green
            ),
            onPressed: sendAnswer,
            child: const Text('ارسال پاسخ'),
          ),
        ),
      ],
    );
  }

  void showAnswer(){
    final w = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: CustomCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            children: [
              const Text('پاسخ صحیح').bold().fsR(4),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      writingModel.correctAnswer?? '',
                    ).englishFont(),
                  ),
                ),
              ).wrapDotBorder(
                  color: Colors.black,
                  alpha: 100,
                  dashPattern: [4,8]
              ),

              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: (){
                      RouteTools.popTopView(context: context);
                    },
                    child: const Text('بستن')
                ),
              ),
            ],
          ),
        ),
      ),
    );

    AppSheet.showSheetCustom(
        context,
        builder: (ctx){
          return w;
        },
        routeName: 'showAnswer',
      contentColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void eventListener(PlaybackEvent event){
    assistCtr.updateHead();
  }

  void sendAnswer() async {
    if(answerCtr.text.trim().isEmpty){
      AppSheet.showSheetOk(context, 'لطفا پاسخ خود را بنویسید');
      return;
    }

    await FocusHelper.hideKeyboardByUnFocusRootWait();

    requester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, res) async {
      if(res?.data != null){
        final map = JsonHelper.jsonToMap(res?.data)!;

        final message = map['message'];

        if(message != null){
          AppSnack.showInfo(context, message);
          return;
        }
      }

      AppSnack.showSnackText(context, AppMessages.errorCommunicatingServer);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final message = res['message']?? 'پاسخ شما ثبت شد';

      AppSnack.showInfo(context, message);
      widget.onSendAnswer.call();
    };

    final js = <String, dynamic>{};
    js['writingId'] = writingModel.id;
    js['userAnswer'] = answerCtr.text.trim();

    requester.methodType = MethodType.post;
    requester.prepareUrl(pathUrl: '/writing/solving');
    requester.bodyJson = js;

    showLoading();
    requester.request(context);
  }
}


