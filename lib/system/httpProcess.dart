import 'package:app/system/keys.dart';
import 'package:app/tools/app/appHttpDio.dart';
import 'package:flutter/material.dart';

import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appSnack.dart';


class HttpProcess {
  HttpProcess._();

  static bool processCommonRequestError(BuildContext context, HttpRequester requester, Map json) {
    int statusCode = requester.responseData?.statusCode?? 200;
    String? message = requester.getBodyAsJson()![Keys.message];

    if(statusCode == 429){
      AppSnack.showError(context, message!);
      return true;
    }

    return false;
  }
}
