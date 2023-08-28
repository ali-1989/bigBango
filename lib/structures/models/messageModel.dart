import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/structures/enums/messageStatus.dart';
import 'package:app/structures/enums/notificationType.dart';
import 'package:app/structures/models/mediaModel.dart';

class MessageModel {
  late String id;
  late String title;
  late String body;
  NotificationType type = NotificationType.unKnow;
  MessageStatus status = MessageStatus.unKnow;
  late DateTime createAt;
  Map? data;
  MediaModel? image;

  MessageModel();

  MessageModel.fromMap(Map? map){
    if(map == null){
      return;
    }

    id = map['id'];
    title = map['title'];
    body = map['body'];
    data = map['data'];
    createAt = DateHelper.tsToSystemDate(map['createdAt'])!;
    type = NotificationType.from(map['type']);
    status = MessageStatus.from(map['status']);

    if(map['image'] is Map){
      image = MediaModel.fromMap(map['image']);
    }
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map['id'] = id;
    map['title'] = title;
    map['body'] = body;
    map['data'] = data;
    map['image'] = image?.toMap();
    map['createdAt'] = DateHelper.toTimestamp(createAt);
    map['status'] = status.number;
    map['type'] = type.number;

    return map;
  }

  void matchBy(MessageModel other){
    id = other.id;
    title = other.title;
    body = other.body;
    data = other.data;
    image = other.image;
    createAt = other.createAt;
    status = other.status;
    type = other.type;
  }

  bool hasContent(){
    return image?.fileLocation != null;
  }
}
