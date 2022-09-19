import 'package:app/models/lessonSegmentModel.dart';
import 'package:app/system/keys.dart';

class LessonModel {
  late int id;
  late String title;
  bool isLock = false;
  int order = 0;
  double improvementPercentage = 0;
  List<LessonSegmentModel> segments = [];

  LessonModel();

  LessonModel.fromMap(Map map) {
    id = map[Keys.id];
    title = map[Keys.title];
    order = map['order']?? 0;
    improvementPercentage = map['improvementPercentage']?? 0;

    _parseSegment(map['segments']?? []);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[Keys.id] = id;
    map[Keys.title] = title;
    map['order'] = order;
    map['improvementPercentage'] = improvementPercentage;
    map['segments'] = segments.map((e) => e.toMap()).toList();

    return map;
  }

  void _parseSegment(List list){
    for(final k in list){
      final m = LessonSegmentModel.fromMap(k);
      segments.add(m);
    }
  }
}
