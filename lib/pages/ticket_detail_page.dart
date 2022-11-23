import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/ticketModel.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

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

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
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
    return Center();
  }
}
