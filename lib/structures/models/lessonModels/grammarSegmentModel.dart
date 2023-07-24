import 'package:app/structures/models/lessonModels/grammarCategoryModel.dart';
import 'package:app/structures/models/lessonModels/iSegmentModel.dart';
import 'package:app/tools/app/appImages.dart';

class GrammarSegmentModel extends ISegmentModel {
  List<GrammarCategoryModel> categories = [];

  GrammarSegmentModel(){
    _init();
  }

  void _init(){
    title = 'گرامر';
    engTitle = 'Grammar';
    icon = AppImages.grammarIco;
  }

  GrammarSegmentModel.fromMap(Map map) :super.fromMap(map) {
    _init();

    if(map['items'] is List){
      for(final i in map['items']){
        categories.add(GrammarCategoryModel.fromMap(i));
      }
    }
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['items'] = categories.map((e) => e.toMap()).toList();

    return map;
  }

  void matchBy(GrammarSegmentModel others){
    title = others.title;
    progress = others.progress;

    if(hashCode != others.hashCode) {
      categories.clear();
      categories.addAll(others.categories);
    }
  }
}
