import 'package:app/structures/models/lessonModels/iSegmentModel.dart';
import 'package:app/structures/models/lessonModels/quizCategoryModel.dart';
import 'package:app/tools/app/appImages.dart';

class QuizSegmentModel extends ISegmentModel {
  List<QuizCategoryModel> categories = [];

  QuizSegmentModel(){
    _init();
  }

  void _init(){
    title = 'آزمون';
    engTitle = 'Quiz';
    icon = AppImages.abc2Ico;
  }

  QuizSegmentModel.fromMap(Map map) :super.fromMap(map) {
    _init();

    if(map['items'] is List) {
      categories.addAll((map['items'] as List).map((e) => QuizCategoryModel.fromMap(e)));
    }
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    map['title'] = title;
    map['items'] = categories.map((e) => e.toMap()).toList();

    return map;
  }

  void matchBy(QuizSegmentModel others){
    title = others.title;
    icon = others.icon;
    engTitle = others.engTitle;
    progress = others.progress;

    if(hashCode != others.hashCode) {
      categories.clear();
      categories.addAll(others.categories);
    }
  }
}
