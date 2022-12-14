import 'package:app/services/jwtService.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/models/dataModels/mediaModel.dart';

import 'package:app/system/keys.dart';


class UserModel {
  late String userId;
  String? name;
  String? family;
  DateTime? birthDate;
  String? mobile;
  int? gender;
  Token? token;
  MediaModel? profileModel;
  String? email;
  int? courseLevelId;
  //---------------- locale
  DateTime? loginDate;

  UserModel();

  UserModel.fromMap(Map map, {String? domain}) {
    final tLoginDate = map[Keys.setting$lastLoginDate];
    final brDate = map[Keys.birthdate];
    //final regDate = map[Keys.registerDate];

    userId = map[Keys.userId].toString();
    name = map[Keys.firstName];
    family = map[Keys.lastName];
    mobile = map[Keys.mobileNumber]?.toString();
    gender = map[Keys.gender];
    email = map['email'];
    courseLevelId = map['courseLevelId'];

    if(map[Keys.token] is Map) {
      token = Token.fromMap(map[Keys.token]);
    }
    else if(map[Keys.token] is String) {
      token = Token()..token = map[Keys.token];
      token?.parseToken();
    }

    if(map['profile_image_model'] != null) {
      profileModel = MediaModel.fromMap(map['profile_image_model']);
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
    map[Keys.lastName] = family;
    map[Keys.birthdate] = birthDate == null? null: DateHelper.toTimestamp(birthDate!);
    map[Keys.mobileNumber] = mobile;
    map[Keys.gender] = gender;
    map['profile_image_model'] = profileModel?.toMap();
    map['email'] = email;
    map['courseLevelId'] = courseLevelId;

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
    family = other.family;
    birthDate = other.birthDate;
    mobile = other.mobile;
    gender = other.gender;
    profileModel = other.profileModel;
    email = other.email;
    courseLevelId = other.courseLevelId;
    token = other.token;

    //--------------------------------- local
    //_profilePath = read._profilePath;
    loginDate = other.loginDate;
  }

  String get nameFamily {
    return '$name $family';
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
    if(profileModel == null || profileModel?.id == null){
      return null;
    }

    return '${userId}_${profileModel!.id}.jpg';
  }

  @override
  String toString(){
    return '$userId _ name: $name _ family: $family _ mobile: $mobile _ sex: $gender | token: ${token?.token} , refresh Token: ${token?.refreshToken} ';
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