import 'package:app/models/mediaModel.dart';


class GrammarModel {
  String title = '';
  int order = 0;
  MediaModel? media;

  GrammarModel();

  GrammarModel.fromMap(Map map) {
    title = map['title'];
    order = map['order']?? 0;
    final video = map['video'];

    if(video != null) {
      media = MediaModel.fromMap(video);
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['video'] = media?.toMap();

    return map;
  }
}
