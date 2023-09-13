import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/urlHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';
import 'package:iris_tools/widgets/optionsRow/radioRow.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/tools/currency_tools.dart';
import 'package:app/tools/route_tools.dart';

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
class _SelectBuyMethodSheetState extends StateSuper<SelectBuyMethodSheet> {
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
          final viewInsets = MediaQuery.of(context).viewInsets;

          return SizedBox(
            width: double.infinity,
            height: viewInsets.collapsedSize.height < 10 ? sh *3/7 : sh - viewInsets.collapsedSize.height,
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
                      const Text('هزینه را چطور پرداخت می کنید؟').bold().fsR(2),

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          CustomCard(
                            color: Colors.grey.shade200,
                              padding: const EdgeInsets.all(3),
                              child: Text('مبلغ : ${CurrencyTools.formatCurrency(widget.amount)} تومان')
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),


                      IgnorePointer(
                          ignoring: !canPayByWallet,
                          child: RadioRow(
                            value: 1,
                            color: canPayByWallet? null: Colors.grey,
                            groupValue: radioGroupValue,
                            description: Row(
                              children: [
                                const Text('پرداخت از کیف پول').fsR(2).alpha(alpha: canPayByWallet? 255: 150),
                                Text(' (موجودی ${CurrencyTools.formatCurrency(widget.userBalance)} تومان)').fsR(-2).alpha(),
                              ],
                            ),
                            //mainAxisSize: MainAxisSize.min,
                            onChanged: (v){
                              radioGroupValue = 1;
                              assistCtr.updateHead();
                            },
                          ),
                        ),

                      const SizedBox(height: 2),
                      RadioRow(
                        value: 2,
                        groupValue: radioGroupValue,
                        description: const Text('پرداخت با کارت عضو شتاب').fsR(2),
                        //mainAxisSize: MainAxisSize.min,
                        onChanged: (v){
                          radioGroupValue = 2;
                          assistCtr.updateHead();
                        },
                      ),

                      const Expanded(child: SizedBox()),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                            onPressed: requestBuy,
                            child: const Text('پرداخت')
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

        AppSheet.showSheetOneAction(context, message, onButton: () {
          RouteTools.popTopView(context: context, data: true);
        });
      }
      else {
        final url = bankPortal['url']?? '';
        await UrlHelper.launchLink(url, mode: LaunchMode.externalApplication);

        RouteTools.popTopView(context: context, data: false);
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
