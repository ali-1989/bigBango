import 'package:iris_tools/api/helpers/mathHelper.dart';

class GrammarCategoryModel {
  String id = '';
  String title = '';
  double reviewProgress = 0;
  double exerciseProgress = 0;
  double progress = 0;

  GrammarCategoryModel();

  GrammarCategoryModel.fromMap(Map map) {

    id = map['id'];
    title = map['title'];
    reviewProgress = MathHelper.clearToDouble(map['reviewProgress']);
    exerciseProgress = MathHelper.clearToDouble(map['exerciseProgress']);

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
}
