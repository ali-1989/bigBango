import 'package:app/structures/models/mediaModel.dart';

class VocabDescriptionModel {
  int number = 0;
  String? content;
  List<VocabDescriptionSampleModel> samples = [];

  VocabDescriptionModel();

  VocabDescriptionModel.fromMap(Map map) {
    number = map['number'];
    content = map['content'];

    if (map['samples'] is List) {
      final List sList = map['samples'];

      for(final k in sList) {
        samples.add(VocabDescriptionSampleModel.fromMap(k));
      }
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['number'] = number;
    map['content'] = content;
    map['samples'] = samples.map((e) => e.toMap()).toList();

    return map;
  }
}
///================================================================================
class VocabDescriptionSampleModel {
  int order = 0;
  int type = 0;
  String? title;
  String? content;
  String? translation;
  MediaModel? voice;

  VocabDescriptionSampleModel();

  VocabDescriptionSampleModel.fromMap(Map map) {
    order = map['order']?? 0;
    type = map['type'];
    title = map['title'];
    content = map['content'];
    translation = map['translation'];

    if(map['voice'] is Map){
      voice = MediaModel.fromMap(map['voice']);
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['order'] = order;
    map['type'] = type;
    map['title'] = title;
    map['content'] = content;
    map['translation'] = translation;
    map['voice'] = voice?.toMap();

    return map;
  }
}