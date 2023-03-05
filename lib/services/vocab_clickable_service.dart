import 'dart:async';

import 'package:app/structures/middleWares/requester.dart';

class VocabClickableService {
  static final requester = Requester();

  VocabClickableService._();

  static Future<Map?> requestVocab(String id) {
    requester.dispose();
    Completer<Map?> com = Completer();

    requester.httpRequestEvents.onFailState = (req, res) async {
      com.complete(null);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      com.complete(res['data']);
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/vocabularies/details?Id=$id');
    requester.request();

    return com.future;
  }

  static Future<Map?> requestIdioms(String id) {
    requester.dispose();
    Completer<Map?> com = Completer();

    requester.httpRequestEvents.onFailState = (req, res) async {
      com.complete(null);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      com.complete(res['data']);
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/idioms/details?Id=$id');
    requester.request();

    return com.future;
  }
}