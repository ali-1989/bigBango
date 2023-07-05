import 'dart:async';

import 'package:app/managers/api_manager.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:flutter/material.dart';

import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_runtime_cache/iris_runtime_cache.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/api/helpers/textHelper.dart';
import 'package:iris_tools/dateSection/ADateStructure.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/enums/appEvents.dart';
import 'package:app/structures/enums/appStoreScope.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/hoursOfSupportModel.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:app/structures/models/supportModels/dayWeekModel.dart';
import 'package:app/structures/models/supportModels/supportPlanModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/services/session_service.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/sheets/support@selectBuyMethodSheet.dart';
import 'package:app/views/sheets/supportPlanSheet.dart';
import 'package:app/views/sheets/timetable@confirmRequestSupport.dart';

class TimetablePage extends StatefulWidget {
  final LessonModel? lesson;
  final int maxUserTime;

  const TimetablePage({
    Key? key,
    this.lesson,
    required this.maxUserTime,
  }) : super(key: key);

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}
///==============================================================================================
class _TimetablePageState extends StateBase<TimetablePage> {
  Requester requester = Requester();
  ScrollController srcCtr = ScrollController();
  TextEditingController titleCtr = TextEditingController();
  TextEditingController timeCtr = TextEditingController();
  List<HoursOfSupportModel> dayHourList = [];
  List<DayWeekModel> days = [];
  int currentDay = 0;
  int maxUserTime = 0;
  String timeSelectId = '';
  bool isInGetWay = false;

  @override
  void initState(){
    super.initState();

    EventNotifierService.addListener(AppEvents.appResume, onBackOfBankGetWay);
    maxUserTime = widget.maxUserTime;
  }

  @override
  void dispose(){
    requester.dispose();
    EventNotifierService.removeListener(AppEvents.appResume, onBackOfBankGetWay);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
        builder: (_, ctr, data){
          return Scaffold(
            body: buildBody(),
          );
        }
    );
  }

  Widget buildBody(){
    return Column(
      children: [
        const SizedBox(height: 15),
        const Align(
            alignment: Alignment.topLeft,
            child: RotatedBox(
                quarterTurns: 2,
                child: BackButton()
            )
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ListView(
              controller: srcCtr,
              children: [
                AspectRatio(
                  aspectRatio: 3/1.5,
                    child: Image.asset(AppImages.timetable)
                ),
                const SizedBox(height: 10),
                Center(child: const Text('پشتیبانی', style: TextStyle(fontSize: 17)).bold()),
                const SizedBox(height: 20),

                const Divider(color: Colors.black54, indent: 0, endIndent: 0),
                const SizedBox(height: 10),

                UnconstrainedBox(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    height: 36,
                    //width: 70,
                    child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            visualDensity: const VisualDensity(vertical: -2)
                        ),
                        onPressed: onChargeTime,
                        label: const Text('شارژ زمان'),
                      icon: const Icon(AppIcons.add),
                    ),
                  ),
                ),

                Visibility(
                  visible: widget.lesson != null,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('نام درس').fsR(2),
                          ],
                        ),

                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text('${widget.lesson?.title}').alpha(),
                            ),
                          ],
                        ).wrapBoxBorder(color: Colors.black),
                      ],
                    )
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Text('موضوع مورد نظر').fsR(2),
                  ],
                ),

                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: titleCtr,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                        ),
                      )
                    ),
                  ],
                ).wrapBoxBorder(color: Colors.black),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Text('مدت زمان مورد نظر').fsR(2),
                    const Text('(به دقیقه)').fsR(-2),
                  ],
                ),

                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: timeCtr,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            hintText: 'حداکثر $maxUserTime دقیقه',
                          ),
                        ).wrapBoxBorder(color: Colors.black)
                    ),

                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        //padding: EdgeInsets.zero,
                        //visualDensity: const VisualDensity(vertical: -2)
                      ),
                        onPressed: requestFreeTimes,
                        child: const Text('بررسی')
                    ),
                  ],
                ),

                Builder(
                    builder: (_){
                      if(dayHourList.isEmpty){
                        return const SizedBox();
                      }

                      return Column(
                        children: [
                          const SizedBox(height: 20),
                          const Text('لطفا روز و زمان مورد نظر خود را انتخاب کنید'),
                          const SizedBox(height: 15),

                          buildDays(),
                          const SizedBox(height: 10),
                          ...buildTimes(),

                          const SizedBox(height: 5),
                          Visibility(
                            visible: dayHourList.isNotEmpty && timeSelectId != '',
                            child: ElevatedButton(
                              onPressed: showConfirmSheet,
                              child: const Text('ثبت درخواست پشتیبانی'),
                            ),
                          ),
                        ],
                      );
                    }
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDays(){
    return SizedBox(
      height: 80,
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(flex: 10, child: buildDayItem(days[0])),
          const Flexible(flex: 2, child: SizedBox()),

          Flexible(flex: 10, child: buildDayItem(days[1])),
          const Flexible(flex: 2, child: SizedBox()),

          Flexible(flex: 10, child: buildDayItem(days[2])),
          const Flexible(flex: 2, child: SizedBox()),

          Flexible(flex: 10, child: buildDayItem(days[3])),
          const Flexible(flex: 2, child: SizedBox()),

          Flexible(flex: 10, child: buildDayItem(days[4])),
          const Flexible(flex: 2, child: SizedBox()),

          Flexible(flex: 10, child: buildDayItem(days[5])),
          const Flexible(flex: 2, child: SizedBox()),

          Flexible(flex: 10, child: buildDayItem(days[6])),
          const Flexible(flex: 2, child: SizedBox()),
        ],
      ),
    );
  }

  Widget buildDayItem(DayWeekModel dModel){
    return GestureDetector(
      onTap: (){
        if(dModel.isBlock){
          return;
        }

        currentDay = dModel.dayOfMonth;
        assistCtr.updateHead();
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black.withAlpha(70))
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ColoredBox(
            color: dModel.isBlock ? Colors.grey[200]! : (dModel.dayOfMonth == currentDay? AppDecoration.red: Colors.transparent),
            child: SizedBox.expand(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(dModel.dayText),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text('${dModel.dayOfMonth}'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildTimes(){
    List<Widget> result = [];

    final day = getDay();
    final hours = dayHourList.firstWhere((element) => element.dayOfWeek == day.dayOfWeek);

    if(hours.hours.isEmpty){
      result.add(const Padding(
        padding: EdgeInsets.all(30.0),
        child: Text('موردی وجود ندارد'),
      ));

      return result;
    }

    for(final row in hours.hours){
      result.add(itemBuilder(row));
    }

    return result;
  }

  Widget itemBuilder(HoursModel hour){
    return GestureDetector(
      onTap: (){
        if(hour.isBlock || hour.isReserveByMe){
          return;
        }

        timeSelectId = hour.id;

        assistCtr.updateHead();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: SizedBox(
          height: 45,
          child: DecoratedBox(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black.withAlpha(50))
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ColoredBox(
                color: hour.isBlock ? Colors.grey[200]! : (hour.id == timeSelectId? AppDecoration.red: Colors.transparent),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Row(
                        children: [
                          //getTimeSeparator(hour),
                          const SizedBox(width: 5),
                          Text(hour.getStateText(),
                              style: TextStyle(color: hour.getStateTextColor(hour.id == timeSelectId))
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Row(
                        children: [
                          Text(hour.toHuman, style: TextStyle(color: hour.getTimeColor(hour.id == timeSelectId))),

                          const SizedBox(width: 10),
                          Image.asset(hour.id != timeSelectId? AppImages.arrowIco: AppImages.arrowWhiteIco),
                          const SizedBox(width: 10),

                          Text(hour.fromHuman, style: TextStyle(color: hour.getTimeColor(hour.id == timeSelectId))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<HoursModel> getHoursList(){
    final day = getDay();
    final hours = dayHourList.firstWhere((element) => element.dayOfWeek == day.dayOfWeek);

    return hours.hours;
  }

  HoursModel? getHourById(String id){
    final hours = getHoursList();

    return hours.firstWhere((element) => element.id == id);
  }

  DayWeekModel getDay(){
    return days.firstWhere((element) => element.dayOfMonth == currentDay);
  }

  void onChargeTime() async {
    final js = await requestSupportTimePlans();

    if(js == null){
      return;
    }

    List<SupportPlanModel> pList = [];

    for(final t in js){
      final p = SupportPlanModel.fromMap(t);
      pList.add(p);
    }

    if(context.mounted){
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

  void requestUserLeftTime() async {
    final rt = IrisRuntimeCache.find(AppStoreScope.user$supportTime, SessionService.getLastLoginUser()!.userId);

    if(rt != null && rt.isUpdate()){
      maxUserTime = rt.value;
    }
    else {
      maxUserTime = await ApiManager.requestUserRemainingMinutes(SessionService.getLastLoginUser()!.userId)?? widget.maxUserTime;
    }

   assistCtr.updateHead();
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
    requester.request(context);

    return co.future;
  }

  void showConfirmSheet() async {
    final hour = getHourById(timeSelectId);

    if(hour == null){
      AppSnack.showInfo(context, 'لطفا یک بازه زمانی را انتخاب کنید');
      return;
    }

    final day = getDay();

    final res = await AppSheet.showSheetCustom(
      context,
      builder: (ctx){
        return TimetableConfirmRequestSupport(
          lesson: widget.lesson?.title,
          title: TextHelper.subByCharCountSafe(titleCtr.text.trim(), 50),
          day: day.day.format('YYYY/MM/DD', 'en'),
          limitTime:'${hour.toHuman}  -  ${hour.fromHuman}',
        );
      },
      routeName: 'TimetableConfirmRequestSupport',
      contentColor: Colors.transparent,
    );

    if(res == true){
      requestSupport();
    }
  }

  void requestFreeTimes() async {
    FocusHelper.hideKeyboardByUnFocusRoot();
    await Future.delayed(const Duration(milliseconds: 200));

    final min = timeCtr.text.trim();
    final title = titleCtr.text.trim();

    if(title.isEmpty){
      AppSheet.showSheetOk(context, 'موضوع را وارد کنید');
      return;
    }

    if(title.length < 5){
      AppSheet.showSheetOk(context, 'موضوع کوتاه است');
      return;
    }

    if(title.length > 50){
      AppSheet.showSheetOk(context, 'موضوع طولانی است');
      return;
    }

    if(min.isEmpty){
      AppSheet.showSheetOk(context, 'مدت زمان را وارد کنید');
      return;
    }

    final minNumber = MathHelper.clearToInt(min);

    if(minNumber > maxUserTime){
      AppSheet.showSheetOk(context, 'شما حداکثر $maxUserTime دقیقه امکان درخواست دارید. اگر زمان بیشتری نیاز دارید ابتدا زمان خود را شارژ کنید.');
      return;
    }

    if(minNumber < 5){
      AppSheet.showSheetOk(context, 'مدت زمان باید بیشتر از 5 دقیقه باشد');
      return;
    }

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
      assistCtr.updateHead();
    };

    requester.httpRequestEvents.onStatusOk = (req, jsData) async {
      final data = jsData[Keys.data];

      if(data is List){
        for(final k in data){
          final g = HoursOfSupportModel.fromMap(k);
          dayHourList.add(g);
        }
      }

      final today = SolarHijriDate();

      for(int i = 0; i < dayHourList.length; i++) {
        final day = today.moveDayClone(i);
        final x = DayWeekModel();
        x.dayText = day.getWeekDayName().substring(0, 1);
        x.dayOfMonth = day.getDay();
        x.dayOfWeek = dayHourList[i].dayOfWeek;
        x.day = day;

        days.add(x);
      }

      currentDay = today.getDay();
      assistCtr.updateHead();

      Future.delayed(const Duration(milliseconds: 500), (){
        srcCtr.animateTo(400, duration: const Duration(milliseconds: 400), curve: Curves.linear);
      });
    };

    days.clear();
    dayHourList.clear();
    showLoading();

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/supportTimes?RequiredMinutes=$minNumber');
    requester.request(context);
  }

  void requestSupport(){
    requester.httpRequestEvents.clear();

    requester.httpRequestEvents.onFailState = (requester, res) async {
      hideLoading();

      String msg = 'خطایی رخ داده است';

      if(res != null && res.data != null){
        final js = JsonHelper.jsonToMap(res.data)?? {};

        msg = js['message']?? msg;
      }

      AppSnack.showInfo(context, msg);
    };

    requester.httpRequestEvents.onStatusOk = (requester, jsData) async {
      hideLoading();

      final data = jsData['data'];
      String msg = data['message']?? 'رزرو شد';

      AppSheet.showSheetOneAction(context, msg, onButton: () {
        RouteTools.popTopView(context: context, data: true);
      });
    };

    final day = getDay();
    final hour = getHourById(timeSelectId)!;

    final js = <String, dynamic>{};
    js['subject'] = TextHelper.subByCharCountSafe(titleCtr.text.trim(), 50);
    js['dayOfWeek'] = day.dayOfWeek;
    js['from'] = hour.from;
    js['to'] = hour.to;

    if(widget.lesson != null){
      js['lessonId'] = widget.lesson!.id;
    }

    showLoading();
    requester.prepareUrl(pathUrl: '/appointments/booking');
    requester.methodType = MethodType.post;
    requester.bodyJson = js;
    requester.request(context);
  }
}
