
import 'package:iris_tools/api/helpers/mathHelper.dart';

class ReadingCategoryModel {
  String id = '';
  String title = '';
  int reviewProgress = 0;
  int exerciseProgress = 0;
  double progress = 0;

  ReadingCategoryModel();

  ReadingCategoryModel.fromMap(Map map) {
    id = map['id'];
    title = map['title'];
    reviewProgress = map['reviewProgress'];
    exerciseProgress = map['exerciseProgress'];

    progress = MathHelper.clearToDouble(map['progress']);
    progress = MathHelper.fixPrecision(progress, 1);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['id'] = id;
    map['title'] = title;
    map['reviewProgress'] = reviewProgress;
    map['exerciseProgress'] = exerciseProgress;
    map['progress'] = progress;

    return map;
  }

  void matchBy(ReadingCategoryModel others){
    id = others.id;
    title = others.title;
    progress = others.progress;
    reviewProgress = others.reviewProgress;
    exerciseProgress = others.exerciseProgress;
  }
}
