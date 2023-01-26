
import 'package:app/pages/support_page.dart';
import 'package:app/services/pages_event_service.dart';
import 'package:app/structures/models/ticketModels/ticketModel.dart';
import 'package:app/views/widgets/customCard.dart';

import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/system/extensions.dart';
import 'package:iris_tools/widgets/optionsRow/radioRow.dart';


class SelectBuyMethodSheet extends StatefulWidget {
  final int userBalance;
  final int amount;

  const SelectBuyMethodSheet({
    required this.userBalance,
    required this.amount,
    Key? key,
  }) : super(key: key);

  @override
  State<SelectBuyMethodSheet> createState() => _SelectBuyMethodSheetState();
}
///==================================================================================================
class _SelectBuyMethodSheetState extends StateBase<SelectBuyMethodSheet> {
  Requester requester = Requester();
  int radioGroupValue = -1;
  bool canPayByWallet = false;

  @override
  void dispose(){
    requester.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();

    if(widget.userBalance >= widget.amount){
      canPayByWallet = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
        controller: assistCtr,
        builder: (_, ctr, data) {
          final x = MediaQuery.of(context).viewInsets;

          return SizedBox(
            width: double.infinity,
            height: x.collapsedSize.height < 10 ? sh *3/7 : sh - x.collapsedSize.height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 14),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 15),
                  child: Column(
                    children: [
                      Text('هزینه را چطور پرداخت می کنید؟').bold().fsR(2),

                      SizedBox(height: 20),
                      Row(
                        children: [
                          CustomCard(
                            color: Colors.grey.shade200,
                              padding: EdgeInsets.all(3),
                              child: Text('مبلغ : ${widget.amount} تومان')
                          ),
                        ],
                      ),
                      SizedBox(height: 5),


                      IgnorePointer(
                          ignoring: !canPayByWallet,
                          child: RadioRow(
                            value: 1,
                            color: canPayByWallet? null: Colors.grey,
                            groupValue: radioGroupValue,
                            description: Row(
                              children: [
                                Text('پرداخت از کیف پول').alpha(alpha: canPayByWallet? 255: 150),
                                Text(' (موجودی ${widget.userBalance} تومان)').fsR(-3).alpha(),
                              ],
                            ),
                            //mainAxisSize: MainAxisSize.min,
                            onChanged: (v){
                              radioGroupValue = 1;
                              assistCtr.updateHead();
                            },
                          ),
                        ),

                      SizedBox(height: 2),
                      RadioRow(
                        value: 2,
                        groupValue: radioGroupValue,
                        description: Text('پرداخت با کارت عضو شتاب'),
                        //mainAxisSize: MainAxisSize.min,
                        onChanged: (v){
                          radioGroupValue = 2;
                          assistCtr.updateHead();
                        },
                      ),

                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                            onPressed: (){},
                            child: Text('پرداخت')
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
    );
  }

  void requestSendTicket({List<String>? attachments}){
    FocusHelper.hideKeyboardByUnFocusRoot();


    final body = <String, dynamic>{};

    if(attachments != null) {
      body['attachments'] = attachments;
    }

    requester.httpRequestEvents.onFailState = (req, res) async {
      hideLoading();

      String msg = 'خطایی اتفاق افتاده است';

      if(res != null && res.data != null){
        final js = JsonHelper.jsonToMap(res.data)!;
        msg = js['message'];
      }

      AppSheet.showSheetOk(context, msg);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      hideLoading();

      final data = res['data'];
      final id = data['id'];
      final number = data['number']?? 0;

      final tik = TicketModel();
      tik.id = id;
      tik.number = number;

      PagesEventService.getEventBus(SupportPage.pageEventId).callEvent(SupportPage.eventFnId$addTicket, tik);

      final message = res['message']?? 'تیکت ثبت شد';

      AppSheet.showSheetOneAction(context, message, (){AppRoute.popTopView(context);},
        buttonText:  'بله',
        dismissOnAction: true,
      );
    };

    showLoading();
    requester.methodType = MethodType.post;
    requester.prepareUrl(pathUrl: '/tickets/add');
    requester.bodyJson = body;
    requester.request(context);
  }
}
