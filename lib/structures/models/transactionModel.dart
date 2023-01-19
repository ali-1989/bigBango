import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

class TransactionModel {
  late String id;
  int amount = 0;
  int amountType = 0;
  String? title;
  late DateTime date;

  TransactionModel();

  TransactionModel.fromMap(Map map){
    id = map['id']?? Generator.generateKey(8);
    title = map['title'];
    amount = map['amount'];
    amountType = map['amountType'];
    date = DateHelper.tsToSystemDate(map['createdAt'])!;
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map['id'] = id;
    map['title'] = title;
    map['amount'] = amount;
    map['amountType'] = amountType;
    map['createdAt'] = DateHelper.toTimestamp(date);

    return map;
  }
}
