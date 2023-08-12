import 'package:flutter/material.dart';

import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/views/pages/grammar_page.dart';
import 'package:app/views/pages/listening_page.dart';
import 'package:app/views/pages/reading_page.dart';
import 'package:app/structures/injectors/grammarPagesInjector.dart';
import 'package:app/structures/injectors/listeningPagesInjector.dart';
import 'package:app/structures/injectors/readingPagesInjector.dart';
import 'package:app/structures/mixins/dateFieldMixin.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';

class AppTools {
  AppTools._();

  static void sortList(List<DateFieldMixin> list, bool isAsc){
    if(list.isEmpty){
      return;
    }

    int sorter(DateFieldMixin d1, DateFieldMixin d2){
      return DateHelper.compareDates(d1.date, d2.date, asc: isAsc);
    }

    list.sort(sorter);
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

  static WidgetsBinding getAppWidgetsBinding() {
    return WidgetsBinding.instance;
  }
}

