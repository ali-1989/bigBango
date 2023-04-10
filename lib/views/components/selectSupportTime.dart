import 'package:app/managers/systemParameterManager.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:flutter/material.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/models/hoursOfSupportModel.dart';
import 'package:app/structures/models/supportModels/dayWeekModel.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/dateSection/ADateStructure.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

class SelectSupportTime extends StatefulWidget {
  const SelectSupportTime({Key? key}) : super(key: key);

  @override
  State<SelectSupportTime> createState() => _SelectSupportTimeState();
}
///=========================================================================================================
class _SelectSupportTimeState extends StateBase<SelectSupportTime> {
  int currentDay = 0;
  String? timeSelectId;
  List<HoursOfSupportModel> dayHourList = [];
  List<DayWeekModel> days = [];
  Requester requester = Requester();


  @override
  void initState(){
    super.initState();

    requestFreeTimes();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (_, __, sendData) {
        return Scaffold(
          body: buildBody(),
        );
      },
    );
  }

  Widget buildBody() {
    if(dayHourList.isEmpty){
      return WaitToLoad();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(AppImages.supportTimeIco),
                  const SizedBox(width: 10),
                  Text(AppMessages.supportTimeTitle, style: const TextStyle(fontSize: 17),),
                ],
              ),

              SizedBox(
                width: 110,
                height: 30,
                child: ElevatedButton(
                  onPressed: timeSelectId == null? null : onRegister,
                  child: Text(AppMessages.register),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(AppMessages.supportDescription, textAlign: TextAlign.center, style: const TextStyle(height: 1.4)),
          ),
          const SizedBox(height: 20),

          buildDays(),
          SizedBox(height: 10),

          Expanded(
              child: ListView(
                children: [
                  ...buildTimes(),
                ],
              ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget getTimeSeparator(HoursModel model){
    return SizedBox(
      width: 3,
      height: 16,
      child: ColoredBox(color: model.getStateTextColor(model.id == timeSelectId)),
    );
  }

  Widget buildListItem(HoursModel model){
    return GestureDetector(
      onTap: (){
        if(model.isBlock || model.isReserveByMe){
          return;
        }

        timeSelectId = model.id;
        callState();
      },
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
              color: model.isBlock ? Colors.grey[200]! : (model.id == timeSelectId? AppColors.red: Colors.transparent),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Row(
                      children: [
                        getTimeSeparator(model),
                        const SizedBox(width: 5),
                        Text(model.getStateText(), style: TextStyle(color: model.getStateTextColor(model.id == timeSelectId))),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Row(
                      children: [
                        Text(model.from, style: TextStyle(color: model.getTimeColor(model.id == timeSelectId))),
                        const SizedBox(width: 10),
                        Builder(
                          builder: (context) {
                            if(model.id != timeSelectId){
                              return Image.asset(AppImages.arrowIco);
                            }

                            return Image.asset(AppImages.arrowWhiteIco);
                          }
                        ),
                        const SizedBox(width: 10),
                        Text(model.to, style: TextStyle(color: model.getTimeColor(model.id == timeSelectId))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
            color: dModel.isBlock ? Colors.grey[200]! : (dModel.dayOfMonth == currentDay? AppColors.red: Colors.transparent),
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
      result.add(Padding(
        padding: const EdgeInsets.all(30.0),
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
                color: hour.isBlock ? Colors.grey[200]! : (hour.id == timeSelectId? AppColors.red: Colors.transparent),
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

  void requestFreeTimes() async {
    FocusHelper.hideKeyboardByUnFocusRoot();
    await Future.delayed(Duration(milliseconds: 200));

    final min = SystemParameterManager.systemParameters.timeTable['determineCourseLevelMinutes'];
    final minNumber = MathHelper.clearToInt(min);

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
    };

    days.clear();
    dayHourList.clear();

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/supportTimes?RequiredMinutes=$minNumber');
    requester.request(context);
  }

  void onRegister(){
    requestSupport();
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

      AppSheet.showSheetOneAction(context, msg, () async {
        showLoading();
        final res = await PublicAccess.requestSetLevel(SystemParameterManager.getCourseLevelById(1));
        await hideLoading();

        if(res){
          AppBroadcast.reBuildMaterial();
          RouteTools.backToRoot(context);
        }
      });
    };

    final day = getDay();
    final hour = getHourById(timeSelectId!)!;

    final js = <String, dynamic>{};
    js['subject'] = 'درخواست تعیین سطح';
    js['dayOfWeek'] = day.dayOfWeek;
    js['from'] = hour.from;
    js['to'] = hour.to;

    showLoading();
    requester.prepareUrl(pathUrl: '/appointments/booking');
    requester.methodType = MethodType.post;
    requester.bodyJson = js;
    requester.request(context);
  }
}
