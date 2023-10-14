import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

class WithdrawalModel {
  late String id;
  int amount = 0;
  String? description;
  late DateTime date;

  WithdrawalModel();

  WithdrawalModel.fromMap(Map map){
    id = map['id']?? Generator.generateKey(8);
    description = map['description'];
    amount = map['amount'];
    date = DateHelper.timestampToSystem(map['createdAt'])!;
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map['id'] = id;
    map['description'] = description;
    map['amount'] = amount;
    map['createdAt'] = DateHelper.toTimestamp(date);

    return map;
  }
}
