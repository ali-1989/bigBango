import 'package:flutter/material.dart';

import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/tools/dateTools.dart';

// 0 saturday
// 6 friday
class HoursOfSupportModel {
  int dayOfWeek = 0;
  List<HoursModel> hours = [];

  HoursOfSupportModel();

  HoursOfSupportModel.fromMap(Map? map){
    if (map != null) {
      dayOfWeek = map['dayOfWeek'];

      if(map['hours'] is List){
        for(final k in map['hours']){
          hours.add(HoursModel.fromMap(k));
        }
      }
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> res = {};
    res['dayOfWeek'] = dayOfWeek;
    res['hours'] = hours.map((e) => e.toMap()).toList();

    return res;
  }
}
///=============================================================================================
class HoursModel {
  late String id;
  late String from;
  late String to;
  late String fromHuman;
  late String toHuman;
  bool isBlock = false;
  bool isReserveByMe = false;

  HoursModel(): id = Generator.generateKey(8);

  HoursModel.fromMap(Map? map){
    id = Generator.generateKey(8);

    if(map != null) {
      from = map['from'];
      to = map['to'];
      isBlock = map['isBooked'];

      fromHuman = DateTools.hmOnlyRelative(DateHelper.tsToSystemDate('2023-01-01 $from'), isUtc: false);
      toHuman = DateTools.hmOnlyRelative(DateHelper.tsToSystemDate('2023-01-01 $to'), isUtc: false);
    }
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> res = {};
    res['from'] = from;
    res['to'] = to;
    res['isBooked'] = isBlock;

    return res;
  }

  String getStateText(){
    if(isBlock){
      return 'رزرو شده';
    }

    return 'آماده رزرو';
  }

  Color getStateTextColor(bool isSelected){
    if(isBlock){
      return Colors.red;
    }

    return isSelected? Colors.white : Colors.green;
  }

  Color getTimeColor(bool isSelected){
    if(isBlock){
      return Colors.grey[600]!;
    }

    return isSelected? Colors.white : Colors.black;
  }
}
