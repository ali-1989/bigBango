import 'package:app/structures/models/mediaModel.dart';

class GrammarModel {
  String id = '';
  String title = '';
  int order = 0;
  MediaModel? media;

  GrammarModel();

  GrammarModel.fromMap(Map map) {
    id = map['id'];
    title = map['title'];
    order = map['order']?? 0;

    if(map['video'] is Map) {
      media = MediaModel.fromMap(map['video']);
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['id'] = id;
    map['title'] = title;
    map['order'] = order;
    map['video'] = media?.toMap();

    return map;
  }
}
