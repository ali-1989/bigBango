
class ProvinceModel {
  late int id;
  late String name;

  ProvinceModel();

  ProvinceModel.fromMap(Map map){
    id = map['id'];
    name = map['name'];
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;

    return map;
  }
}