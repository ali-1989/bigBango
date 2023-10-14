import 'package:app/structures/models/mediaModel.dart';
import 'package:app/structures/models/ticketModels/ticketReplyModel.dart';

class TicketDetailModel {
  late String id;
  int number = 0;
  int status = 0;
  late String title;
  String trackingRoleName = '';
  List<TicketReplyModel> replies = [];
  late TicketReplyModel firstTicket;

  /*late String description;
  late DateTime createdAt;
  late TicketCreatorModel creator;
  List<MediaModel> attachments = [];*/

  TicketDetailModel();

  TicketDetailModel.fromMap(Map map){
    id = map['id'];
    title = map['title'];
    number = map['number'];
    status = map['status']?? 0;
    trackingRoleName = map['trackingRoleName']?? '';
    //final List<Map> repliesTemp = Converter.correctList(map['replies'])?? [];
    replies = map['replies'].map<TicketReplyModel>((i) => TicketReplyModel.fromMap(i)).toList();

    /*attachments = map['attachments'].map<MediaModel>((i) => MediaModel.fromMap(i)).toList();
    description = map['description'];
    createdAt = DateHelper.timestampToSystem(map['createdAt'])!;
    creator = TicketCreatorModel.fromMap(map['creator']);*/

    firstTicket = TicketReplyModel.fromMap(map);
  }

  Map<String, dynamic> toMap(){
    final map = firstTicket.toMap();

    map['id'] = id;
    map['title'] = title;
    map['number'] = number;
    map['status'] = status;
    map['trackingRoleName'] = trackingRoleName;
    map['replies'] = replies.map((e) => e.toMap()).toList(growable: false);

    /*map['description'] = description;
    map['createdAt'] = DateHelper.toTimestamp(createdAt);
    map['creator'] = creator.toMap();
    map['attachments'] = attachments.map((e) => e.toMap()).toList(growable: false);*/

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

  bool hasAvatar(){
    return avatar != null && avatar!.fileLocation != null;
  }
}