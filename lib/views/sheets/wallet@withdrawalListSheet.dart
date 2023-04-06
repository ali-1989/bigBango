import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/jsonHelper.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/withdrawalModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/currencyTools.dart';
import 'package:app/tools/dateTools.dart';

class WalletWithdrawalListSheet extends StatefulWidget {
  final List<WithdrawalModel> withdrawalList;

  WalletWithdrawalListSheet({
    Key? key,
    required this.withdrawalList,
  }) : super(key: key);

  @override
  State<WalletWithdrawalListSheet> createState() => _WalletWithdrawalListSheetState();
}
///==================================================================================
class _WalletWithdrawalListSheetState extends StateBase<WalletWithdrawalListSheet> {
  Requester requester = Requester();


  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
    requester.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: sh * 3/5,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  padding: EdgeInsets.zero,
                    visualDensity: VisualDensity(vertical: -4),
                    iconSize: 17,
                    splashRadius: 14,
                    constraints: BoxConstraints.tightFor(),
                    onPressed: (){
                      RouteTools.popTopView(context: context);
                    },
                    icon: Icon(AppIcons.close, size: 17)
                ),
              ),

              SizedBox(height: 2),
              Text('درخواست های درحال بررسی', textAlign: TextAlign.center, style: TextStyle(height: 1.4)).fsR(1),
              SizedBox(height: 20),

              Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.withdrawalList.length,
                      itemBuilder: itemBuilder
                  ),
              ),

              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget itemBuilder(_, idx){
    final wModel = widget.withdrawalList[idx];

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal:8.0, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('مبلغ ${CurrencyTools.formatCurrency(wModel.amount)}'),

            Text(DateTools.dateAndHmRelative(wModel.date)).alpha(),

            IconButton(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity(vertical: -4),
                iconSize: 22,
                splashRadius: 14,
                constraints: BoxConstraints.tightFor(),
                onPressed: (){
                  cancelWithdrawal(wModel);
                },
                icon: Icon(AppIcons.remove, color: Colors.red)
            )
          ],
        ),
      ),
    );
  }

  void cancelWithdrawal(WithdrawalModel wModel){
    void yesFn() {
      requestCancelWithdrawal(wModel);
    }

    AppDialogIris.instance.showYesNoDialog(
        context,
      yesFn: yesFn,
      desc: 'آیا درخواست لغو شود؟',
    );
  }

  void requestCancelWithdrawal(WithdrawalModel wModel) {
    requester.httpRequestEvents.onFailState = (req, res) async {
      await hideLoading();

      String msg = 'خطایی رخ داده است';

      if(res != null && res.data != null){
        final js = JsonHelper.jsonToMap(res.data)?? {};
        msg = js['message']?? msg;
      }

      AppSheet.showSheetNotice(context, msg);
    };

    requester.httpRequestEvents.onStatusOk = (req, dataJs) async {
      await hideLoading();
      widget.withdrawalList.remove(wModel);
      callState();
    };

    showLoading();
    requester.methodType = MethodType.post;
    requester.bodyJson = {'id': wModel.id};
    requester.prepareUrl(pathUrl: '/wallet/withdrawal/cancel');
    requester.request(context);
  }
}
