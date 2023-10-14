import 'package:flutter/material.dart';

import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/structures/enums/transactionSectionFilter.dart';
import 'package:app/structures/enums/transactionStatusFilter.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_images.dart';

class TransactionModel {
  late String id;
  int amount = 0;
  String? description;
  late DateTime date;
  TransactionSectionFilter section = TransactionSectionFilter.unKnow;
  TransactionStatusFilter status = TransactionStatusFilter.unKnow;
  List items = [];

  TransactionModel();

  TransactionModel.fromMap(Map map){
    id = map['id']?? Generator.generateKey(8);
    description = map['description'];
    amount = map['amount'];
    section = TransactionSectionFilter.from(map['section']);
    status = TransactionStatusFilter.from(map['status']);
    date = DateHelper.timestampToSystem(map['createdAt'])!;
    items = map['items']?? [];
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map['id'] = id;
    map['description'] = description;
    map['amount'] = amount;
    map['section'] = section.number;
    map['status'] = status.number;
    map['createdAt'] = DateHelper.toTimestamp(date);
    map['items'] = items;

    return map;
  }

  bool isPlus(){
    return section == TransactionSectionFilter.withdrawWallet;
  }

  Color getStatusColor(){
    switch(status){
      case TransactionStatusFilter.inProgress:
        return AppDecoration.blue;
      case TransactionStatusFilter.cancelled:
        return Colors.deepOrangeAccent;
      case TransactionStatusFilter.paid:
        return AppDecoration.green;
      case TransactionStatusFilter.rejected:
        return AppDecoration.red;
      default:
        return Colors.black;
    }
  }

  Color getSectionColor(){
    switch(section){
      case TransactionSectionFilter.chargeWallet:
        return AppDecoration.blue;
      case TransactionSectionFilter.withdrawWallet:
        return AppDecoration.green;
      case TransactionSectionFilter.lessonPurchase:
        return AppDecoration.purple;
      case TransactionSectionFilter.supportPurchase:
        return AppDecoration.purple;
      case TransactionSectionFilter.forceChargeWallet:
        return AppDecoration.green;
      default:
        return Colors.black;
    }

  }

  Color getSectionTintColor(){
    switch(section){
      case TransactionSectionFilter.chargeWallet:
        return AppDecoration.blueTint;
      case TransactionSectionFilter.withdrawWallet:
        return AppDecoration.greenTint;
      case TransactionSectionFilter.lessonPurchase:
        return AppDecoration.purpleTint;
      case TransactionSectionFilter.supportPurchase:
        return AppDecoration.purpleTint;
      case TransactionSectionFilter.forceChargeWallet:
        return AppDecoration.greenTint;
      default:
        return Colors.black;
    }
  }

  String getIcon(){
    switch(section){
      case TransactionSectionFilter.chargeWallet:
        return AppImages.chargeWallet;
      case TransactionSectionFilter.withdrawWallet:
        return AppImages.withdrawWalletIc;
      case TransactionSectionFilter.lessonPurchase:
        return AppImages.lessonPurchaseIc;
      case TransactionSectionFilter.supportPurchase:
        return AppImages.supportPurchaseIco;
      case TransactionSectionFilter.forceChargeWallet:
        return AppImages.withdrawWalletIc;
      default:
        return '';
    }
  }
}
