import 'package:flutter/material.dart';

enum SupportSessionStatus {
  unKnow(-1),
  inProgress(1),
  done(2),
  canceled(4);

  final int _type;

  const SupportSessionStatus(this._type);

  int type(){
    return _type;
  }

  String getState(){
    switch(_type){
      case 1:
        return 'در انتظار';
      case 2:
        return 'انجام شده';
      case 4:
        return 'لغو شده';
    }

    return '-';
  }

  Color getStateColor(){
    switch(_type){
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 4:
        return Colors.orange;
    }

    return Colors.black87;
  }

  static SupportSessionStatus from(int type){
    for(final v in SupportSessionStatus.values){
      if(v._type == type){
        return v;
      }
    }

    return SupportSessionStatus.unKnow;
  }
}