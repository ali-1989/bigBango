import 'package:app/structures/models/examModel.dart';
import 'package:app/structures/models/mediaModel.dart';

class ListeningModel {
  String id = '';
  String title = '';
  MediaModel? voice;
  late ExamModel quiz;

  ListeningModel();

  ListeningModel.fromMap(Map map) {
    final voiceTemp = map['voice'];
    final quizTemp = map['quiz'];

    id = map['id'];
    title = map['title'];

    if(voiceTemp != null) {
      voice = MediaModel.fromMap(voiceTemp);
    }

    if(quizTemp != null) {
      quiz = ExamModel.fromMap(quizTemp);
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['id'] = id;
    map['title'] = title;
    map['voice'] = voice?.toMap();
    map['quiz'] = quiz.toMap();

    return map;
  }
}
