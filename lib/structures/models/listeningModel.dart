import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/structures/models/mediaModel.dart';

class ListeningModel {
  String id = '';
  String title = '';
  MediaModel? voice;
  late ExamModel quiz;

  ListeningModel();

  ListeningModel.fromMap(Map map) {
    id = map['id'];
    title = map['title'];

    if(map['voice'] != null) {
      voice = MediaModel.fromMap(map['voice']);
    }

    if(map['exercise'] != null) {
      quiz = ExamModel.fromMap(map['exercise']);
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
