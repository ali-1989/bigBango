// ignore_for_file: non_constant_identifier_names

class Keys {
  Keys._();

  static const ok = 'ok';
  static const error = 'error';
  static const password = 'password';
  static const token = 'token';
  static const expire = 'expire';
  static const value = 'value';
  static const name = 'name';
  static const firstName = 'firstName';
  static const key = 'key';
  static const lastName = 'lastName';
  static const userId = 'id';
  static const gender = 'gender';
  static const birthdate = 'birthDate';
  static const title = 'title';
  static const type = 'type';
  static const domain = 'domain';
  static const data = 'data';
  static const date = 'date';
  static const state = 'state';
  static const mobileNumber = 'phoneNumber';
  static const phoneCode = 'phone_code';
  static const countryIso = 'country_iso';
  static const path = 'path';
  static const uri = 'uri';
  static const url = 'url';
  static const id = 'id';
  static const description = 'description';
  static const languageIso = 'language_iso';
  static const message = 'message';
  //----- common settings key -----------------------------------------------------------------
  static const setting$lastLoginDate = 'last_login_date';
  //static const setting$toBackgroundTs = 'to_background_ts';
  static const setting$appSettings = 'app_settings';
  static const setting$fontThemeData = 'font_theme_data';
  static const setting$colorThemeName = 'color_theme_name';
  static const setting$lastForegroundTs = 'last_foreground_ts';
  static const setting$confirmOnExit = 'confirm_on_exit';
  static const setting$notificationChanelKey = 'notification_chanel_key';
  static const setting$notificationChanelGroup = 'notification_chanel_group';
  static const setting$notificationModel = 'notification_model';
  static const setting$currentVersion = 'current_version';
  static const setting$webDeviceId = 'web_device_id';
  //----- app settings key -----------------------------------------------------------------
  static const setting$registerPhoneNumber = 'register_phone_number';
  static const setting$registerPhoneNumberTs = 'register_phone_number_ts';

  static String genDownloadKey_userAvatar(int userId) {
    return 'downloadUserAvatar_$userId';
  }
}
