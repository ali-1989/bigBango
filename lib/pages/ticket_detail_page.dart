
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appNavigator.dart';
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

  @override
  void initState(){
    super.initState();

    assistCtr.addState(AssistController.state$loading);
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
      children: [
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
                      Text(widget.ticketModel.title).bold().fsR(1),
                      DecoratedBox(
                        decoration: BoxDecoration(
                            color: Colors.greenAccent.withAlpha(40),
                            borderRadius: BorderRadius.circular(4)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
                          child: Text(widget.ticketModel.status == 1 ? 'باز' : 'بسته',
                              style: TextStyle(color: Color(0xFF0ECF73), fontSize: 10)
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),

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
        ),

        Divider(indent: 15, endIndent: 15, color: Colors.black54,),
        SizedBox(height: 20),

        Expanded(child: Text('f')),
      ],
    );
  }

  void onRefresh(){
    assistCtr.clearStates();
    assistCtr.addStateAndUpdateHead(AssistController.state$loading);
    requestTicketDetail();
  }

  void requestTicketDetail() async {
    requester.httpRequestEvents.onFailState = (req, res) async {

    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final data = res['data'];

      assistCtr.clearStates();
      assistCtr.updateHead();
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/tickets/details?Id=${widget.ticketModel.id}');
    requester.request(context);
  }
}
