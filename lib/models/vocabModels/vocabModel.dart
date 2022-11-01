
import 'package:app/models/mediaModel.dart';
import 'package:app/models/vocabModels/vocabDescriptionModel.dart';
import 'package:app/system/keys.dart';

class VocabModel {
  late String id;
  late String word;
  late String translation;
  String? pronunciation;
  List<VocabDescriptionModel> descriptions = [];
  int order = 0;
  int? britishVoiceId;
  int? americanVoiceId;
  bool inLeitner = false;
  MediaModel? image;


  VocabModel();

  VocabModel.fromMap(Map map) {
    id = map[Keys.id];
    word = map['word'];
    translation = map['translation'];
    pronunciation = map['pronunciation'];
    order = map['order'] ?? 0;
    inLeitner = map['inLeitner'] ?? false;

    if (map['image'] is Map) {
      image = MediaModel.fromMap(map['image']);
    }

    if (map['descriptions'] is List) {
      final List dList = map['descriptions'];

      for(final k in dList) {
        descriptions.add(VocabDescriptionModel.fromMap(k));
      }
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[Keys.id] = id;
    map['word'] = word;
    map['translation'] = translation;
    map['pronunciation'] = pronunciation;
    map['order'] = order;
    map['inLeitner'] = inLeitner;
    map['image'] = image?.toMap();
    map['descriptions'] = descriptions.map((e) => e.toMap()).toList();

    return map;
  }
}