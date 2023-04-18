import 'package:flutter/foundation.dart';

import 'package:iris_tools/dateSection/dateHelper.dart';

class MediaModel {
  String? id;
  String? fileLocation;
  String? path;
  DateTime? date;
  int? volume;
  int? fileType;
  Uint8List? bytes;

  MediaModel();

  MediaModel.fromMap(Map map){
    id = map['id'];
    fileLocation = map['fileLocation'];
    path = map['path'];
    fileType = map['fileType'];
    volume = map['volume'];
    date = DateHelper.tsToSystemDate(map['date']);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['fileLocation'] = fileLocation;
    map['path'] = path;
    map['volume'] = volume;
    map['fileType'] = fileType;

    if (date != null) {
      map['date'] = DateHelper.toTimestampNullable(date);
    }

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  void matchBy(MediaModel other) {
    //id = other.id;
    fileLocation = other.fileLocation;
    path = other.path;
    fileType = other.fileType;
    volume = other.volume;
    date = other.date;
  }
}
