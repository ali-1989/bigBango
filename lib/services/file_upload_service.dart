import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/pathHelper.dart';
import 'package:iris_tools/models/two_state_return.dart';

import 'package:app/structures/enums/fileUploadType.dart';
import 'package:app/structures/middleWares/requester.dart';

class FileUploadService {
  FileUploadService._();

  /// final data = twoResponse.result1![Keys.data];
  static Future<TwoStateReturn<Map, Response>> uploadFiles(List<File> files, FileUploadType section){
    Requester requester = Requester();
    Completer<TwoStateReturn<Map, Response>> res = Completer();

    requester.httpRequestEvents.onFailState = (req, response) async {
      res.complete(TwoStateReturn(r2: response));
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final js = JsonHelper.jsonToMap(data)!;

      res.complete(TwoStateReturn(r1: js));
    };

    requester.httpItem.addFormField('Section', '${section.number}');

    for(final f in files){
      final fName = PathHelper.getFileName(f.path);

      requester.httpItem.addFormFile('Files', fName, f);
    }

    requester.prepareUrl(pathUrl: '/attachments/upload');
    //requester.prepareUrl(pathUrl: 'http://192.168.50.155:7054/v1/attachments/upload', isFull: true);
    requester.methodType = MethodType.post;
    requester.httpItem.headers = {'accept': 'application/json', 'Content-Type': 'multipart/form-data'};

    requester.debug = true;

    requester.request();
    return res.future;
  }

}

/*
 if(uploadRes.hasResult2()){
      final res = uploadRes.result2!.data;

      if(res != null){
        final js = JsonHelper.jsonToMap(res)?? {};
        final message = js['message'];

        if(message != null){
          AppSnack.showInfo(context, message);
          return null;
        }
      }
    }

    if(uploadRes.hasResult1()){
      final data = uploadRes.result1![Keys.data];

      if(data is List<String>) {
        return data;
      }
    }
* */
