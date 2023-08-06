import 'package:iris_tools/api/helpers/mathHelper.dart';

import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/structures/models/mediaModel.dart';

class ListeningModel {
  String id = '';
  String title = '';
  MediaModel? voice;
  List<ExamModel> exams = [];
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

    if(map['exercises'] is List) {
      for(final x in map['exercises']){
        final e = ExamModel.fromMap(x);
        exams.add(e);
      }
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['id'] = id;
    map['title'] = title;
    map['voice'] = voice?.toMap();
    map['progress'] = progress;

    map['exercises'] = exams.map((e) => e.toMap()).toList();

    return map;
  }
}
