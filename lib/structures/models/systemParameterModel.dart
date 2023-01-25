
import 'package:app/structures/models/courseLevelModel.dart';

class SystemParameterModel {
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
  Map contacts = {};

  /*
    minSupportMinutes : 1
    maxSupportMinutes : 1
    lessonSupportMinutes : 1
    minuteAmount : 1
   */
  Map timeTableOption = {};


  SystemParameterModel();

  SystemParameterModel.fromMap(Map? map) {
    if(map == null){
      return;
    }

    contacts = map['contacts'];
    advertisingVideos = map['advertisingVideos'];
    timeTableOption = map['timeTableOption'];

    if(map['courseLevels'] is List) {
      courseLevels = (map['courseLevels'] as List).map<CourseLevelModel>((e) => CourseLevelModel.fromMap(e)).toList();
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['courseLevels'] = courseLevels.map((e) => e.toMap()).toList();
    map['advertisingVideos'] = advertisingVideos;
    map['contacts'] = contacts;
    map['timeTableOption'] = timeTableOption;

    return map;
  }
}
