
class CityModel {
  late int id;
  int? provinceId;
  late String name;

  CityModel();

  CityModel.fromMap(Map map){
    id = map['id'];
    provinceId = map['provinceId'];
    name = map['name'];
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['provinceId'] = provinceId;
    map['name'] = name;

    return map;
  }
}