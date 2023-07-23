
class ReadingExerciseModel {
  String id = '';
  String title = '';
  int progress = 0;
  int count = 0;

  ReadingExerciseModel();

  ReadingExerciseModel.fromMap(Map map) {
    id = map['id'];
    title = map['title'];
    progress = map['progress'];
    count = map['count'];
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['id'] = id;
    map['title'] = title;
    map['progress'] = progress;
    map['count'] = count;

    return map;
  }
}
