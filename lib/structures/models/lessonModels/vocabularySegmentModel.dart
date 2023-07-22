import 'package:app/structures/models/lessonModels/iSegmentModel.dart';
import 'package:app/tools/app/appImages.dart';

class VocabularySegmentModel extends ISegmentModel {
  List<String> vocabularyCategories = [];
  List<String> idiomCategories = [];

  VocabularySegmentModel(){
    _init();
  }

  void _init(){
    title = 'واژه آموزی';
    engTitle = 'Vocabulary';
    icon = AppImages.abc2Ico;
  }

  VocabularySegmentModel.fromMap(Map map):super.fromMap(map) {
    print('@@@@@@@@@@@@@@vocab@@@@@@@@@@@@@@@@@');
    print(map);
    print('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');

    if(map['vocabularyCategories'] is List) {
      vocabularyCategories.addAll((map['vocabularyCategories'] as List).map((e) => e.toString()));
    }

    if(map['idiomCategories'] is List) {
      idiomCategories.addAll((map['idiomCategories'] as List).map((e) => e.toString()));
    }
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    map['title'] = title;
    map['vocabularyCategories'] = vocabularyCategories;
    map['idiomCategories'] = idiomCategories;

    return map;
  }

  void matchBy(VocabularySegmentModel others){
    id = others.id;
    title = others.title;
    progress = others.progress;
    vocabularyCategories = others.vocabularyCategories;
    idiomCategories = others.idiomCategories;
  }
}
