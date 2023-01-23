import 'dart:async';

import 'package:app/structures/enums/transactionSectionFilter.dart';
import 'package:app/structures/enums/transactionStatusFilter.dart';
import 'package:app/structures/models/transactionModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/currencyTools.dart';
import 'package:app/tools/dateTools.dart';

import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:app/views/widgets/customCard.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/views/states/errorOccur.dart';


class TransactionsPage extends StatefulWidget {

  const TransactionsPage({Key? key}) : super(key: key);

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}
///========================================================================================
class _TransactionsPageState extends StateBase<TransactionsPage> {
  Requester requester = Requester();
  RefreshController refreshController = RefreshController(initialRefresh: false);
  int pageSize = 100;
  int pageIndex = 1;
  List<TransactionModel> transactionList = [];
  TransactionStatusFilter? statusFilter;
  TransactionSectionFilter? sectionFilter;
  String key$downArrangeSelected = 'downArrangeSelected';
  String key$upArrangeSelected = 'upArrangeSelected';

  @override
  void initState(){
    super.initState();

    assistCtr.addState(AssistController.state$loading);
    requestTransaction();
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
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(AppImages.transactionIco, height: 25),
                  SizedBox(width: 8),
                  Text('تراکنش ها').bold().fsR(3)
                ],
              ),


              Row(
                children: [
                  GestureDetector(
                    onTap: (){
                      int last = assistCtr.getValueOr(key$downArrangeSelected, 0);

                      if(last == 0){
                        assistCtr.setKeyValue(key$downArrangeSelected, 255);
                        assistCtr.setKeyValue(key$upArrangeSelected, 0);
                      }
                      else {
                        assistCtr.setKeyValue(key$downArrangeSelected, 0);
                      }

                      assistCtr.updateHead();
                    },
                    child: CustomCard(
                        radius: 0,
                        color: AppColors.redTint,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(AppIcons.arrowDown, size: 14, color: AppColors.red),
                        )
                    ).wrapBoxBorder(
                      radius: 0,
                      padding: EdgeInsets.zero,
                      alpha: assistCtr.getValueOr(key$downArrangeSelected, 0),
                    ),
                  ),


                  SizedBox(width: 8),

                  GestureDetector(
                    onTap: (){
                      int last = assistCtr.getValueOr(key$upArrangeSelected, 0);

                      if(last == 0){
                        assistCtr.setKeyValue(key$upArrangeSelected, 255);
                        assistCtr.setKeyValue(key$downArrangeSelected, 0);
                      }
                      else {
                        assistCtr.setKeyValue(key$upArrangeSelected, 0);
                      }

                      assistCtr.updateHead();
                    },
                    child: CustomCard(
                        radius: 0,
                        color: AppColors.redTint,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RotatedBox(
                              quarterTurns: 2,
                              child: Icon(AppIcons.arrowDown, size: 14, color: AppColors.green)
                          ),
                        )
                    ).wrapBoxBorder(
                      radius: 0,
                      padding: EdgeInsets.zero,
                      alpha: assistCtr.getValueOr(key$upArrangeSelected, 0),
                    ),
                  ),

                  SizedBox(width: 10),
                  RotatedBox(
                      quarterTurns: 2,
                      child: BackButton()
                  ),
                ],
              ),
            ],
          )
        ),

        SizedBox(
          height: 20,
        ),

        Expanded(
            child: Builder(
                builder: (_){
                  if(transactionList.isEmpty){
                    return EmptyData();
                  }

                  return RefreshConfiguration(
                    headerBuilder: () => MaterialClassicHeader(),
                    footerBuilder: () => PublicAccess.classicFooter,
                    enableScrollWhenRefreshCompleted: true,
                    enableLoadingWhenFailed : true,
                    hideFooterWhenNotFull: true,
                    enableBallisticLoad: true,
                    enableLoadingWhenNoData: false,
                    child: SmartRefresher(
                      enablePullDown: false,
                      enablePullUp: true,
                      controller: refreshController,
                      onRefresh: (){},
                      onLoading: onLoadingMore,
                      child: ListView.builder(
                        itemCount: transactionList.length,
                        itemBuilder: listBuilderForTransaction,
                      ),
                    ),
                  );
                }
            ),
        ),
      ],
    );
  }

  Widget listBuilderForTransaction(_, idx){
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
                        color: transaction.isAmountPlus()? AppColors.greenTint : AppColors.redTint,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Builder(
                              builder: (context) {
                                if(transaction.isAmountPlus()) {
                                  return RotatedBox(
                                      quarterTurns: 2,
                                      child: Icon(AppIcons.arrowDown, size: 14, color: AppColors.green)
                                  );
                                }

                                return Icon(AppIcons.arrowDown, size: 14, color: AppColors.red);
                              }
                          ),
                        )
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(CurrencyTools.formatCurrencyString(transaction.amount.toString().replaceFirst('-', ''))),
                        Text(transaction.getAmountHuman()).fsR(-2).color(transaction.isAmountPlus()? AppColors.green : AppColors.red),
                      ],
                    ),
                    SizedBox(width: 5),
                    //Text(transaction.getAmountHuman()),
                  ],
                ),

                Row(
                  children: [
                    Text(DateTools.dateAndHmRelative(transaction.date)).alpha(),
                    SizedBox(width: 5),
                    Icon(AppIcons.calendar, size: 13, color: Colors.black54),
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

  void onLoadingMore(){
    pageIndex++;
    requestTransaction();
  }

  Future<void> requestTransaction() async {
    Completer co = Completer();

    requester.httpRequestEvents.onFailState = (req, res) async {
      assistCtr.clearStates();
      assistCtr.addStateAndUpdateHead(AssistController.state$error);
      co.complete(null);
    };

    requester.httpRequestEvents.onStatusOk = (req, dataJs) async {
      final data = dataJs['data']?? [];
      pageIndex = dataJs['pageIndex']?? pageIndex;
      final hasNextPage = dataJs['hasNextPage']?? true;

      transactionList.clear();

      for(final t in data){
        final tik = TransactionModel.fromMap(t);
        transactionList.add(tik);
      }

      if(refreshController.isLoading) {
        refreshController.loadComplete();
      }

      if(!hasNextPage){
        refreshController.loadNoData();
      }

      co.complete(null);

      assistCtr.clearStates();
      assistCtr.updateHead();
    };

    String url = '/transactions?Page=$pageIndex&Size=$pageSize';

    if(statusFilter != null){
      url += '&Status=${statusFilter!.number}';
    }

    if(sectionFilter != null){
      url += '&Section=${sectionFilter!.number}';
    }

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: url);
    requester.request(context);

    return co.future;
  }
}
