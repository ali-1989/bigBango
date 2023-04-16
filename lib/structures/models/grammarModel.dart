import 'package:app/structures/models/mediaModel.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';

class GrammarModel {
  String id = '';
  String title = '';
  MediaModel? media;
  double reviewProgress = 0;
  double exerciseProgress = 0;
  double progress = 0;

  GrammarModel();

  GrammarModel.fromMap(Map map) {
    id = map['id'];
    title = map['title'];

    if(map['video'] is Map) {
      media = MediaModel.fromMap(map['video']);
    }

    progress = MathHelper.clearToDouble(map['progress']);
    progress = MathHelper.fixPrecision(progress, 1);

    reviewProgress = MathHelper.clearToDouble(map['reviewProgress']);
    reviewProgress = MathHelper.fixPrecision(reviewProgress, 1);

    exerciseProgress = MathHelper.clearToDouble(map['exerciseProgress']);
    exerciseProgress = MathHelper.fixPrecision(exerciseProgress, 1);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['id'] = id;
    map['title'] = title;
    map['video'] = media?.toMap();
    map['progress'] = progress;
    map['reviewProgress'] = reviewProgress;
    map['exerciseProgress'] = exerciseProgress;

    return map;
  }
}
