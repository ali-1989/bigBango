import 'package:flutter/material.dart';

class SupportTimeModel {
  int id = 0;
  String startTime = '10:00';
  String endTime = '12:00';
  bool isBlock = false;
  bool isReserved = false;

  String getStateText(){
    if(isBlock){
      return 'پایان وقت';
    }

    if(isReserved){
      return 'رزرو شده';
    }

    return 'آماده رزرو';
  }

  Color getStateTextColor(bool isSelected){
    if(isBlock){
      return Colors.black;
    }

    if(isReserved){
      return Colors.red;
    }

    return isSelected? Colors.white : Colors.orange;
  }

  Color getTimeColor(bool isSelected){
    if(isBlock){
      return Colors.grey[600]!;
    }

    if(isReserved){
      return Colors.grey[600]!;
    }

    return isSelected? Colors.white : Colors.black;
  }
}