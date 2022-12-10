import 'package:app/structures/models/mediaModel.dart';
import 'package:app/structures/models/ticketModels/ticketReplyModel.dart';
import 'package:iris_tools/api/converter.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

class TicketDetailModel {
  late String id;
  int number = 0;
  int status = 0;
  late String title;
  String trackingRoleName = '';
  late DateTime createdAt;
  List<TicketReplyModel> replies = [];
  List<MediaModel> attachments = [];

  TicketDetailModel();

  TicketDetailModel.fromMap(Map map){
    id = map['id'];
    title = map['title'];
    number = map['number'];
    status = map['status']?? 0;
    trackingRoleName = map['trackingRoleName']?? '';
    createdAt = DateHelper.tsToSystemDate(map['createdAt'])!;

    final List<Map> repliesTemp = Converter.correctList(map['replies'])?? [];

    replies = repliesTemp.map((i) => TicketReplyModel.fromMap(i)).toList();
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map['id'] = id;
    map['title'] = title;
    map['number'] = number;
    map['status'] = status;
    map['trackingRoleName'] = trackingRoleName;
    map['createdAt'] = DateHelper.toTimestamp(createdAt);
    map['replies'] = replies.map((e) => e.toMap()).toList(growable: false);

    return map;
  }
}
