import 'package:flutter/material.dart';

import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/structures/enums/transactionSectionFilter.dart';
import 'package:app/structures/enums/transactionStatusFilter.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';

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
    section = TransactionSectionFilter.fromType(map['section']);
    status = TransactionStatusFilter.fromType(map['status']);
    date = DateHelper.tsToSystemDate(map['createdAt'])!;
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
        return AppColors.blue;
      case TransactionStatusFilter.cancelled:
        return Colors.deepOrangeAccent;
      case TransactionStatusFilter.paid:
        return AppColors.green;
      case TransactionStatusFilter.rejected:
        return AppColors.red;
      default:
        return Colors.black;
    }
  }

  Color getSectionColor(){
    switch(section){
      case TransactionSectionFilter.chargeWallet:
        return AppColors.blue;
      case TransactionSectionFilter.withdrawWallet:
        return AppColors.green;
      case TransactionSectionFilter.lessonPurchase:
        return AppColors.purple;
      case TransactionSectionFilter.supportPurchase:
        return AppColors.purple;
      case TransactionSectionFilter.forceChargeWallet:
        return AppColors.green;
      default:
        return Colors.black;
    }

  }

  Color getSectionTintColor(){
    switch(section){
      case TransactionSectionFilter.chargeWallet:
        return AppColors.blueTint;
      case TransactionSectionFilter.withdrawWallet:
        return AppColors.greenTint;
      case TransactionSectionFilter.lessonPurchase:
        return AppColors.purpleTint;
      case TransactionSectionFilter.supportPurchase:
        return AppColors.purpleTint;
      case TransactionSectionFilter.forceChargeWallet:
        return AppColors.greenTint;
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
