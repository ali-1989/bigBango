
import 'package:app/structures/models/mediaModel.dart';
import 'package:app/structures/models/vocabModels/vocabDescriptionModel.dart';
import 'package:app/system/keys.dart';

class VocabModel {
  late String id;
  late String word;
  late String translation;
  String? pronunciation;
  List<VocabDescriptionModel> descriptions = [];
  int order = 0;
  bool inLeitner = false;
  bool showTranslation = false;
  MediaModel? britishVoice;
  MediaModel? americanVoice;
  MediaModel? image;


  VocabModel();

  VocabModel.fromMap(Map map) {
    id = map[Keys.id];
    word = map['word'];
    translation = map['translation'];
    pronunciation = map['pronunciation'];
    order = map['order'] ?? 0;
    inLeitner = map['inLeitner'] ?? false;
    showTranslation = map['showTranslation']?? false;

    if (map['image'] is Map) {
      image = MediaModel.fromMap(map['image']);
    }

    if (map['britishVoice'] is Map) {
      britishVoice = MediaModel.fromMap(map['britishVoice']);
    }

    if (map['americanVoice'] is Map) {
      americanVoice = MediaModel.fromMap(map['americanVoice']);
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
    map['descriptions'] = descriptions.map((e) => e.toMap()).toList();
    map['image'] = image?.toMap();
    map['britishVoice'] = britishVoice?.toMap();
    map['americanVoice'] = americanVoice?.toMap();
    map['showTranslation'] = showTranslation;

    return map;
  }
}