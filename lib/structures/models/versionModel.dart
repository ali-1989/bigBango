
class VersionModel {
  String newVersionName = '0';
  int newVersionCode = 0;
  String? description;
  bool restricted = false;
  String? directLink;
  String? storeLink;
  String? newVersionTs;


  VersionModel();

  VersionModel.fromMap(Map map) {
    newVersionName = map['code']?? '0';
    newVersionCode = map['new_version_code']?? 0;
    description = map['description'];
    restricted = map['isForce']?? false;
    directLink = map['downloadLink'];
    storeLink = map['storeLink'];
    newVersionTs = map['createdAt'];
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['code'] = newVersionName;
    map['new_version_code'] = newVersionCode;
    map['description'] = description;
    map['isForce'] = restricted;
    map['downloadLink'] = directLink;
    map['storeLink'] = storeLink;
    map['createdAt'] = newVersionTs;

    return map;
  }
}
