import 'package:app/managers/settings_manager.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/services/jwt_service.dart';
import 'package:app/structures/models/cityModel.dart';
import 'package:app/structures/models/courseLevelModel.dart';
import 'package:app/structures/models/mediaModel.dart';
import 'package:app/system/keys.dart';

class UserModel {
  late String userId;
  String? name;
  String? lastName;
  DateTime? birthDate;
  String? mobile;
  int? gender;
  Token? token;
  MediaModel? avatarModel;
  String? email;
  String? iban;
  CourseLevelModel? courseLevel;
  CityModel? cityModel;
  //---------------- locale
  DateTime? loginDate;

  UserModel();

  UserModel.fromMap(Map map, {String? domain}) {
    final tLoginDate = map[Keys.setting$lastLoginDate];
    final brDate = map[Keys.birthdate];
    //final regDate = map[Keys.registerDate];

    userId = map[Keys.userId].toString();
    name = map[Keys.firstName];
    lastName = map[Keys.lastName];
    mobile = map[Keys.mobileNumber]?.toString();
    gender = map[Keys.gender];
    email = map['email'];
    iban = map['iban'];
    courseLevel = SettingsManager.getCourseLevelById(map['courseLevelId']?? 0);

    if(map[Keys.token] is Map) {
      token = Token.fromMap(map[Keys.token]);
    }
    else if(map[Keys.token] is String) {
      token = Token()..token = map[Keys.token];
      token?.parseToken();
    }

    if(map['city'] is Map) {
      cityModel = CityModel.fromMap(map['city']);
    }

    if(map['refreshToken'] != null) {
      token?.refreshToken = map['refreshToken'];
    }

    if(map['avatar'] is Map) {
      avatarModel = MediaModel.fromMap(map['avatar']);
    }

    if(brDate is int) {
      birthDate = DateHelper.milToDateTime(brDate);
    }
    else if(brDate is String) {
      birthDate = DateHelper.tsToSystemDate(brDate);
    }

    //profileModel?.url = UriTools.correctAppUrl(profileModel?.url, domain: domain);
    //----------------------- local
    if (tLoginDate is int) {
      loginDate = DateHelper.milToDateTime(tLoginDate);
    }
    else if (tLoginDate is String) {
      loginDate = DateHelper.tsToSystemDate(tLoginDate);
    }
  }
  
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map[Keys.userId] = userId;
    map[Keys.firstName] = name;
    map[Keys.lastName] = lastName;
    map[Keys.birthdate] = birthDate == null? null: DateHelper.toTimestamp(birthDate!);
    map[Keys.mobileNumber] = mobile;
    map[Keys.gender] = gender;
    map['avatar'] = avatarModel?.toMap();
    map['city'] = cityModel?.toMap();
    map['email'] = email;
    map['iban'] = iban;
    map['courseLevelId'] = courseLevel?.id;

    if (token != null) {
      map[Keys.token] = token!.toMap();
    }

    //-------------------------- local
    map[Keys.setting$lastLoginDate] = loginDate == null ? null : DateHelper.toTimestamp(loginDate!);

    return map;
  }

  void matchBy(UserModel other) {
    userId = other.userId;
    name = other.name;
    lastName = other.lastName;
    birthDate = other.birthDate;
    mobile = other.mobile;
    gender = other.gender;
    avatarModel = other.avatarModel;
    email = other.email;
    courseLevel = other.courseLevel;
    cityModel = other.cityModel;
    token = other.token;

    //--------------------------------- local
    //_profilePath = read._profilePath;
    loginDate = other.loginDate;
  }

  String get nameFamily {
    return '$name $lastName';
  }

  int get age {
    if(birthDate == null) {
      return 0;
    }

    return DateHelper.calculateAge(birthDate!);
  }

  /*String get countryName {
    return CountryTools.countryShowNameByCountryIso(countryModel.countryIso?? 'US');
  }*/

  String? get avatarFileName {
    if(avatarModel != null && avatarModel?.id != null){
      return '${userId}_${avatarModel!.id}.jpg';
    }


    return '$userId.jpg';
  }

  bool hasAvatar(){
    return avatarModel != null && avatarModel!.fileLocation != null;
  }

  @override
  String toString(){
    return '$userId _ name: $name _ family: $lastName _ mobile: $mobile _ sex: $gender | token: ${token?.token} , refresh Token: ${token?.refreshToken} ';
  }
}
///=======================================================================================================
class Token {
  String? token;
  String? refreshToken;
  DateTime? expireDate;

  Token();

  Token.fromMap(Map json) {
    token = json[Keys.token];
    refreshToken = json['refreshToken'];
    expireDate = DateHelper.tsToSystemDate(json[Keys.expire]);

    parseToken();
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data[Keys.token] = token;
    data[Keys.expire] = DateHelper.toTimestampNullable(expireDate);
    data['refreshToken'] = refreshToken;

    return data;
  }

  void parseToken(){
    final jwt = JwtService.decodeToken(token?? '');
    final exp = jwt['exp'];

    if(exp != null && expireDate == null){
      expireDate = DateTime(1970, 1, 1);
      expireDate = expireDate!.add(Duration(seconds: exp));
    }
  }

  @override
  String toString(){
    return 'Token: $token | refreshToken: $refreshToken | expire Date: $expireDate';
  }
}
