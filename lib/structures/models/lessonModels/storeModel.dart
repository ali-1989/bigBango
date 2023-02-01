import 'package:app/system/keys.dart';

class StoreModel {
  late int id;
  late String name;
  int order = 0;
  List<StoreLessonModel> lessons = [];

  StoreModel();

  StoreModel.fromMap(Map map) {
    final courseLevel = map['courseLevel'];
    final lessonsMap = map['lessons'];

    id = courseLevel[Keys.id];
    name = courseLevel[Keys.name];
    order = courseLevel['order']?? 0;

    if(lessonsMap is List) {
      lessons = (map['lessons'] as List).map<StoreLessonModel>((e) => StoreLessonModel.fromMap(e)).toList();
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    final inMap = <String, dynamic>{};

    inMap[Keys.id] = id;
    inMap[Keys.name] = name;
    inMap['order'] = order;

    map['courseLevel'] = inMap;
    map['lessons'] = lessons.map((e) => e.toMap()).toList();

    return map;
  }

  void matchBy(StoreModel others){
    id = others.id;
    name = others.name;
    order = others.order;
    lessons = others.lessons;
  }
}
///=================================================================================
class StoreLessonModel {
  late int id;
  late String title;
  int number = 0;
  late int amount;

  StoreLessonModel();

  StoreLessonModel.fromMap(Map map) {
    id = map[Keys.id];
    title = map[Keys.title];
    amount = map['amount']?? 0;
    number = map['number']?? 0;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[Keys.id] = id;
    map[Keys.title] = title;
    map['number'] = number;
    map['amount'] = amount;

    return map;
  }

  void matchBy(StoreLessonModel others){
    id = others.id;
    number = others.number;
    title = others.title;
    amount = others.amount;
  }
}
