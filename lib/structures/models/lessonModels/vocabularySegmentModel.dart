import 'package:app/structures/models/lessonModels/iSegmentModel.dart';
import 'package:app/tools/app/appImages.dart';

class VocabularySegmentModel extends ISegmentModel {
  bool hasIdioms = false;

  VocabularySegmentModel(){
    _init();
  }

  void _init(){
    title = 'واژه آموزی';
    engTitle = 'Vocabulary';
    icon = AppImages.abc2Ico;
  }

  VocabularySegmentModel.fromMap(Map map):super.fromMap(map) {
    _init();
    hasIdioms = map['hasIdioms'];
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    map['hasIdioms'] = hasIdioms;

    return map;
  }
}
