import 'package:iris_tools/api/helpers/mathHelper.dart';

abstract class ISegmentModel {
  double progress = 0;

  //-------------- local
  int? id;//todo.
  String title = '';
  String engTitle = '';
  String icon = '';

  ISegmentModel();

  ISegmentModel.fromMap(Map map) {
    progress = MathHelper.clearToDouble(map['progress']);
    progress = MathHelper.fixPrecision(progress, 1);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['progress'] = progress;

    return map;
  }
}
