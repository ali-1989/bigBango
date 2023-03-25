import 'package:flutter/material.dart';

enum SupportSessionStatus {
  unKnow(-1),
  inProgress(1),
  done(2),
  expired(3),
  canceled(4),
  adminCanceled(5);

  final int number;

  const SupportSessionStatus(this.number);

  String getTypeHuman(){
    switch(number){
      case 1:
        return 'در انتظار';
      case 2:
        return 'انجام شده';
      case 3:
        return 'منقضی شده';
      case 4:
        return 'لغو شده';
      case 5:
        return 'لغو توسط مدیر';
    }

    return '-';
  }

  Color getStateColor(){
    switch(number){
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.orange;
    }

    return Colors.black87;
  }

  static SupportSessionStatus fromType(int type){
    for(final v in SupportSessionStatus.values){
      if(v.number == type){
        return v;
      }
    }

    return SupportSessionStatus.unKnow;
  }

  static SupportSessionStatus fromName(String name){
    for(final v in SupportSessionStatus.values){
      if(v.name == name){
        return v;
      }
    }

    return SupportSessionStatus.unKnow;
  }
}