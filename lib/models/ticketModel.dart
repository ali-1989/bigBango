import 'package:iris_tools/dateSection/dateHelper.dart';

class TicketModel {
  late String id;
  int number = 0;
  int status = 0;
  late String title;
  String trackingRoleName = '';
  late DateTime createdAt;

  TicketModel();

  TicketModel.fromMap(Map map){
    id = map['id'];
    title = map['title'];
    number = map['number'];
    status = map['status']?? 0;
    trackingRoleName = map['trackingRoleName']?? '';

    createdAt = DateHelper.tsToSystemDate(map['createdAt'])!;
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map['id'] = id;
    map['title'] = title;
    map['number'] = number;
    map['status'] = status;
    map['trackingRoleName'] = trackingRoleName;
    map['createdAt'] = DateHelper.toTimestamp(createdAt);

    return map;
  }
}