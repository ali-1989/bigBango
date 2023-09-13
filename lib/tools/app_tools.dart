import 'package:flutter/material.dart';


import 'package:app/structures/injectors/grammarPagesInjector.dart';
import 'package:app/structures/injectors/listeningPagesInjector.dart';
import 'package:app/structures/injectors/readingPagesInjector.dart';

import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:app/views/pages/grammar_page.dart';
import 'package:app/views/pages/listening_page.dart';
import 'package:app/views/pages/reading_page.dart';

class AppTools {
  AppTools._();


  static WidgetsBinding getAppWidgetsBinding() {
    return WidgetsBinding.instance;
  }

  static Widget? getNextPartOfLesson(LessonModel lessonModel){
    Widget? page;

    /*todo if((lessonModel.vocabSegmentModel?.hasIdioms?? false) && IrisNavigatorObserver.lastRoute() != (IdiomsPage).toString()){
      page = IdiomsPage(injector: VocabIdiomsPageInjector(lessonModel));
    }
    else*/ if (lessonModel.grammarSegment != null){
      page = GrammarPage(injector: GrammarPageInjector(lessonModel));
    }
    else if (lessonModel.readingSegment != null){
      page = ReadingPage(injector: ReadingPageInjector(lessonModel, categoryId: lessonModel.readingSegment!.categories.first.id));
    }
    else if (lessonModel.listeningSegment != null && lessonModel.listeningSegment!.listeningList.isNotEmpty){
      if (lessonModel.listeningSegment!.listeningList.length == 1) {
        page = ListeningPage(injector: ListeningPageInjector(lessonModel, lessonModel.listeningSegment!.listeningList[0].id));
      }
      else {
        page = ListeningPage(injector: ListeningPageInjector(lessonModel, lessonModel.listeningSegment!.listeningList[0].id));
      }
    }

    return page;
  }
}

