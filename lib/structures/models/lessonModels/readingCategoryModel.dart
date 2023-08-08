import 'package:iris_tools/api/helpers/mathHelper.dart';

class ReadingCategoryModel {
  String id = '';
  String title = '';
  //double reviewProgress = 0;
  double progress = 0;

  ReadingCategoryModel();

  ReadingCategoryModel.fromMap(Map map) {
    id = map['id'];
    title = map['title'];
    //reviewProgress =  MathHelper.clearToDouble(map['reviewProgress']);

    progress = MathHelper.clearToDouble(map['progress']);
    progress = MathHelper.fixPrecision(progress, 1);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['id'] = id;
    map['title'] = title;
    //map['reviewProgress'] = reviewProgress;
    map['progress'] = progress;

    return map;
  }

  void matchBy(ReadingCategoryModel others){
    id = others.id;
    title = others.title;
    progress = others.progress;
    //exerciseProgress = others.exerciseProgress;
  }
}
