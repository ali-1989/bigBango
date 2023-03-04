import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/urlHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/optionsRow/radioRow.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:iris_tools/widgets/customCard.dart';

class SelectBuyMethodSheet extends StatefulWidget {
  final int userBalance;
  final int amount;
  final int? minutes;
  final String? planId;
  final List<int>? lessonIds;

  const SelectBuyMethodSheet({
    required this.userBalance,
    required this.amount,
    this.minutes,
    this.planId,
    this.lessonIds,
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
                            onPressed: requestBuy,
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

  void requestBuy(){
    if(radioGroupValue < 1){
      AppToast.showToast(context, 'لطفا یک گزینه را انتخاب کنید');
      return;
    }

    FocusHelper.hideKeyboardByUnFocusRoot();
    requester.httpRequestEvents.onFailState = (req, res) async {
      hideLoading();

      String msg = 'خطایی اتفاق افتاده است';

      if(res != null && res.data != null){
        final js = JsonHelper.jsonToMap(res.data)!;
        msg = js['message']?? msg;
      }

      AppSheet.showSheetOk(context, msg);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      hideLoading();

      final data = res['data'];
      final isPaid = data['paid'];
      final Map bankPortal = data['bankPortal']?? {};

      if(isPaid){
        final message = res['message']?? 'با موفقیت پرداخت شد';

        AppSheet.showSheetOneAction(context, message, () {
          AppRoute.popTopView(context);
        });
      }
      else {
        final url = bankPortal['url']?? '';
        await UrlHelper.launchLink(url, mode: LaunchMode.externalApplication);

        AppRoute.popTopView(context);
      }
    };

    final body = <String, dynamic>{};
    body['fromWallet'] = radioGroupValue == 1;

    if(widget.minutes != null) {
      if (widget.planId != null) {
        body['supportPlanId'] = widget.planId;
      }
      else {
        body['minutes'] = widget.minutes;
      }
    }
    else {
      body['lessonIds'] = widget.lessonIds;
    }

    showLoading();
    requester.bodyJson = body;
    requester.methodType = MethodType.post;

    if(widget.minutes != null) {
      requester.prepareUrl(pathUrl: '/support/purchase');
    }
    else {
      requester.prepareUrl(pathUrl: '/lessons/purchase');
    }

    requester.request(context);
  }
}
