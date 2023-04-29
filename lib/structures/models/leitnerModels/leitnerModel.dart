import 'package:app/structures/models/leitnerModels/leitnerIdiomModel.dart';
import 'package:app/structures/models/leitnerModels/leitnerVocabModel.dart';

class LeitnerModel {
  String id = '';
  int contentType = 0;
  LeitnerVocabModel? vocabulary;
  LeitnerIdiomModel? idiom;

  LeitnerModel();

  LeitnerModel.fromMap(Map map){
    id = map['id'];
    contentType = map['contentType'];

    if(map['vocabulary'] is Map){
      vocabulary = LeitnerVocabModel.fromMap(map['vocabulary']);
    }

    if(map['idiom'] is Map){
      idiom = LeitnerIdiomModel.fromMap(map['idiom']);
    }
  }

  Map toMap(){
    final map = <String, dynamic>{};

    map['id'] = id;
    map['contentType'] = contentType;
    map['vocabulary'] = vocabulary?.toMap();
    map['idiom'] = idiom?.toMap();

    return map;
  }

  String getContent(){
    if(vocabulary != null){
      return vocabulary!.word;
    }

    return idiom!.content;
  }

  String getTranslate(){
    if(vocabulary != null){
      return vocabulary!.translation;
    }

    return idiom!.translation;
  }

  String? getPronunciation(){
    if(vocabulary != null){
      return vocabulary!.pronunciation;
    }

    return null;
  }
}