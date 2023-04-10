import 'package:app/structures/models/courseLevelModel.dart';

class SystemParameterModel {

  int expiryMinutes = 1;
  int tempClientSecretExpirySeconds = 1;
  /*
  {id: 1, name: پایه, order: 1},
  {id: 2, name: مبتدی, order: 2},
  {id: 3, name: متوسط, order: 3},
  {id: 4, name: پیشرفته, order: 4}
   */
  List<CourseLevelModel> courseLevels = [];

  // {login, determiningCourseLevel}
  Map advertisingVideos = {};

  /*
   "supportPhoneNumber": "031-32355205",
    "supportEmail": "support@bigbango.ir",
    "conditionTermsLink": "google.com",
    "description": "بیگ‌‌بنگو اپلیکیشن آموزش زبان"
   */
  Map contact = {};

  /*
    minSupportMinutes
    maxSupportMinutes
    determineCourseLevelMinutes
    minuteAmount
   */
  Map timeTable = {};


  /*
    code
    isForce
    downloadLink
    storeLink
    description
    createdAt
   */
  Map version = {};


  SystemParameterModel();

  SystemParameterModel.fromMap(Map? map) {
    if(map == null){
      return;
    }

    expiryMinutes = map['expiryMinutes']?? 1;
    tempClientSecretExpirySeconds = map['tempClientSecretExpirySeconds']?? 600;
    contact = map['contact']?? {};
    advertisingVideos = map['advertisingVideos']?? {};
    timeTable = map['timeTable']?? {};
    version = map['version']?? {};

    if(map['courseLevels'] is List) {
      courseLevels = (map['courseLevels'] as List).map<CourseLevelModel>((e) => CourseLevelModel.fromMap(e)).toList();
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['expiryMinutes'] = expiryMinutes;
    map['tempClientSecretExpirySeconds'] = tempClientSecretExpirySeconds;
    map['advertisingVideos'] = advertisingVideos;
    map['contact'] = contact;
    map['timeTable'] = timeTable;
    map['version'] = version;
    map['courseLevels'] = courseLevels.map((e) => e.toMap()).toList();

    return map;
  }
}
