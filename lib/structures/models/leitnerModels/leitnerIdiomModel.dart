import 'package:app/system/keys.dart';

class LeitnerIdiomModel {
  late String id;
  late int lessonId;
  late String content;
  late String translation;
  bool showTranslation = false;


  LeitnerIdiomModel();

  LeitnerIdiomModel.fromMap(Map map) {
    id = map[Keys.id];
    lessonId = map['lessonId'];
    content = map['content'];
    translation = map['translation'];
    showTranslation = map['showTranslation']?? false;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[Keys.id] = id;
    map['content'] = content;
    map['translation'] = translation;
    map['showTranslation'] = showTranslation;
    map['lessonId'] = lessonId;

    return map;
  }
}