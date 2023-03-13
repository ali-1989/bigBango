import 'package:iris_tools/api/helpers/mathHelper.dart';

import 'package:app/system/keys.dart';

abstract class ISegmentModel {
  int? id;
  double progress = 0;

  //-------------- local
  String title = '';
  String engTitle = '';
  String icon = '';

  ISegmentModel();

  ISegmentModel.fromMap(Map map) {
    id = map[Keys.id];
    progress = MathHelper.clearToDouble(map['progress']);
    progress = MathHelper.fixPrecision(progress, 1);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[Keys.id] = id;
    map['progress'] = progress;

    return map;
  }
}
