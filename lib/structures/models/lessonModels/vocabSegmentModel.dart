import 'package:app/structures/models/lessonModels/iSegmentModel.dart';
import 'package:app/structures/models/lessonModels/idiomCategoryModel.dart';
import 'package:app/structures/models/lessonModels/vocabCategoryModel.dart';
import 'package:app/tools/app/appImages.dart';

class VocabularySegmentModel extends ISegmentModel {
  List<VocabCategoryModel> vocabularyCategories = [];
  List<IdiomCategoryModel> idiomCategories = [];

  VocabularySegmentModel(){
    _init();
  }

  void _init(){
    title = 'واژه آموزی';
    engTitle = 'Vocabulary';
    icon = AppImages.abc2Ico;
  }

  VocabularySegmentModel.fromMap(Map map) :super.fromMap(map) {
    _init();

    if(map['vocabularyCategories'] is List) {
      vocabularyCategories.addAll((map['vocabularyCategories'] as List).map((e) => VocabCategoryModel.fromMap(e)));
    }

    if(map['idiomCategories'] is List) {
      idiomCategories.addAll((map['idiomCategories'] as List).map((e) => IdiomCategoryModel.fromMap(e)));
    }
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    map['title'] = title;
    map['vocabularyCategories'] = vocabularyCategories.map((e) => e.toMap()).toList();
    map['idiomCategories'] = idiomCategories.map((e) => e.toMap()).toList();

    return map;
  }

  void matchBy(VocabularySegmentModel others){
    title = others.title;
    progress = others.progress;

    vocabularyCategories.clear();
    vocabularyCategories.addAll(others.vocabularyCategories);

    if(hashCode != others.hashCode) {
      idiomCategories.clear();
      idiomCategories.addAll(others.idiomCategories);
    }
  }
}
