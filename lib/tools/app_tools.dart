import 'package:app/pages/grammar_page.dart';
import 'package:app/pages/idioms_page.dart';
import 'package:app/pages/listening_page.dart';
import 'package:app/pages/reading_page.dart';
import 'package:app/structures/injectors/grammarPagesInjector.dart';
import 'package:app/structures/injectors/listeningPagesInjector.dart';
import 'package:app/structures/injectors/readingPagesInjector.dart';
import 'package:app/structures/injectors/vocabPagesInjector.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:flutter/material.dart';
import 'package:iris_route/iris_route.dart';

import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:app/structures/mixins/dateFieldMixin.dart';

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

    if((lessonModel.vocabSegmentModel?.hasIdioms?? false) && IrisNavigatorObserver.lastRoute() != (IdiomsPage).toString()){
      page = IdiomsPage(injector: VocabIdiomsPageInjector(lessonModel));
    }
    else if (lessonModel.grammarModel != null){
      page = GrammarPage(injector: GrammarPageInjector(lessonModel));
    }
    else if (lessonModel.readingModel != null){
      page = ReadingPage(injector: ReadingPageInjector(lessonModel));
    }
    else if (lessonModel.listeningModel != null && lessonModel.listeningModel!.listeningList.isNotEmpty){
      if (lessonModel.listeningModel!.listeningList.length == 1) {
        page = ListeningPage(injector: ListeningPageInjector(lessonModel, lessonModel.listeningModel!.listeningList[0].id));
      }
      else {
        page = ListeningPage(injector: ListeningPageInjector(lessonModel, lessonModel.listeningModel!.listeningList[0].id));
      }
    }

    return page;
  }


  static WidgetsBinding getAppWidgetsBinding() {
    return WidgetsBinding.instance;
  }

  static ClassicFooter classicFooter = const ClassicFooter(
    loadingText: '',
    idleText: '',
    noDataText: '',
    failedText: '',
    loadStyle: LoadStyle.ShowWhenLoading,
  );
}

