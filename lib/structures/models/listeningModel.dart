import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/structures/models/mediaModel.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';

class ListeningModel {
  String id = '';
  String title = '';
  MediaModel? voice;
  late ExamModel quiz;
  double progress = 0;

  ListeningModel();

  ListeningModel.fromMap(Map map) {
    id = map['id'];
    title = map['title'];
    progress = MathHelper.clearToDouble(map['progress']);
    progress = MathHelper.fixPrecision(progress, 1);

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
    map['progress'] = progress;

    return map;
  }
}
