import 'package:app/structures/models/mediaModel.dart';

class NotificationModel {
  late String id;
  late String title;
  late String body;
  int type = 1;
  int status = 1;
  String? data;
  MediaModel? image;

  NotificationModel.fromMap(Map? map){
    if(map == null){
      return;
    }

    id = map['id'];
    title = map['title'];
    body = map['body'];
    data = map['data'];

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
    map['status'] = status;
    map['type'] = type;

    return map;
  }
}
