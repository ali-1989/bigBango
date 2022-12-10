import 'package:iris_tools/dateSection/dateHelper.dart';

class TicketReplyModel {
  late String id;
  int number = 0;
  late DateTime createdAt;

  TicketReplyModel();

  TicketReplyModel.fromMap(Map map){
    id = map['id'];
    createdAt = DateHelper.tsToSystemDate(map['createdAt'])!;
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map['id'] = id;
    map['createdAt'] = DateHelper.toTimestamp(createdAt);

    return map;
  }
}
