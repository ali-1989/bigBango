import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/structures/enums/walletAmountType.dart';

class TransactionWalletModel {
  late String id;
  int amount = 0;
  WalletAmountType amountType = WalletAmountType.unKnow;
  String? description;
  late DateTime date;

  TransactionWalletModel();

  TransactionWalletModel.fromMap(Map map){
    id = map['id']?? Generator.generateKey(8);
    description = map['description'];
    amount = map['amount'];
    amountType = WalletAmountType.from(map['amountType']?? -1);
    date = DateHelper.tsToSystemDate(map['createdAt'])!;
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map['id'] = id;
    map['description'] = description;
    map['amount'] = amount;
    map['amountType'] = amountType.number;
    map['createdAt'] = DateHelper.toTimestamp(date);

    return map;
  }

  bool isAmountPlus(){
    return amount >= 0;
  }

  String getAmountHuman(){
    if(isAmountPlus()){
      return 'واریز به حساب';
    }

    if(!isAmountPlus()){
      return 'برداشت از حساب';
    }

    return '';
  }
}
