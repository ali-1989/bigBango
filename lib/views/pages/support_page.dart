import 'dart:async';

import 'package:flutter/material.dart';

import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_runtime_cache/iris_runtime_cache.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:app/managers/api_manager.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/appStoreScope.dart';
import 'package:app/structures/enums/app_events.dart';
import 'package:app/structures/enums/supportSessionStatus.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/supportModels/supportPlanModel.dart';
import 'package:app/structures/models/supportModels/supportSessionModel.dart';
import 'package:app/structures/models/ticketModels/ticketModel.dart';
import 'package:app/structures/models/ticketModels/ticketRole.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_dialog_iris.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/tools/date_tools.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/pages/ticket_detail_page.dart';
import 'package:app/views/pages/timetable_page.dart';
import 'package:app/views/sheets/addTicketSheet.dart';
import 'package:app/views/sheets/support@selectBuyMethodSheet.dart';
import 'package:app/views/sheets/supportPlanSheet.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';

class SupportPage extends StatefulWidget {

  const SupportPage({Key? key}) : super(key: key);

  @override
  State<SupportPage> createState() => _SupportPageState();
}
///========================================================================================
class _SupportPageState extends StateSuper<SupportPage> with SingleTickerProviderStateMixin {
  Requester requester = Requester();
  RefreshController timetableRefreshController = RefreshController(initialRefresh: false);
  RefreshController ticketRefreshController = RefreshController(initialRefresh: false);
  late TabController tabCtr;
  late TextStyle tabBarStyle;
  int ticketPage = 1;
  int timetablePage = 1;
  int? userTime;
  bool isInGetWay = false;
  List<TicketRole> ticketRoles = [];
  List<TicketModel> ticketList = [];
  List<SupportSessionModel> sessionList = [];
  String assistId$Timetable = 'assistId_Timetable';
  String assistId$Ticketing = 'assistId_Ticketing';
  String assistId$userLeftTime = 'assistId_userLeftTime';

  @override
  void initState(){
    super.initState();

    EventNotifierService.addListener(AppEvents.appResume, onBackOfBankGetWay);

    assistCtr.addStateTo(state: AssistController.state$loading, scopeId: assistId$Timetable);
    assistCtr.addStateTo(state: AssistController.state$loading, scopeId: assistId$Ticketing);
    assistCtr.addStateTo(state: AssistController.state$loading, scopeId: assistId$userLeftTime);

    tabCtr = TabController(length: 2, vsync: this);

    tabBarStyle = const TextStyle(
      color: AppDecoration.red,
      fontWeight: FontWeight.w900
    );

    requestTimeTable();
    requestTickets();
    requestUserLeftTime();
  }

  @override
  void dispose(){
    EventNotifierService.removeListener(AppEvents.appResume, onBackOfBankGetWay);
    DataNotifierService.removeListener(AppBroadcast.addTicketNotifier, onAddTicketEventCall);
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
      return ErrorOccur();
    }

    return Column(
      children: [
        const Row(
          textDirection: TextDirection.ltr,
          children: [
            RotatedBox(
              quarterTurns: 2,
                child: BackButton()
            ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Stack(
            children: [
              const Positioned(
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
                  indicatorColor: AppDecoration.red,
                  labelColor: Colors.red,
                  unselectedLabelColor: Colors.grey,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  tabs: const [
                    Padding(
                      padding: EdgeInsets.only(bottom: 6.0),
                      child: Text('جلسات'),
                    ),

                    Padding(
                      padding: EdgeInsets.only(bottom: 6.0),
                      child: Text('تیکت ها'),
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
                physics: const NeverScrollableScrollPhysics(),
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
          if(assistCtr.hasState(AssistController.state$loading, scopeId: assistId$Timetable)){
            return const WaitToLoad();
          }

          return Column(
            children: [
              const SizedBox(height: 20),
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
                              const SizedBox(width: 8),
                              const Text(' باقی مانده\u200cی زمان پشتیبانی شما', maxLines: 1, overflow: TextOverflow.clip).fsR(-1)
                            ],
                          ),

                          Row(
                            children: [
                              Assist(
                                  id: assistId$userLeftTime,
                                  controller: assistCtr,
                                  builder: (_, __, data){
                                    if(userTime != null){
                                      return DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                          ),
                                          child: Text('$userTime')
                                            .wrapBoxBorder(
                                          radius: 2,
                                          padding: const EdgeInsets.symmetric(horizontal:6, vertical: 4),
                                          color: Colors.grey.shade600,
                                        ),
                                      );
                                    }

                                    if(assistCtr.hasState(scopeId: assistId$userLeftTime, AssistController.state$loading)){
                                      return const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      );
                                    }

                                    return IconButton(
                                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                        padding: EdgeInsets.zero,
                                        iconSize: 17,
                                        splashRadius: 20,
                                        constraints: const BoxConstraints.tightFor(),
                                        onPressed: (){
                                          assistCtr.clearStates(scopeId: assistId$userLeftTime);
                                          assistCtr.addStateTo(state: AssistController.state$loading, scopeId: assistId$userLeftTime);
                                          assistCtr.updateAssist(assistId$userLeftTime);
                                          requestUserLeftTime();
                                        },
                                        icon: const Icon(AppIcons.refreshCircle, size: 17, color: AppDecoration.red)
                                    );
                                }
                              ),
                              const SizedBox(width: 4),
                              const Text(' دقیقه'),
                              /*SizedBox(
                                height: 30,
                                child: FloatingActionButton(
                                  onPressed: showBuySessionTimeSheet,
                                  backgroundColor: AppDecoration.red,
                                  elevation: 0,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  child: Icon(AppIcons.add, size: 15, color: Colors.white),
                                ),
                              ),*/

                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ActionChip(
                            label: const Text('درخواست پشتیبانی'),
                            onPressed: gotoSupportTimeRequestPage,
                            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),

                          ActionChip(
                            label: const Text('خرید زمان'),
                            onPressed: showBuySessionTimeSheet,
                            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
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
              const SizedBox(height: 10),

              Expanded(
                  child: Builder(
                      builder: (ctx){
                        if(sessionList.isEmpty){
                          return const EmptyData(message: 'موردی ثبت نشده',);
                        }

                        return RefreshConfiguration(
                          headerBuilder: () => const MaterialClassicHeader(),
                          footerBuilder: () => AppDecoration.classicFooter,
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
        padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(model.lesson?.title?? 'عمومی', maxLines: 1).alpha()
              ),

              Row(
                children: [
                  const SizedBox(width: 4),
                  DecoratedBox(
                    decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(40),
                        borderRadius: BorderRadius.circular(4)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2),
                      child: Text(LocaleHelper.embedLtr('${model.durationMinutes} \u{2032}'),
                          style: const TextStyle(color: AppDecoration.red, fontSize: 10)
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),
                  Text(DateTools.hmOnlyRelative(model.reservationAt, isUtc: false)),
                  const SizedBox(width: 6),
                  Text(DateTools.dateOnlyRelative(model.reservationAt, isUtc: false)).alpha(),
                  const SizedBox(width: 5),
                  Icon(AppIcons.calendar, size: 14, color: Colors.grey.shade700),
                ],
              ),
            ],
          ),

          const SizedBox(height: 6),
          Divider(color: Colors.grey.shade500),
          const SizedBox(height: 6),

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
                      child: Text(model.status.getTypeHuman(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Visibility(
                    visible: model.status == SupportSessionStatus.inProgress,
                      child: IconButton(
                        iconSize: 17,
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        constraints: const BoxConstraints.tightFor(),
                        splashRadius: 12,
                        style: IconButton.styleFrom(
                          visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(AppIcons.remove, size: 17, color: Colors.red),
                        onPressed: (){
                          showUnReserveDialog(model);
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
          if(assistCtr.hasState(AssistController.state$loading, scopeId: assistId$Ticketing)){
            return const WaitToLoad();
          }

          return Column(
            children: [
              Expanded(
                  child: Builder(
                    builder: (context) {
                      if(ticketList.isEmpty){
                        return const EmptyData(message: 'موردی ثبت نشده',);
                      }

                      return RefreshConfiguration(
                        headerBuilder: () => const MaterialClassicHeader(),
                        footerBuilder: () => AppDecoration.classicFooter,
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
                      );
                    }
                  )
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: showAddTicketSheet,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical:15.0),
                      child: const Text('ایجاد تیکت').fsR(-1),
                    ),
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
      onTap: () async {
        await RouteTools.pushPage(context, TicketDetailPage(ticketModel: tik, ticketId: tik.id));
        assistCtr.updateHead();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal:10, vertical: 15),
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
                          color: tik.status == 1 ? AppDecoration.greenTint : AppDecoration.redTint,
                          borderRadius: BorderRadius.circular(4)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
                        child: SizedBox(
                          width: 25,
                          child: Text(tik.status == 1 ? 'باز' : 'بسته',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: tik.status == 1 ? AppDecoration.green : Colors.red, fontSize: 10)
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),
                    Text(DateTools.dateOnlyRelative(tik.createdAt)),
                    const SizedBox(width: 5),
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
            const SizedBox(height: 6),
            Divider(color: Colors.grey.shade700),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
  ///-------------------------------------------------------------------------
  void gotoSupportTimeRequestPage() async {
    if(userTime == null){
      IrisRuntimeCache.resetUpdateTime(AppStoreScope.user$supportTime, SessionService.getLastLoginUser()!.userId);
      await requestUserLeftTime();

      if(userTime == null){
        AppSnack.showSnackText(context, AppMessages.operationFailed);
        return;
      }
    }

    final page = TimetablePage(maxUserTime: userTime!);

    final mustUpdate = await RouteTools.pushPage(context, page);

    if(mustUpdate is bool && mustUpdate){
      assistCtr.addStateTo(state: AssistController.state$loading, scopeId: assistId$Timetable);
      assistCtr.updateAssist(assistId$Timetable);

      requestTimeTable();
    }
  }

  void showBuySessionTimeSheet() async {
    final js = await requestSupportTimePlans();

    if(js == null){
      return;
    }

    List<SupportPlanModel> pList = [];

    for(final t in js){
      final p = SupportPlanModel.fromMap(t);
      pList.add(p);
    }

    final res = await AppSheet.showSheetCustom(
        context,
        builder: (_) => SupportPlanSheet(planList: pList),
        routeName: 'buySessionTimeSheet',
      isDismissible: true,
      isScrollControlled: true,
      contentColor: Colors.transparent,
      backgroundColor: Colors.transparent,
    );

    if(res is Map){
      showSelectPaymentMethodSheet(res['amount'], res['minutes'], res['planId']);
    }
  }

  void showSelectPaymentMethodSheet(int amount, int minutes, String? planId) async {
    showLoading();
    final balance = await ApiManager.requestUserBalance();
    await hideLoading();

    if(balance == null){
      AppSnack.showError(context, 'متاسفانه خطایی رخ داده است');
      return;
    }

    final mustUpdate = await AppSheet.showSheetCustom(
      context,
      builder: (_) => SelectBuyMethodSheet(userBalance: balance, amount: amount, minutes: minutes, planId: planId),
      routeName: 'showSelectBuyMethodSheet',
      isScrollControlled: true,
      contentColor: Colors.transparent,
      backgroundColor: Colors.transparent,
    );

    if(mustUpdate is bool && mustUpdate){
      IrisRuntimeCache.resetUpdateTime(AppStoreScope.user$supportTime, SessionService.getLastLoginUser()!.userId);
      requestUserLeftTime();
    }
    else {
      isInGetWay = true;
    }
  }

  void onBackOfBankGetWay({data}) {
    if(isInGetWay){
      isInGetWay = false;
      IrisRuntimeCache.resetUpdateTime(AppStoreScope.user$supportTime, SessionService.getLastLoginUser()!.userId);
      requestUserLeftTime();
    }
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
      builder: (_) => AddTicketSheet(ticketRoles: ticketRoles),
      routeName: 'showAddTicketSheet',
      isScrollControlled: true,
      contentColor: Colors.transparent,
      backgroundColor: Colors.transparent,
    );

    DataNotifierService.addListener(AppBroadcast.addTicketNotifier, onAddTicketEventCall);
  }

  void onAddTicketEventCall(ticketModel){
    /*ticketList.add(param);

    ticketList.sort((e1, e2){
      return DateHelper.compareDates(e1.createdAt, e2.createdAt, asc: false);
    });*/

    tryLoadTickets();
  }

  void tryLoadTimetable() async {
    assistCtr.clearStatesFrom(assistId$Timetable);
    assistCtr.addStateAndUpdateAssist(AssistController.state$loading, assistId$Timetable);

    requestTimeTable();
  }

  void tryLoadTickets() async {
    assistCtr.clearStatesFrom(assistId$Ticketing);
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

  void showUnReserveDialog(SupportSessionModel model) {
    bool fn(ctx){
      requestUnReserveTime(model);
      return false;
    }

    AppDialogIris.instance.showYesNoDialog(
        context,
        yesFn: fn,
        desc: 'آیا می خواهید درخواست را لغو کنید؟'
    );
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
    requester.request();

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
      await Future.delayed(const Duration(seconds: 5));
      if(!mounted){
        return;
      }
      final data = res['data'];

      final hasNextPage = res['hasNextPage']?? true;
      ticketPage = res['pageIndex']?? ticketPage;

      sessionList.clear();

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

      assistCtr.clearStatesFrom(assistId$Timetable);
      assistCtr.updateAssist(assistId$Timetable);
    };

    requester.methodType = MethodType.get;
    ///&keyword=
    requester.prepareUrl(pathUrl: '/appointments?Page=$timetablePage&status=1&size=200');
    requester.request();

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

      ticketList.clear();

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

      assistCtr.clearStatesFrom(assistId$Ticketing);
      assistCtr.updateAssist(assistId$Ticketing);
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/tickets?Page=$ticketPage');
    requester.request();

    return co.future;
  }

  Future<void> requestUserLeftTime() async {
    final rt = IrisRuntimeCache.find(AppStoreScope.user$supportTime, SessionService.getLastLoginUser()!.userId);

    if(rt != null && rt.isUpdate()){
      userTime = rt.value;
    }
    else {
      userTime = await ApiManager.requestUserRemainingMinutes(SessionService.getLastLoginUser()!.userId);
    }

    assistCtr.clearStatesFrom(assistId$userLeftTime);

    if(userTime == null){
      assistCtr.addStateTo(state: AssistController.state$error, scopeId: assistId$userLeftTime);
    }

    assistCtr.updateAssist(assistId$userLeftTime);
  }

  Future<List?> requestSupportTimePlans() async {
    final co = Completer<List?>();
    final requester = Requester();

    requester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
      requester.dispose();
    };

    requester.httpRequestEvents.onFailState = (req, res) async {
      String msg = 'خطایی رخ داده است';

      if(res != null && res.data != null){
        final js = JsonHelper.jsonToMap(res.data)?? {};

        msg = js['message']?? msg;
      }

      AppSnack.showInfo(context, msg);
      co.complete(null);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final data = res['data'];

      co.complete(data);
    };

    showLoading();
    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/shop/supportPackages');
    requester.request();

    return co.future;
  }

  void requestUnReserveTime(SupportSessionModel sModel) async {
    requester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, res) async {
      String msg = 'خطایی رخ داده است';

      if(res != null && res.data != null){
        final js = JsonHelper.jsonToMap(res.data)?? {};

        msg = js['message']?? msg;
      }

      AppSnack.showInfo(context, msg);
    };

    requester.httpRequestEvents.onStatusOk = (req, jdData) async {
      sessionList.remove(sModel);
      assistCtr.updateHead();

      String msg = jdData['message']?? 'لغو شد';
      AppSnack.showInfo(context, msg);
    };

    showLoading();
    requester.methodType = MethodType.delete;
    requester.bodyJson = {'id': sModel.id};
    requester.prepareUrl(pathUrl: '/appointments/cancel');
    requester.request();
  }
}
