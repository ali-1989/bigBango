import 'package:app/models/lessonModels/grammarModel.dart';
import 'package:app/models/lessonModels/readingModel.dart';
import 'package:app/models/lessonModels/speakingModel.dart';
import 'package:app/models/lessonModels/vocabModel.dart';
import 'package:app/system/keys.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';

class LessonModel {
  late int id;
  late String title;
  bool isLock = false;
  int number = 0;
  int improvementPercentage = 0;
  VocabModel? vocabModel;
  GrammarModel? grammarModel;
  ReadingModel? readingModel;
  SpeakingModel? speakingModel;

  LessonModel();

  LessonModel.fromMap(Map map) {
    id = map[Keys.id];
    title = map[Keys.title];
    isLock = map['isLock'];
    number = map['number']?? 0;
    improvementPercentage = MathHelper.clearToInt(map['progress']);

    if(map['vocabulary'] is Map) {
      vocabModel = VocabModel.fromMap(map['vocabulary']);
    }

    if(map['vocabulary'] is Map) {
      grammarModel = GrammarModel.fromMap(map['vocabulary']);
    }

    if(map['vocabulary'] is Map) {
      readingModel = ReadingModel.fromMap(map['vocabulary']);
    }

    if(map['vocabulary'] is Map) {
      speakingModel = SpeakingModel.fromMap(map['vocabulary']);
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[Keys.id] = id;
    map[Keys.title] = title;
    map['number'] = number;
    map['isLock'] = isLock;
    map['progress'] = improvementPercentage;
    map['vocabulary'] = vocabModel?.toMap();

    return map;
  }
}
