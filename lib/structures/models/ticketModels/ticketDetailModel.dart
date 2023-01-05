import 'package:app/structures/models/mediaModel.dart';
import 'package:app/structures/models/ticketModels/ticketReplyModel.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

class TicketDetailModel {
  late String id;
  int number = 0;
  int status = 0;
  late String title;
  late String description;
  String trackingRoleName = '';
  late DateTime createdAt;
  late TicketCreatorModel creator;
  List<TicketReplyModel> replies = [];
  List<MediaModel> attachments = [];

  TicketDetailModel();

  TicketDetailModel.fromMap(Map map){
    id = map['id'];
    title = map['title'];
    description = map['description'];
    number = map['number'];
    status = map['status']?? 0;
    creator = TicketCreatorModel.fromMap(map['creator']);
    trackingRoleName = map['trackingRoleName']?? '';
    createdAt = DateHelper.tsToSystemDate(map['createdAt'])!;

    //final List<Map> repliesTemp = Converter.correctList(map['replies'])?? [];

    replies = map['replies'].map<TicketReplyModel>((i) => TicketReplyModel.fromMap(i)).toList();
    attachments = map['attachments'].map<MediaModel>((i) => MediaModel.fromMap(i)).toList();
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map['id'] = id;
    map['title'] = title;
    map['description'] = description;
    map['number'] = number;
    map['status'] = status;
    map['trackingRoleName'] = trackingRoleName;
    map['createdAt'] = DateHelper.toTimestamp(createdAt);
    map['replies'] = replies.map((e) => e.toMap()).toList(growable: false);
    map['attachments'] = attachments.map((e) => e.toMap()).toList(growable: false);

    return map;
  }
}
///==========================================================================
class TicketCreatorModel {
  late String id;
  String? firstName;
  String? lastName;
  MediaModel? avatar;

  TicketCreatorModel();

  TicketCreatorModel.fromMap(Map map){
    id = map['id'];
    firstName = map['firstName'];
    lastName = map['lastName'];

    if(map['avatar'] is Map){
      avatar = MediaModel.fromMap(map['avatar']);
    }
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map['id'] = id;
    map['firstName'] = firstName;
    map['lastName'] = lastName;
    map['avatar'] = avatar?.toMap();

    return map;
  }
}