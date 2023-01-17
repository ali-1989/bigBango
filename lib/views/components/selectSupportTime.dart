import 'dart:math';

import 'package:app/structures/models/hoursOfSupportModel.dart';
import 'package:flutter/material.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/models/supportModels/dayWeekModel.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';

class SelectSupportTime extends StatefulWidget {
  const SelectSupportTime({Key? key}) : super(key: key);

  @override
  State<SelectSupportTime> createState() => _SelectSupportTimeState();
}
///=========================================================================================================
class _SelectSupportTimeState extends StateBase<SelectSupportTime> {
  int currentDay = 12;
  String timeSelectId = '';
  List<DayWeekModel> days = [];
  List<HoursModel> times = [];


  @override
  void initState(){
    super.initState();

    days.add(DayWeekModel()..dayText = 'ش'..dayOfWeek = 10..isBlock = true);
    days.add(DayWeekModel()..dayText = 'ی'..dayOfWeek = 11);
    days.add(DayWeekModel()..dayText = 'د'..dayOfWeek = 12);
    days.add(DayWeekModel()..dayText = 'س'..dayOfWeek = 13);
    days.add(DayWeekModel()..dayText = 'چ'..dayOfWeek = 14);
    days.add(DayWeekModel()..dayText = 'پ'..dayOfWeek = 15);
    days.add(DayWeekModel()..dayText = 'ج'..dayOfWeek = 16);

    final randomNumberGenerator = Random();

    List.generate(30, (index) {
      final s = HoursModel();
      s.id = '$index';
      s.isBlock = randomNumberGenerator.nextBool();
      s.isReserveByMe = randomNumberGenerator.nextBool();

      times.add(s);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
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
                child: ElevatedButton(
                    onPressed: null,
                    child: Text(AppMessages.register),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(AppMessages.selectLevelDescription, textAlign: TextAlign.center, style: const TextStyle(height: 1.4)),
          ),
          const SizedBox(height: 30),

          SizedBox(
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
          ),
          const SizedBox(height: 30),

          Expanded(
            child: ListView.separated(
                itemCount: times.length,
                itemBuilder: (ctx, idx){
                  final t = times[idx];
                  return buildListItem(t);
                },
              separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 10);
              },
            ),
          ),
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

  Widget buildDayItem(DayWeekModel dModel){
    return GestureDetector(
      onTap: (){
        if(dModel.isBlock){
          return;
        }

        currentDay = dModel.dayOfWeek;
        callState();
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black.withAlpha(70))
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ColoredBox(
            color: dModel.isBlock ? Colors.grey[200]! : (dModel.dayOfWeek == currentDay? AppColors.red: Colors.transparent),
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
                    child: Text('${dModel.dayOfWeek}'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
