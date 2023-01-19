import 'package:app/structures/injectors/ticketDetailUserBubbleInjector.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/structures/models/ticketModels/ticketDetailModel.dart';
import 'package:app/structures/models/userModel.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/views/sheets/replyTicketSheet.dart';
import 'package:app/views/components/ticketDetailBigbangoBubbleComponent.dart';
import 'package:app/views/components/ticketDetailUserBubbleComponent.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:app/views/widgets/customCard.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/models/ticketModels/ticketModel.dart';

class TicketDetailPage extends StatefulWidget {
  final TicketModel ticketModel;

  const TicketDetailPage({
    required this.ticketModel,
    Key? key,
  }) : super(key: key);

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}
///=================================================================================================
class _TicketDetailPageState extends StateBase<TicketDetailPage> {
  Requester requester = Requester();
  late TicketModel ticketModel;
  late UserModel userModel;
  TicketDetailModel? ticketDetailModel;

  @override
  void initState(){
    super.initState();

    ticketModel = widget.ticketModel;
    assistCtr.addState(AssistController.state$loading);
    userModel = Session.getLastLoginUser()!;

    requestTicketDetail();
  }

  @override
  void dispose(){
    requester.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (_, ctr, data){
        return Scaffold(
          body: buildBody(),
          floatingActionButton: ElevatedButton(
            onPressed: openNewResponse,
            child: Text('پاسخ دادن'),
          ),
        );
      },
    );
  }

  Widget buildBody(){
    if(assistCtr.hasState(AssistController.state$error)){
      return ErrorOccur(onRefresh: onRefresh);
    }

    if(assistCtr.hasState(AssistController.state$loading)){
      return WaitToLoad();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// header
        SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 4,
                    height: 36,
                    child: ColoredBox(color: AppColors.red),
                  ),

                  SizedBox(width: 7),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ticketModel.title).bold().fsR(1),
                      DecoratedBox(
                        decoration: BoxDecoration(
                            color: ticketModel.status == 1 ? AppColors.greenTint : AppColors.redTint,
                            borderRadius: BorderRadius.circular(4)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
                          child: Text(ticketModel.status == 1 ? 'باز' : 'بسته',
                              style: TextStyle(color: ticketModel.status == 1 ? AppColors.green : Colors.red, fontSize: 10)
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),

              Row(
                children: [
                  Visibility(
                    visible: widget.ticketModel.status == 1,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        ),
                        onPressed: closeTicket,
                        child: Text('بستن',
                            textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: true, applyHeightToLastDescent: true)
                        ).subFont().color(Colors.white)
                    ),
                  ),

                  SizedBox(width: 10,),
                  GestureDetector(
                    onTap: (){
                      AppNavigator.pop(context);
                    },
                    child: Row(
                      children: [
                        //Text(AppMessages.back),
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
            ],
          ),
        ),
        Divider(indent: 15, endIndent: 15, color: Colors.black54,),
        SizedBox(height: 20),

        /// content
        Expanded(
            child: ListView.builder(
                itemCount: ticketDetailModel!.replies.length +1,
                itemBuilder: buildList,
            ),
        ),
      ],
    );
  }

  Widget buildList(_, int idx) {
    if (idx == 0) {
      return TicketDetailUserBubbleComponent(
        injector: TicketDetailBubbleInjector(ticketDetailModel!.firstTicket),
      );
    }

    final item = ticketDetailModel!.replies[idx-1];

    if (item.creator.id == userModel.userId) {
      return TicketDetailUserBubbleComponent(
        injector: TicketDetailBubbleInjector(item),
      );
    }
    else {
      return TicketDetailBigbangoBubbleComponent(
        injector: TicketDetailBubbleInjector(item),
      );
    }
  }

  void onRefresh(){
    assistCtr.clearStates();
    assistCtr.addStateAndUpdateHead(AssistController.state$loading);
    requestTicketDetail();
  }

  void closeTicket() {
    void yesFn(){
      requestCloseTicket();
    }

    AppDialogIris.instance.showYesNoDialog(
      context,
      yesFn: yesFn,
      desc: 'آیا می خواهید تیکت بسته شود؟',
    );
  }

  void openNewResponse() async {
    final res = await AppSheet.showSheetCustom(
      context,
      builder: (ctx) => ReplyTicketSheet(ticketDetailModel: ticketDetailModel!),
      routeName: 'ReplyTicketSheet',
      contentColor: Colors.transparent,
      isScrollControlled: true,
    );

    if(res is bool && res){
      onRefresh();
    }
  }

  void requestTicketDetail() async {
    requester.httpRequestEvents.onFailState = (req, res) async {
      assistCtr.clearStates();
      assistCtr.addStateAndUpdateHead(AssistController.state$error);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final data = res['data'];

      if(data is Map){
        ticketDetailModel = TicketDetailModel.fromMap(data);
      }

      assistCtr.clearStates();
      assistCtr.updateHead();
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/tickets/details?Id=${ticketModel.id}');
    requester.request(context);
  }

  void requestCloseTicket(){
    requester.httpRequestEvents.onFailState = (req, res) async {
      hideLoading();
      AppSnack.showSnack$OperationFailed(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      hideLoading();
      AppSnack.showSnack$operationSuccess(context);

      widget.ticketModel.status = 2;
      assistCtr.updateHead();
    };

    final js = <String, dynamic>{};
    js['ticketId'] = widget.ticketModel.id;

    showLoading();
    requester.methodType = MethodType.post;
    requester.bodyJson = js;
    requester.prepareUrl(pathUrl: '/tickets/close');
    requester.request(context);
  }
}
