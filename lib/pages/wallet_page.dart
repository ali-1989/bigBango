import 'dart:async';

import 'package:app/services/event_dispatcher_service.dart';
import 'package:app/structures/models/transactionModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appSnack.dart';

import 'package:app/views/sheets/incraseAmountComponent.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:app/views/widgets/customCard.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/urlHelper.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:url_launcher/url_launcher.dart';


class WalletPage extends StatefulWidget {

  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}
///========================================================================================
class _WalletPageState extends StateBase<WalletPage> {
  Requester requester = Requester();
  RefreshController refreshController = RefreshController(initialRefresh: false);
  int walletBalance = 0;
  int withdrawalBalance = 0;
  List<TransactionModel> transactionList = [];
  bool isInGetWay = false;

  @override
  void initState(){
    super.initState();

    assistCtr.addState(AssistController.state$loading);
    EventDispatcherService.attachFunction(EventDispatcher.appResume, onBackOfBankGetWay);

    requestTransaction();
  }

  @override
  void dispose(){
    requester.dispose();
    EventDispatcherService.deAttachFunction(EventDispatcher.appResume, onBackOfBankGetWay);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
        builder: (_, ctr, data){
          return Scaffold(
            body: SafeArea(
                child: buildBody()
            ),
          );
        }
    );
  }

  Widget buildBody(){
    if(assistCtr.hasState(AssistController.state$error)){
      return ErrorOccur(onRefresh: tryAgain);
    }

    if(assistCtr.hasState(AssistController.state$loading)){
      return WaitToLoad();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  //Image.asset(AppImages.watchIco, color: Colors.red),
                  Icon(AppIcons.wallet, color: Colors.red.withAlpha(200)),
                  SizedBox(width: 5),
                  Text('کیف پول').bold().fsR(1),
                ],
              ),

              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      visualDensity: VisualDensity(horizontal: 0, vertical: -3),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: StadiumBorder(),
                    ),
                      onPressed: gotoIncreaseAmount,
                      icon: Icon(AppIcons.addCircle, size: 15),
                      label: Text('افزایش اعتبار').fsR(-2).color(Colors.white)
                  ),

                  RotatedBox(
                    quarterTurns: 2,
                      child: BackButton()
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(
          height: 20,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: SizedBox(
            width: double.infinity,
            child: Card(
              elevation: 0,
              color: Colors.grey.shade200,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text('کل موجودی'),
                    SizedBox(height: 4),
                    Text('$walletBalance').fsR(5).bold(),

                    SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 0,
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.percent, size: 12, color: Colors.red),
                                    SizedBox(width: 4),
                                    Text('قابل برداشت'),
                                  ],
                                ),

                                Text('$withdrawalBalance تومان'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        SizedBox(
          height: 20,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(AppIcons.list),
              SizedBox(width: 5),
              Text('تراکنش ها').bold().fsR(3)
            ],
          ),
        ),

        SizedBox(
          height: 10,
        ),


        Expanded(
            child: Builder(
                builder: (_){
                  if(transactionList.isEmpty){
                    return EmptyData();
                  }

                  return ListView.builder(
                    itemCount: transactionList.length,
                    itemBuilder: listBuilderForTicket,
                  );
                }
            ),
        ),
      ],
    );
  }

  Widget listBuilderForTicket(_, idx){
    final transaction = transactionList[idx];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomCard(
                      radius: 0,
                        color: AppColors.greenTint,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(AppIcons.arrowDown, size: 14, color: AppColors.green),
                        )
                    ),
                    SizedBox(width: 5),
                    Text('واریز به حساب'),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1401/05/22'),
                    SizedBox(width: 5),
                    Icon(AppIcons.calendar, size: 13, color: Colors.black87),
                  ],
                ),
              ],
            ),

            SizedBox(height: 6),
            Divider(color: Colors.black38),
            SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  void tryAgain(){
    assistCtr.clearStates();
    assistCtr.addStateAndUpdateHead(AssistController.state$loading);
    requestTransaction();
  }

  void onBackOfBankGetWay({data}) {
    if(isInGetWay){
      isInGetWay = false;
      tryAgain();
    }
  }

  void gotoIncreaseAmount() async {
    final res = await AppSheet.showSheetCustom(
        context,
        builder: (ctx){
          return IncreaseAmountSheet();
        },
      routeName: 'IncreaseAmount',
      backgroundColor: Colors.transparent,
      contentColor: Colors.transparent,
      isScrollControlled: true,
    );

    if(res is int){
      requestInc(res);
    }
  }

  Future<void> requestTransaction() async {
    Completer co = Completer();

    requester.httpRequestEvents.onFailState = (req, res) async {
      assistCtr.clearStates();
      assistCtr.addStateAndUpdateHead(AssistController.state$error);
      co.complete(null);
    };

    requester.httpRequestEvents.onStatusOk = (req, dataJs) async {
      final data = dataJs['data'];
      final transactions = data['transactions']?? [];
      walletBalance = data['walletBalance']?? 0;

      transactionList.clear();

      for(final t in transactions){
        final tik = TransactionModel.fromMap(t);
        transactionList.add(tik);
      }

      co.complete(null);

      assistCtr.clearStates();
      assistCtr.updateHead();
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/wallet');
    requester.request(context);

    return co.future;
  }

  Future<void> requestInc(int amount) async {
    requester.httpRequestEvents.onFailState = (req, res) async {
      await hideLoading();

      String msg = 'خطایی رخ داده است';

      if(res != null && res.data != null){
        final js = JsonHelper.jsonToMap(res.data)?? {};

        msg = js['message']?? msg;
      }

      AppSnack.showInfo(context, msg);
    };

    requester.httpRequestEvents.onStatusOk = (req, dataJs) async {
      await hideLoading();
      final data = dataJs['data'];
      final url = data['url'];

      if(url != null){
        isInGetWay = true;

        await UrlHelper.launchLink(url, mode: LaunchMode.externalApplication);
      }
    };

    showLoading();
    requester.methodType = MethodType.post;
    requester.bodyJson = {'amount': amount};
    requester.prepareUrl(pathUrl: '/wallet/charge');
    requester.request(context);
  }
}
