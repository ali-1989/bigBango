import 'package:app/structures/models/mediaModel.dart';
import 'package:app/structures/models/ticketModels/ticketDetailModel.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';


class TicketReplyModel {
  late String id;
  late String description;
  late DateTime createdAt;
  late TicketCreatorModel creator;
  List<MediaModel> attachments = [];

  TicketReplyModel();

  TicketReplyModel.fromMap(Map map){
    id = map['id'];
    description = map['description'];
    creator = TicketCreatorModel.fromMap(map['creator']);
    createdAt = DateHelper.tsToSystemDate(map['createdAt'])!;
    attachments = map['attachments'].map<MediaModel>((i) => MediaModel.fromMap(i)).toList();
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map['id'] = id;
    map['description'] = description;
    map['createdAt'] = DateHelper.toTimestamp(createdAt);
    map['creator'] = creator.toMap();
    map['attachments'] = attachments.map((e) => e.toMap()).toList(growable: false);

    return map;
  }
}
