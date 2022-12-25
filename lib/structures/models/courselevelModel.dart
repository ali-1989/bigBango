
class CourseLevelModel {
  late int id;
  late String name;
  int order = 0;

  CourseLevelModel();

  CourseLevelModel.fromMap(Map js){
    id = js['id'] ?? 1;
    name = js['name'];
    order = js['order']?? 0;
  }

  Map<String, dynamic> toMap() {
    final js = <String, dynamic>{};

    js['id'] = id;
    js['name'] = name;
    js['order'] = order;

    return js;
  }
}