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

  factory SupportSessionStatus.from(dynamic numberOrString){
    if(numberOrString is String){
      return values.firstWhere((element) => element.name == numberOrString, orElse: ()=> unKnow);
    }

    if(numberOrString is int){
      return values.firstWhere((element) => element.number == numberOrString, orElse: ()=> unKnow);
    }

    return SupportSessionStatus.unKnow;
  }
}