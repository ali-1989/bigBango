import 'package:app/structures/models/mediaModel.dart';
import 'package:app/system/keys.dart';

class LeitnerVocabModel {
  late String id;
  late String word;
  late String translation;
  String? pronunciation;
  String? description;
  MediaModel? britishVoice;
  MediaModel? americanVoice;

  LeitnerVocabModel();

  LeitnerVocabModel.fromMap(Map map) {
    id = map[Keys.id];
    word = map['word'];
    translation = map['translation'];
    pronunciation = map['pronunciation'];
    description = map['description'];

    if (map['britishVoice'] is Map) {
      britishVoice = MediaModel.fromMap(map['britishVoice']);
    }

    if (map['americanVoice'] is Map) {
      americanVoice = MediaModel.fromMap(map['americanVoice']);
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[Keys.id] = id;
    map['word'] = word;
    map['translation'] = translation;
    map['pronunciation'] = pronunciation;
    map['britishVoice'] = britishVoice?.toMap();
    map['americanVoice'] = americanVoice?.toMap();
    map['description'] = description;

    return map;
  }
}
