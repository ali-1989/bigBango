import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/system.dart';
import 'package:platform_device_id/platform_device_id.dart';

import 'package:app/system/keys.dart';
import 'package:app/tools/app/appDb.dart';

class DeviceInfoTools {
  DeviceInfoTools._();

  static String? deviceId;
  static AndroidDeviceInfo? androidDeviceInfo;
  static IosDeviceInfo? iosDeviceInfo;
  static WebBrowserInfo? webDeviceInfo;

  static Future<void> prepareDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();

    if(System.isWeb()) {
      webDeviceInfo = await deviceInfoPlugin.webBrowserInfo;
    }
    else if (Platform.isAndroid) {
      androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    }
    else if (Platform.isIOS) {
      iosDeviceInfo = await deviceInfoPlugin.iosInfo;
    }
  }

  static Future<void> prepareDeviceId() async {
    deviceId = await getDeviceId();
  }

  static Future<String> getDeviceId() async {
    if(deviceId != null) {
      return SynchronousFuture<String>(deviceId!);
    }

    try {
      if(kIsWeb){
        deviceId = AppDB.fetchKv(Keys.setting$webDeviceId);

        if(deviceId == null) {
          final vendor = webDeviceInfo?.vendor ?? '';
          deviceId = 'web_${Generator.hashMd5('$vendor ${Generator.generateKey(10)}')}';

          AppDB.setReplaceKv(Keys.setting$webDeviceId, deviceId);
        }
      }
      /*else if() {
        deviceId = '${androidDeviceInfo?.brand}:${androidDeviceInfo?.id}';
      }*/
      else {
        deviceId = await PlatformDeviceId.getDeviceId;
      }
    }
    on PlatformException {
      deviceId = 'Failed:${Generator.generateDateIsoId(4)}';
    }

    return SynchronousFuture<String>(deviceId!);
  }

  static Map<String, dynamic> getDeviceInfo() {
    final js = <String, dynamic>{};

    if(kIsWeb){
      final br = webDeviceInfo?.userAgent;

      js['device_type'] = 'Web';
      js['model'] = webDeviceInfo?.appName;
      js['brand'] = br?.substring(0, min(50, br.length));
      js['api'] = webDeviceInfo?.platform;

      return js;
    }

    if (System.isAndroid()) {
      js['device_type'] = 'Android';
      js['model'] = androidDeviceInfo?.model;
      js['brand'] = androidDeviceInfo?.brand;
      js['api'] = androidDeviceInfo?.version.sdkInt.toString();
    }
    else if (System.isIOS()) {
      js['device_type'] = 'iOS';
      js['model'] = iosDeviceInfo?.model; //utsname.machine
      js['brand'] = iosDeviceInfo?.systemName;
      js['api'] = iosDeviceInfo?.utsname.version.toString();
    }
    else {
      js['device_type'] = 'unKnow';
    }

    return js;
  }
}
