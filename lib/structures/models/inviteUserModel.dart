import 'package:app/structures/models/mediaModel.dart';

class InviteUserModel {
  String id = '';
  String firstName = '';
  String lastName = '';
  MediaModel? avatar;

  InviteUserModel.fromMap(Map map){
    id = map['id'];
    firstName = map['firstName'];
    lastName = map['lastName'];

    if(map['avatar'] is Map) {
      avatar = MediaModel.fromMap(map['avatar']);
    }
  }

  String getName(){
    return '$firstName $lastName';
  }

  String getFirstChar(){
    return getName().substring(0,1);
  }
}