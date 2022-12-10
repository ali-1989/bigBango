import 'package:iris_tools/dateSection/dateHelper.dart';

class TransactionModel {
  late String id;
  int amount = 0;
  String? title;
  late DateTime date;

  TransactionModel();

  TransactionModel.fromMap(Map map){
    id = map['id'];
    title = map['title'];
    amount = map['amount'];
    date = DateHelper.tsToSystemDate(map['date'])!;
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map['id'] = id;
    map['title'] = title;
    map['amount'] = amount;
    map['date'] = DateHelper.toTimestamp(date);

    return map;
  }
}
