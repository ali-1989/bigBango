import 'package:app/models/lessonSubSegmentModel.dart';
import 'package:app/system/keys.dart';

class LessonSegmentModel {
  late int id;
  double improvementPercentage = 0;
  List<LessonSubSegmentModel> subSegments = [];
  //----------------------------------
  late String title;
  late String englishTitle;

  LessonSegmentModel();

  LessonSegmentModel.fromMap(Map map) {
    id = map[Keys.id];
    improvementPercentage = map['improvementPercentage']?? 0;
    subSegments = map['improvementPercentage']?? 0;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[Keys.id] = id;
    map['improvementPercentage'] = improvementPercentage;

    map[Keys.title] = title;
    map['englishTitle'] = englishTitle;

    return map;
  }
}
