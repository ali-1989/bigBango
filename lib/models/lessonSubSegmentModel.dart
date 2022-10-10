import 'package:app/system/keys.dart';

class LessonSubSegmentModel {
  late int id;
  late String segmentName;
  late String title;
  late dynamic icon;
  bool isExam = false;

  LessonSubSegmentModel();

  LessonSubSegmentModel.fromMap(Map map) {
    id = map[Keys.id];
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[Keys.id] = id;
    map[Keys.title] = title;

    return map;
  }
}
