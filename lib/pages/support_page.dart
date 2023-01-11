import 'dart:async';

import 'package:app/services/pages_event_service.dart';
import 'package:app/structures/enums/supportSessionStatus.dart';
import 'package:app/structures/models/supportModels/supportSessionModel.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:app/pages/ticket_detail_page.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/structures/models/ticketModels/ticketModel.dart';
import 'package:app/structures/models/ticketModels/ticketRole.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/dateTools.dart';
import 'package:app/views/components/addTicketComponent.dart';
import 'package:app/views/components/supportPlanPage.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';

class SupportPage extends StatefulWidget {
  static final pageEventId = 'SupportPageEvent';
  static final eventFnId$addTicket = 'eventIdAddTicket';

  const SupportPage({Key? key}) : super(key: key);

  @override
  State<SupportPage> createState() => _SupportPageState();
}
///========================================================================================
class _SupportPageState extends StateBase<SupportPage> with SingleTickerProviderStateMixin {
  Requester requester = Requester();
  RefreshController timetableRefreshController = RefreshController(initialRefresh: false);
  RefreshController ticketRefreshController = RefreshController(initialRefresh: false);
  late TabController tabCtr;
  late TextStyle tabBarStyle;
  int ticketPage = 1;
  int timetablePage = 1;
  List<TicketRole> ticketRoles = [];
  List<TicketModel> ticketList = [];
  List<SupportSessionModel> sessionList = [];
  String assistId$Timetable = 'assistId_Timetable';
  String assistId$Ticketing = 'assistId_Ticketing';

  @override
  void initState(){
    super.initState();

    assistCtr.addState(AssistController.state$loading, sectionId: assistId$Timetable);
    assistCtr.addState(AssistController.state$loading, sectionId: assistId$Ticketing);

    tabCtr = TabController(length: 2, vsync: this);

    tabBarStyle = TextStyle(
      color: AppColors.red,
      fontWeight: FontWeight.w900
    );

    requestTimeTable();
    requestTickets();
  }

  @override
  void dispose(){
    requester.dispose();
    PagesEventService.removeFor(SupportPage.pageEventId);

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
      return ErrorOccur();
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
    return Assist(
        controller: assistCtr,
        id: assistId$Timetable,
        builder: (_, ctr, data){
          if(assistCtr.hasState(AssistController.state$loading, sectionId: assistId$Timetable)){
            return WaitToLoad();
          }

          return Column(
            children: [
              SizedBox(height: 20),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal:8.0, vertical: 14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(AppImages.watchIco),
                              SizedBox(width: 8),
                              Text(' باقی مانده\u200cی زمان پشتیبانی شما', maxLines: 1, overflow: TextOverflow.clip)
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
                              /*SizedBox(
                                height: 30,
                                child: FloatingActionButton(
                                  onPressed: showBuySessionTimeSheet,
                                  backgroundColor: AppColors.red,
                                  elevation: 0,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  child: Icon(AppIcons.add, size: 15, color: Colors.white),
                                ),
                              ),*/

                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ActionChip(
                            label: Text('درخواست پشتیبانی'),
                            onPressed: showBuySessionTimeSheet,
                            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),

                          ActionChip(
                            label: Text('خرید زمان'),
                            onPressed: showBuySessionTimeSheet,
                            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                  child: Builder(
                      builder: (ctx){
                        if(sessionList.isEmpty){
                          return EmptyData(message: 'موردی ثبت نشده',);
                        }

                        return RefreshConfiguration(
                          headerBuilder: () => MaterialClassicHeader(),
                          footerBuilder: () => PublicAccess.classicFooter,
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
                            controller: timetableRefreshController,
                            onRefresh: (){},
                            onLoading: onLoadingMoreTimetableCall,
                            child: ListView.builder(
                              itemCount: sessionList.length,
                              itemBuilder: listBuilderForSession,
                            ),
                          ),
                        );
                      }
                  ),
              ),
            ],
          );
        }
    );
  }

  Widget listBuilderForSession(_, idx){
    final model = sessionList[idx];

    return Padding(
        padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(model.lesson?.title?? 'عمومی', maxLines: 1)
              ),

              Row(
                children: [
                  Text(DateTools.dateAndHmRelative(model.reservationAt, isUtc: false)),
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
              Expanded(
                  child: Text(model.subject, maxLines: 1)
              ),

              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                        color: model.status.getStateColor(),
                        borderRadius: BorderRadius.circular(4)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2),
                      child: Text(model.status.getState(), style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ),

                  SizedBox(width: 10,),

                  DecoratedBox(
                    decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(40),
                        borderRadius: BorderRadius.circular(4)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2),
                      child: Text(LocaleHelper.embedLtr('${model.durationMinutes} \u{2032}'),
                          style: TextStyle(color: AppColors.red, fontSize: 10)
                      ),
                    ),
                  ),

                  Visibility(
                    visible: model.status == SupportSessionStatus.inProgress,
                      child: IconButton(
                        iconSize: 17,
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        constraints: BoxConstraints.tightFor(),
                        splashRadius: 12,
                        style: IconButton.styleFrom(
                          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: Icon(AppIcons.delete, size: 17, color: Colors.red),
                        onPressed: (){
                          unReserve(model);
                        },
                      )
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  ///-------------------------------------------------------------------------
  Widget buildTicketPart(){
    return Assist(
        controller: assistCtr,
        id: assistId$Ticketing,
        builder: (_, ctr, data){
          if(assistCtr.hasState(AssistController.state$loading, sectionId: assistId$Ticketing)){
            return WaitToLoad();
          }

          return Column(
            children: [
              Expanded(
                  child: RefreshConfiguration(
                    headerBuilder: () => MaterialClassicHeader(),
                    footerBuilder: () => PublicAccess.classicFooter,
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
                      controller: ticketRefreshController,
                      onRefresh: (){},
                      onLoading: onLoadingMoreTicketsCall,
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
                          color: tik.status == 1 ? AppColors.greenTint : AppColors.redTint,
                          borderRadius: BorderRadius.circular(4)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
                        child: Text(tik.status == 1 ? 'باز' : 'بسته',
                            style: TextStyle(color: tik.status == 1 ? AppColors.green : Colors.red, fontSize: 10)
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('تیکت شماره : ${tik.number}').alpha(),
                Text(tik.trackingRoleName).alpha(),
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
  ///\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
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
      builder: (_) => AddTicketComponent(ticketRoles: ticketRoles),
      routeName: 'showAddTicketSheet',
      isScrollControlled: true,
      contentColor: Colors.transparent,
      backgroundColor: Colors.transparent,
    );

    PagesEventService.getEventBus(SupportPage.pageEventId).addEvent(SupportPage.eventFnId$addTicket, onAddTicketEventCall);
  }

  void onAddTicketEventCall(param){
    ticketList.add(param);

    ticketList.sort((e1, e2){
      return DateHelper.compareDates(e1.createdAt, e2.createdAt, asc: false);
    });

    assistCtr.updateHead();
  }

  void tryLoadTimetable() async {
    assistCtr.clearStates(sectionId: assistId$Timetable);
    assistCtr.addStateAndUpdateAssist(AssistController.state$loading, assistId$Timetable);

    requestTimeTable();
  }

  void tryLoadTickets() async {
    assistCtr.clearStates(sectionId: assistId$Ticketing);
    assistCtr.addStateAndUpdateAssist(AssistController.state$loading, assistId$Ticketing);

    requestTickets();
  }

  void onLoadingMoreTimetableCall(){
    timetablePage++;
    requestTimeTable();
  }

  void onLoadingMoreTicketsCall(){
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

  Future<void> requestTimeTable() async {
    Completer co = Completer();
    Requester requester = Requester();

    requester.httpRequestEvents.onAnyState = (req) async {
      requester.dispose();
    };

    requester.httpRequestEvents.onFailState = (req, res) async {
      if(res?.data != null){
        final map = JsonHelper.jsonToMap(res?.data)?? {};

        final message = map['message'];

        if(message != null){
          AppSnack.showInfo(context, message);
          co.complete(null);
          return;
        }
      }

      AppToast.showToast(context, 'ارتباط با سرور برقرار نشد');
      co.complete(null);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      await Future.delayed(Duration(seconds: 5));
      if(!mounted){
        return;
      }
      final data = res['data'];

      final hasNextPage = res['hasNextPage']?? true;
      ticketPage = res['pageIndex']?? ticketPage;

      if(data is List){
        for(final t in data){
          final tik = SupportSessionModel.fromMap(t);
          sessionList.add(tik);
        }
      }

      if(timetableRefreshController.isLoading) {
        timetableRefreshController.loadComplete();
      }

      if(!hasNextPage){
        timetableRefreshController.loadNoData();
      }

      co.complete(null);

      assistCtr.clearStates(sectionId: assistId$Timetable);
      assistCtr.updateAssist(assistId$Timetable);
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/appointments?Page=$timetablePage');//&size=200&keyword=
    requester.request(context);

    return co.future;
  }

  Future<void> requestTickets() async {
    Completer co = Completer();
    Requester requester = Requester();

    requester.httpRequestEvents.onAnyState = (req) async {
      requester.dispose();
    };

    requester.httpRequestEvents.onFailState = (req, res) async {
      if(res?.data != null){
        final map = JsonHelper.jsonToMap(res?.data)!;

        final message = map['message'];

        if(message != null){
          AppSnack.showInfo(context, message);
          co.complete(null);
          return;
        }
      }

      AppToast.showToast(context, 'ارتباط با سرور برقرار نشد');
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

      ticketList.sort((e1, e2){
        return DateHelper.compareDates(e1.createdAt, e2.createdAt, asc: false);
      });

      if(ticketRefreshController.isLoading) {
        ticketRefreshController.loadComplete();
      }

      if(!hasNextPage){
        ticketRefreshController.loadNoData();
      }

      co.complete(null);

      assistCtr.clearStates(sectionId: assistId$Ticketing);
      assistCtr.updateAssist(assistId$Ticketing);
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/tickets?Page=$ticketPage');
    requester.request(context);

    return co.future;
  }

  void unReserve(SupportSessionModel model) {
    void fn(){

    }

    AppDialogIris.instance.showYesNoDialog(
        context,
      yesFn: fn,
      desc: 'آیا می خواهید درخواست را لغو کنید؟'
    );
  }
}
