import 'dart:async';

import 'package:app/structures/middleWare/requester.dart';
import 'package:app/structures/models/vocabModels/vocabModel.dart';

class VocabClickableService {
  static final requester = Requester();

  VocabClickableService._();

  static Future<VocabModel?> requestVocab(String id) {
    requester.dispose();
    Completer<VocabModel?> com = Completer();

    requester.httpRequestEvents.onFailState = (req, res) async {
      com.complete(null);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final data = res['data'];

      final v = VocabModel.fromMap(data);
      com.complete(v);
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/vocabularies/details?Id=$id');
    requester.request();

    return com.future;
  }
}