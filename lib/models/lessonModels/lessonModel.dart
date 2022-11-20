import 'package:app/models/lessonModels/grammarSegmentModel.dart';
import 'package:app/models/lessonModels/readingSegmentModel.dart';
import 'package:app/models/lessonModels/speakingSegmentModel.dart';
import 'package:app/models/lessonModels/vocabularySegmentModel.dart';
import 'package:app/system/keys.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';

class LessonModel {
  late int id;
  late String title;
  bool isLock = false;
  int number = 0;
  int improvementPercentage = 0;
  VocabularySegmentModel? vocabModel;
  GrammarSegmentModel? grammarModel;
  ReadingSegmentModel? readingModel;
  SpeakingSegmentModel? speakingModel;

  LessonModel();

  LessonModel.fromMap(Map map) {
    id = map[Keys.id];
    title = map[Keys.title];
    isLock = map['isLock'];
    number = map['number']?? 0;
    improvementPercentage = MathHelper.clearToInt(map['progress']);

    if(map['vocabulary'] is Map) {
      vocabModel = VocabularySegmentModel.fromMap(map['vocabulary']);
    }

    if(map['vocabulary'] is Map) {
      grammarModel = GrammarSegmentModel.fromMap(map['vocabulary']);
    }

    if(map['vocabulary'] is Map) {
      readingModel = ReadingSegmentModel.fromMap(map['vocabulary']);
    }

    if(map['vocabulary'] is Map) {
      speakingModel = SpeakingSegmentModel.fromMap(map['vocabulary']);
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
