import 'package:flutter/material.dart';

import 'package:app/system/keys.dart';
import 'package:app/tools/app/appHttpDio.dart';
import 'package:app/tools/app/appSnack.dart';

class CommonHttpHandler {
  CommonHttpHandler._();


  static bool processCommonRequestError(BuildContext context, HttpRequester requester, Map json) {
    int statusCode = requester.responseData?.statusCode?? 200;
    String? message = requester.getBodyAsJson()![Keys.message];

    /*if(statusCode == 429){
      AppSnack.showError(context, message!);
      return true;
    }*/

    AppSnack.showError(context, message!);
    return true;
  }
}
///=============================================================================
class HttpCodes {
  HttpCodes._();

  static int error_zoneKeyNotFound = 10;
  static int error_requestNotDefined = 15;
  static int error_userIsBlocked = 20;
  static int error_userNotFound = 25;
  static int error_parametersNotCorrect = 30;
  static int error_mustSendRequesterUserId = 33;
  static int error_databaseError = 35;
  static int error_internalError = 40;
  static int error_isNotJson = 45;
  static int error_dataNotExist = 50;
  static int error_tokenNotCorrect = 55;
  static int error_existThis = 60;
  static int error_canNotAccess = 65;
  static int error_youMustRegisterForThis = 66;
  static int error_operationCannotBePerformed = 70;
  static int error_notUpload = 75;
  static int error_userNamePassIncorrect = 80;
  static int error_userMessage = 85;
  static int error_translateMessage = 86;
  static int error_spacialError = 90;

  //------------ sections -----------------------------------------------------
  static const sec_command = 'command';
  static const sec_userData = 'UserData';
  //static const sec_ticketData = 'TicketData';
  //------------ commands -----------------------------------------------------
  static const com_forceLogOff = 'ForceLogOff';
  static const com_forceLogOffAll = 'ForceLogOffAll';
  static const com_talkMeWho = 'TalkMeWho';
  static const com_sendDeviceInfo = 'SendDeviceInfo';
  static const com_messageForUser = 'messageForUser';
  static const com_dailyText = 'dailyText';
  static const com_updateProfileSettings = 'UpdateProfileSettings';
}
