import 'dart:async';

import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/pages/home_page.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:app/tools/app/appDb.dart';

class ReviewService {
  ReviewService._();

  static void sendReviews() async {
    final con = Conditions();
    //con.add(Condition(ConditionType.DefinedNotNull)..key = 'section'..value);

    final res = AppDB.db.query(AppDB.tbReviews, con);

    if(res.isNotEmpty){
      for(final row in res){
        if(row['ids'].length > 0) {
          requestSetReview(_getRowSection(row['section']), row['ids'].map<String>((e) => e.toString()).toList());
        }
      }
    }
  }

  static void addReviews(ReviewSection section, Set<String> ids) async {
    final con = Conditions();
    con.add(Condition()..key = 'section'..value = section.name);

    final data = {};
    data['section'] = section.name;
    data['ids'] = ids.toList();

    await AppDB.db.insertOrUpdateEx(AppDB.tbReviews, data, con, (old, n){
      final r = <dynamic>{};
      r.addAll(n['ids']?? []);
      r.addAll(old['ids']?? []);

      n['ids'] = r.map((key) => key.toString()).toList();

      return n;
    });
  }

  static void deleteReviews(ReviewSection section, List<String> ids) async {
    final con = Conditions();
    con.add(Condition()..key = 'section'..value = section.name);

    final data = {};
    data['section'] = section.name;
    data['ids'] = [];

    await AppDB.db.insertOrUpdateEx(AppDB.tbReviews, data, con, (old, n){
      (old['ids'] as List).removeWhere((element) => ids.contains(element));

      return old;
    });
  }

  static Future<bool> requestSetReview(ReviewSection section, List<String> ids) async {
    final reviewRequester = Requester();
    final completer = Completer<bool>();

    reviewRequester.httpRequestEvents.onFailState = (req, res) async {
      completer.complete(false);
    };

    reviewRequester.httpRequestEvents.onStatusOk = (req, res) async {
      ReviewService.deleteReviews(ReviewSection.vocab, ids);

      completer.complete(true);
    };

    final js = <String, dynamic>{};
    js[_getReviewAddressKeyName(section)] = ids.toList();

    reviewRequester.bodyJson = js;
    reviewRequester.methodType = MethodType.post;
    reviewRequester.prepareUrl(pathUrl: _getReviewAddress(section));
    reviewRequester.request();

    return completer.future;
  }

  static Future<bool> requestUpdateReviews(LessonModel lessonModel) async {
    final reviewRequester = Requester();
    final completer = Completer<bool>();

    reviewRequester.httpRequestEvents.onFailState = (req, res) async {
      completer.complete(false);
    };

    reviewRequester.httpRequestEvents.onStatusOk = (req, res) async {
      final data = res['data'];

      final lesson = LessonModel.fromMap(data);
      lessonModel.matchBy(lesson);

      AssistController.updateAssistGlobal(HomePage.id$homePageHead);
      completer.complete(true);
    };

    reviewRequester.methodType = MethodType.get;
    reviewRequester.prepareUrl(pathUrl: '/lessons/details?LessonId=${lessonModel.id}');
    reviewRequester.request();

    return completer.future;
  }

  static String _getReviewAddress(ReviewSection section){
    switch(section){
      case ReviewSection.vocab:
        return '/vocabularies/review';
      case ReviewSection.idioms:
        return '/idioms/review';
      case ReviewSection.grammar:
        return '/grammars/review';
      case ReviewSection.reading:
        return '/reading/review';
    }
  }

  static String _getReviewAddressKeyName(ReviewSection section){
    switch(section){
      case ReviewSection.vocab:
        return 'vocabularyIds';
      case ReviewSection.idioms:
        return 'idiomIds';
      case ReviewSection.grammar:
        return 'grammarId';
      case ReviewSection.reading:
        return 'readingId';
    }
  }

  static ReviewSection _getRowSection(String section){
    for(final k in ReviewSection.values){
      if(k.name == section){
        return k;
      }
    }

    return ReviewSection.vocab;
  }
}
///================================================================================
enum ReviewSection {
  vocab,
  idioms,
  grammar,
  reading
}
