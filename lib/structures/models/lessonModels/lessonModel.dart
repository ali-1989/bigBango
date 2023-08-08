import 'package:iris_tools/api/helpers/mathHelper.dart';

import 'package:app/structures/models/lessonModels/grammarSegmentModel.dart';
import 'package:app/structures/models/lessonModels/listeningSegmentModel.dart';
import 'package:app/structures/models/lessonModels/quizSegmentModel.dart';
import 'package:app/structures/models/lessonModels/readingSegmentModel.dart';
import 'package:app/structures/models/lessonModels/speakingSegmentModel.dart';
import 'package:app/structures/models/lessonModels/vocabSegmentModel.dart';
import 'package:app/structures/models/lessonModels/writingSegmentModel.dart';
import 'package:app/system/keys.dart';

class LessonModel {
  late int id;
  late String title;
  bool isLock = false;
  int number = 0;
  double improvementPercentage = 0;
  QuizSegmentModel? quizSegment;
  VocabularySegmentModel? vocabSegment;
  GrammarSegmentModel? grammarSegment;
  ReadingSegmentModel? readingSegment;
  ListeningSegmentModel? listeningSegment;
  WritingSegmentModel? writingSegment;
  SpeakingSegmentModel? speakingSegment;

  LessonModel();

  LessonModel.fromMap(Map map) {
    id = map[Keys.id];
    title = map[Keys.title];
    isLock = map['isLock']?? false;
    number = map['number']?? 0;

    {///progress
      improvementPercentage = MathHelper.clearToDouble(map['progress']);
      improvementPercentage = MathHelper.fixPrecision(improvementPercentage, 1);
    }

    if(map['vocabulary'] is Map) {
      vocabSegment = VocabularySegmentModel.fromMap(map['vocabulary']);
    }

    if(map['grammar'] is Map) {
      grammarSegment = GrammarSegmentModel.fromMap(map['grammar']);
    }

    if(map['readingCategory'] is Map) {
      readingSegment = ReadingSegmentModel.fromMap(map['readingCategory']);
    }

    if(map['listeningCategory'] is Map) {
      listeningSegment = ListeningSegmentModel.fromMap(map['listeningCategory']);
    }

    if(map['quizCategory'] is Map) {
      quizSegment = QuizSegmentModel.fromMap(map['quizCategory']);
    }

    if(map['writingCategories'] is List) {
      writingSegment = WritingSegmentModel.fromMap(map['writingCategories']);
    }

    if(map['speakingCategories'] is List) {
      speakingSegment = SpeakingSegmentModel.fromMap(map['speakingCategories']);
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[Keys.id] = id;
    map[Keys.title] = title;
    map['number'] = number;
    map['isLock'] = isLock;
    map['progress'] = improvementPercentage;
    map['vocabulary'] = vocabSegment?.toMap();
    map['grammar'] = grammarSegment?.toMap();
    map['reading'] = readingSegment?.toMap();
    map['listeningCategory'] = listeningSegment?.toMap();
    map['quizCategory'] = quizSegment?.toMap();
    map['writingCategories'] = writingSegment?.toMap();
    map['speakingCategories'] = speakingSegment?.toMap();

    return map;
  }

  void matchBy(LessonModel others){
    id = others.id;
    quizSegment = others.quizSegment;
    number = others.number;
    title = others.title;
    improvementPercentage = others.improvementPercentage;
    isLock = others.isLock;

    if(others.vocabSegment != null) {
      vocabSegment?.matchBy(others.vocabSegment!);
    }

    if(others.grammarSegment != null) {
      grammarSegment?.matchBy(others.grammarSegment!);
    }

    if(others.readingSegment != null) {
      readingSegment?.matchBy(others.readingSegment!);
    }

    if(others.listeningSegment != null) {
      listeningSegment?.matchBy(others.listeningSegment!);
    }

    if(others.quizSegment != null) {
      quizSegment?.matchBy(others.quizSegment!);
    }

    if(others.writingSegment != null) {
      writingSegment?.matchBy(others.writingSegment!);
    }

    if(others.listeningSegment != null) {
      listeningSegment?.matchBy(others.listeningSegment!);
    }
  }

  @override
  String toString() {
    return 'id:$id | title:$title | number:$number | isLock:$isLock | reading:[${readingSegment.toString()}]';
  }
}
