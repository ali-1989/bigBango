import 'package:app/structures/enums/notificationStatus.dart';
import 'package:app/structures/enums/notificationType.dart';
import 'package:app/structures/models/mediaModel.dart';

class NotificationModel {
  late String id;
  late String title;
  late String body;
  NotificationType type = NotificationType.unKnow;
  NotificationStatus status = NotificationStatus.unKnow;
  late DateTime createAt;
  String? data;
  MediaModel? image;

  NotificationModel();

  NotificationModel.fromMap(Map? map){
    if(map == null){
      return;
    }

    id = map['id'];
    title = map['title'];
    body = map['body'];
    data = map['data'];
    createAt = map['createAt'];
    type = NotificationType.fromType(map['type']);
    status = NotificationStatus.fromType(map['status']);

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
    map['createAt'] = createAt;
    map['status'] = status.number;
    map['type'] = type.number;

    return map;
  }

  void matchBy(NotificationModel other){
    id = other.id;
    title = other.title;
    body = other.body;
    data = other.data;
    image = other.image;
    createAt = other.createAt;
    status = other.status;
    type = other.type;
  }
}
