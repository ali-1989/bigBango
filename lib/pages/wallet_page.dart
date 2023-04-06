import 'dart:async';

import 'package:app/structures/enums/appEventDispatcher.dart';
import 'package:flutter/material.dart';
import 'package:iris_notifier/iris_notifier.dart';

import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/urlHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:app/pages/profile_page.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/transactionWalletModel.dart';
import 'package:app/structures/models/withdrawalModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/currencyTools.dart';
import 'package:app/tools/dateTools.dart';
import 'package:app/views/sheets/incraseAmountComponent.dart';
import 'package:app/views/sheets/wallet@withdrawaSheet.dart';
import 'package:app/views/sheets/wallet@withdrawalListSheet.dart';
import 'package:app/views/states/backBtn.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:iris_tools/widgets/customCard.dart';

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
  List<TransactionWalletModel> transactionList = [];
  List<WithdrawalModel> withdrawalList = [];
  bool isInPayGetway = false;

  @override
  void initState(){
    super.initState();

    assistCtr.addState(AssistController.state$loading);
    EventNotifierService.addListener(EventDispatcher.appResume, onBackOfBankGetWay);

    requestTransaction();
  }

  @override
  void dispose(){
    requester.dispose();
    EventNotifierService.removeListener(EventDispatcher.appResume, onBackOfBankGetWay);

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
      return ErrorOccur(onTryAgain: tryAgain, backButton: BackBtn());
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
                    Text(CurrencyTools.formatCurrency(walletBalance)).fsR(5).bold(),

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
                                    //Icon(Icons.percent, size: 12, color: Colors.red),
                                    //SizedBox(width: 4),
                                    Text('قابل برداشت'),
                                  ],
                                ),

                                Text('${CurrencyTools.formatCurrency(withdrawalBalance)} تومان'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        children: [
                          Visibility(
                            visible: withdrawalBalance > 0,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity(vertical: -4, horizontal: -2)
                              ),
                                onPressed: showWithdrawalSheet,
                                child: Text('درخواست برداشت').fsR(-3).color(Colors.blue)
                            ),
                          ),

                          Builder(
                              builder: (_){
                                if(withdrawalList.isEmpty){
                                  return SizedBox();
                                }

                                return Row(
                                  children: [
                                    Visibility(
                                      visible: withdrawalBalance > 0,
                                        child: Text('/')
                                    ),

                                    TextButton(
                                        style: TextButton.styleFrom(
                                            visualDensity: VisualDensity(vertical: -4, horizontal: -2)
                                        ),
                                        onPressed: showWithdrawalListSheet,
                                        child: Text('درخواست های در حال بررسی').fsR(-3).color(Colors.blue)
                                    ),
                                  ],
                                );
                              }
                          )
                        ],
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
                    itemBuilder: listBuilderForTransaction,
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
              mainAxisAlignment: MainAxisAlignment.start,
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

                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(CurrencyTools.formatCurrencyString(transaction.amount.toString().replaceFirst('-', ''))),
                          Text(transaction.getAmountHuman()).fsR(-2).color(transaction.isAmountPlus()? AppColors.green : AppColors.red),
                          SizedBox(height: 5),
                          Text(transaction.description?? '').fsR(-2).alpha(),
                        ],
                      ),
                      SizedBox(width: 5),
                      //Text(transaction.getAmountHuman()),
                    ],
                  ),
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

  void onBackOfBankGetWay({data}) {
    if(isInPayGetway){
      isInPayGetway = false;
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

  void showWithdrawalSheet() async {
    if(Session.getLastLoginUser()!.iban == null){
      void fn(){
        RouteTools.pushPage(context, ProfilePage(userModel: Session.getLastLoginUser()!));
      }

      AppSheet.showSheetOneAction(context, 'ابتدا باید شماره شبای متعلق به خود را در بخش پروفایل وارد کنید', fn, buttonText: 'پروفایل');
      return;
    }

    final amount = await AppSheet.showSheetCustom(
        context, builder: (_){
          return WalletWithdrawalSheet(maxAmount: withdrawalBalance);
    },
      routeName: 'withdrawalSheetDialog',
      contentColor: Colors.transparent,
      isScrollControlled: true,
    );

    if(amount is int){
      requestWithdrawal(amount);
    }
  }

  void showWithdrawalListSheet() async {
    await AppSheet.showSheetCustom(
        context, builder: (_){
          return WalletWithdrawalListSheet(withdrawalList: withdrawalList);
    },
        routeName: 'showWithdrawalListSheet',
      contentColor: Colors.transparent,
      isScrollControlled: true,
    );

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
      final data = dataJs['data'];
      final transactions = data['transactions']?? [];
      final withdrawalRequests = data['withdrawalRequests']?? [];
      walletBalance = data['walletBalance']?? 0;
      withdrawalBalance = data['withdrawalBalance']?? 0;

      transactionList.clear();
      withdrawalList.clear();

      for(final t in transactions){
        final tik = TransactionWalletModel.fromMap(t);
        transactionList.add(tik);
      }

      for(final t in withdrawalRequests){
        final tik = WithdrawalModel.fromMap(t);
        withdrawalList.add(tik);
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
        isInPayGetway = true;
        await UrlHelper.launchLink(url, mode: LaunchMode.externalApplication);
      }
    };

    showLoading();
    requester.methodType = MethodType.post;
    requester.bodyJson = {'amount': amount};
    requester.prepareUrl(pathUrl: '/wallet/charge');
    requester.request(context);
  }

  Future<void> requestWithdrawal(int amount) async {
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
      String msg = 'نتیجه پس از بررسی اعلام می شود';

      msg = data['message']?? msg;

      AppSnack.showInfo(context, msg);
      requestTransaction();
    };

    showLoading();
    requester.methodType = MethodType.post;
    requester.bodyJson = {'amount': amount};
    requester.prepareUrl(pathUrl: '/wallet/withdrawal');
    requester.request(context);
  }
}
