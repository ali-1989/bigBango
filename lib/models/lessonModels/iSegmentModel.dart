
import 'package:app/system/keys.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';

abstract class ISegmentModel {
  int? id;
  int progress = 0;

  String title = '';
  String engTitle = '';
  String icon = '';

  ISegmentModel();

  ISegmentModel.fromMap(Map map) {
    id = map[Keys.id];
    progress = MathHelper.clearToInt(map['progress']);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[Keys.id] = id;
    map['progress'] = progress;

    return map;
  }
}