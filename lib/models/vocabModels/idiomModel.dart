import 'package:app/models/mediaModel.dart';
import 'package:app/system/keys.dart';

class IdiomModel {
  late String id;
  late String content;
  late String translation;
  bool showTranslation = false;
  MediaModel? video;


  IdiomModel();

  IdiomModel.fromMap(Map map) {
    id = map[Keys.id];
    content = map['content'];
    translation = map['translation'];
    showTranslation = map['showTranslation']?? false;


    if (map['video'] is Map) {
      video = MediaModel.fromMap(map['video']);
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[Keys.id] = id;
    map['content'] = content;
    map['translation'] = translation;
    map['video'] = video?.toMap();
    map['showTranslation'] = showTranslation;

    return map;
  }
}