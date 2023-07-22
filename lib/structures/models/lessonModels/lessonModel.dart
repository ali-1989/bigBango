import 'package:iris_tools/api/helpers/mathHelper.dart';

import 'package:app/structures/models/lessonModels/grammarSegmentModel.dart';
import 'package:app/structures/models/lessonModels/listeningSegmentModel.dart';
import 'package:app/structures/models/lessonModels/readingSegmentModel.dart';
import 'package:app/structures/models/lessonModels/vocabularySegmentModel.dart';
import 'package:app/system/keys.dart';

class LessonModel {
  late int id;
  late String title;
  bool isLock = false;
  int number = 0;
  double improvementPercentage = 0;
  List quizCategory = [];
  VocabularySegmentModel? vocabSegmentModel;
  GrammarSegmentModel? grammarModel;
  ReadingSegmentModel? readingModel;
  ListeningSegmentModel? listeningModel;

  LessonModel();

  LessonModel.fromMap(Map map) {
    print('-----------------------');
    print(map);
    print('-----------------------');
    id = map[Keys.id];
    title = map[Keys.title];
    isLock = map['isLock']?? false;
    number = map['number']?? 0;

    {///progress
      improvementPercentage = MathHelper.clearToDouble(map['progress']);
      improvementPercentage = MathHelper.fixPrecision(improvementPercentage, 1);
    }

    if(map['vocabulary'] is Map) {
      vocabSegmentModel = VocabularySegmentModel.fromMap(map['vocabulary']);
    }

    if(map['grammar'] is Map) {
      grammarModel = GrammarSegmentModel.fromMap(map['grammar']);
    }

    if(map['reading'] is Map) {
      readingModel = ReadingSegmentModel.fromMap(map['reading']);
    }

    if(map['listeningCategory'] is Map) {
      listeningModel = ListeningSegmentModel.fromMap(map['listeningCategory']);
    }

    if(map['quizCategory'] is Map) {
      quizCategory = map['quizCategory'];
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[Keys.id] = id;
    map[Keys.title] = title;
    map['number'] = number;
    map['isLock'] = isLock;
    map['progress'] = improvementPercentage;
    map['vocabulary'] = vocabSegmentModel?.toMap();
    map['grammar'] = grammarModel?.toMap();
    map['reading'] = readingModel?.toMap();
    map['listeningCategory'] = listeningModel?.toMap();

    return map;
  }

  void matchBy(LessonModel others){
    id = others.id;
    quizCategory = others.quizCategory;
    number = others.number;
    title = others.title;
    improvementPercentage = others.improvementPercentage;
    isLock = others.isLock;

    if(others.vocabSegmentModel != null) {
      vocabSegmentModel?.matchBy(others.vocabSegmentModel!);
    }

    if(others.grammarModel != null) {
      grammarModel?.matchBy(others.grammarModel!);
    }

    if(others.readingModel != null) {
      readingModel?.matchBy(others.readingModel!);
    }

    if(others.listeningModel != null) {
      listeningModel?.matchBy(others.listeningModel!);
    }
  }

  @override
  String toString() {
    return 'id:$id | title:$title | number:$number | isLock:$isLock | reading:[${readingModel.toString()}]';
  }
}
