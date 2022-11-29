import 'dart:async';

import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:app/pages/ticket_detail_page.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/structures/models/ticketModel.dart';
import 'package:app/structures/models/ticketRole.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/dateTools.dart';
import 'package:app/views/components/addTicketPage.dart';
import 'package:app/views/components/supportPlanPage.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  State<SupportPage> createState() => _SupportPageState();
}
///========================================================================================
class _SupportPageState extends StateBase<SupportPage> with SingleTickerProviderStateMixin {
  Requester requester = Requester();
  RefreshController refreshController = RefreshController(initialRefresh: false);
  late TabController tabCtr;
  late TextStyle tabBarStyle;
  int ticketPage = 1;
  List<TicketRole> ticketRoles = [];
  List<TicketModel> ticketList = [];

  @override
  void initState(){
    super.initState();

    tabCtr = TabController(length: 2, vsync: this);

    tabBarStyle = TextStyle(
      color: AppColors.red,
      fontWeight: FontWeight.w900
    );

    requestTickets();
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
        Row(
          children: [
            BackButton(),
          ],
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Stack(
            children: [
              Positioned(
                left:0,
                  right:0,
                  bottom: 0,
                  child: SizedBox(
                    height: 1,
                    child: ColoredBox(color: Colors.grey),
                  ),
              ),

              TabBar(
                controller: tabCtr,
                  indicatorColor: AppColors.red,
                  labelColor: Colors.yellow,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  tabs: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Text('جلسات', style: tabBarStyle),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Text('تیکت ها', style: tabBarStyle),
                    ),
                  ]),
            ],
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: TabBarView(
                controller: tabCtr,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  buildSessionPart(),
                  buildTicketPart(),
                ]
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSessionPart(){
    return LayoutBuilder(
      builder: (_, siz) {
        return SingleChildScrollView(
          child: SizedBox(
            height: siz.maxHeight,
            child: Column(
              children: [
                SizedBox(height: 30),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal:8.0, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(AppImages.watchIco),
                            SizedBox(width: 8),
                            Text('زمان باقی مانده\u200cی پشتیبانی')
                          ],
                        ),

                        Row(
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                              ),
                              child: Text('20')
                                  .wrapBoxBorder(
                                    radius: 2,
                                    padding: EdgeInsets.symmetric(horizontal:6, vertical: 4),
                                    color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(' دقیقه'),
                            SizedBox(
                              height: 30,
                              child: FloatingActionButton(
                                onPressed: showBuySessionTimeSheet,
                                backgroundColor: AppColors.red,
                                elevation: 0,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                child: Icon(AppIcons.add, size: 15, color: Colors.white),
                              ),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ).wrapDotBorder(
                      radius: 0,
                      stroke: 1.5,
                      color: Colors.grey,
                      padding: EdgeInsets.zero
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                      itemCount: 15,
                      shrinkWrap: true,
                      itemBuilder: listBuilderForSession
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  Widget listBuilderForSession(_, idx){
    return Padding(
        padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('عنوان درس'),

              Row(
                children: [
                  Text('2020/10/10'),
                  SizedBox(width: 5),
                  Icon(AppIcons.calendar, size: 14, color: Colors.grey.shade700),
                ],
              ),
            ],
          ),

          SizedBox(height: 6),
          Divider(color: Colors.grey.shade700),
          SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('موضوع'),

              DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withAlpha(40),
                    borderRadius: BorderRadius.circular(4)
                  ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2),
                  child: Text('10', style: TextStyle(color: Color(0xFF0ECF73), fontSize: 10)),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
  ///----------------------------------------------------
  Widget buildTicketPart(){
    return Column(
      children: [
        Expanded(
            child: RefreshConfiguration(
              headerBuilder: () => MaterialClassicHeader(),
              footerBuilder:  () => PublicAccess.classicFooter,
              //headerTriggerDistance: 80.0,
              //maxOverScrollExtent :100,
              //maxUnderScrollExtent:0,
              //springDescription: SpringDescription(stiffness: 170, damping: 16, mass: 1.9),
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
                onLoading: onLoadingMoreCall,
                child: ListView.builder(
                  itemCount: ticketList.length,
                  itemBuilder: listBuilderForTicket,
                ),
              ),
            )
        ),

        Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: showAddTicketSheet,
              child: Text('ایجاد تیکت'),
            ),
          ),
        ),
      ],
    );
  }

  Widget listBuilderForTicket(_, idx){
    final tik = ticketList[idx];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        AppRoute.push(context, TicketDetailPage(ticketModel: tik));
      },
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tik.title),

                Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                          color: Colors.greenAccent.withAlpha(40),
                          borderRadius: BorderRadius.circular(4)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2),
                        child: Text(tik.status == 1 ? 'باز' : 'بسته',
                            style: TextStyle(color: Color(0xFF0ECF73), fontSize: 10)
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Text(DateTools.dateOnlyRelative(tik.createdAt)),
                    SizedBox(width: 5),
                    Icon(AppIcons.calendar, size: 14, color: Colors.grey.shade700),
                  ],
                ),
              ],
            ),

            SizedBox(height: 6),
            Divider(color: Colors.grey.shade700),
            SizedBox(height: 2),
          ],
        ),
      ),
    );
  }

  void tryAgain(){

  }

  void showBuySessionTimeSheet(){
    AppSheet.showSheetCustom(
        context,
        builder: (_) => SupportPlanPage(),
        routeName: 'showBuySessionTimeSheet',
      isDismissible: true,
      isScrollControlled: true,
      contentColor: Colors.transparent,
      backgroundColor: Colors.transparent,
    );
  }

  void showAddTicketSheet() async {
    showLoading();
    await requestRoles();
    await hideLoading();

    if(ticketRoles.isEmpty){
      AppSnack.showError(context, 'متاسفانه خطایی رخ داده است');
      return;
    }

    AppSheet.showSheetCustom(
      context,
      builder: (_) => AddTicketPage(ticketRoles: ticketRoles),
      routeName: 'showAddTicketSheet',
      isDismissible: true,
      isScrollControlled: true,
      contentColor: Colors.transparent,
      backgroundColor: Colors.transparent,
    );
  }

  void tryLoadClick() async {
    assistCtr.addStateAndUpdate(AssistController.state$loading);

    requestTickets();
  }

  void onLoadingMoreCall(){
    ticketPage++;
    requestTickets();
  }

  Future<void> requestRoles() async {
    ticketRoles.clear();
    Completer co = Completer();

    requester.httpRequestEvents.onFailState = (req, res) async {
      co.complete(null);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final data = res['data'];

      if(data is List){
        for(final t in data){
          final tr = TicketRole.fromMap(t);
          ticketRoles.add(tr);
        }
      }

      co.complete(null);
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/roles');
    requester.request(context);

    return co.future;
  }

  Future<void> requestTickets() async {
    ticketRoles.clear();
    Completer co = Completer();

    requester.httpRequestEvents.onFailState = (req, res) async {
      co.complete(null);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final data = res['data'];
      final hasNextPage = res['hasNextPage']?? true;
      ticketPage = res['pageIndex']?? ticketPage;

      if(data is List){
        for(final t in data){
          final tik = TicketModel.fromMap(t);
          ticketList.add(tik);
        }
      }

      if(refreshController.isLoading) {
        refreshController.loadComplete();
      }

      if(!hasNextPage){
        refreshController.loadNoData();
      }
      co.complete(null);

      assistCtr.updateMain();
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/tickets?Page=$ticketPage');
    requester.request(context);

    return co.future;
  }
}
