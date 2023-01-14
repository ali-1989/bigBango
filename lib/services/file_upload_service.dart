
import 'dart:async';
import 'dart:io';

import 'package:app/structures/enums/fileUploadType.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/structures/models/towReturn.dart';
import 'package:dio/dio.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/pathHelper.dart';

class FileUploadService {
  FileUploadService._();

  static Future<TwoReturn<Map, Response>> uploadFiles(List<File> files, FileUploadType section){
    Requester requester = Requester();
    Completer<TwoReturn<Map, Response>> res = Completer();

    requester.httpRequestEvents.onFailState = (req, response) async {
      res.complete(TwoReturn(r2: response));
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final js = JsonHelper.jsonToMap(data)!;

      res.complete(TwoReturn(r1: js));
    };

    requester.httpItem.addFormField('Section', '${section.number()}');

    for(final f in files){
      final fName = PathHelper.getFileName(f.path);

      requester.httpItem.addFormFile('files', fName, f);
    }

    requester.prepareUrl(pathUrl: '/attachments/upload');
    //requester.prepareUrl(pathUrl: 'http://192.168.50.155:7054/v1/attachments/upload', isFull: true);
    requester.methodType = MethodType.post;

    requester.request(null, false);
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