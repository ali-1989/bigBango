import 'package:app/models/lessonModels/iSegmentModel.dart';
import 'package:app/tools/app/appImages.dart';

class VocabModel extends ISegmentModel {
  bool hasIdioms = false;

  VocabModel(){
    _init();
  }

  void _init(){
    title = 'واژه آموزی';
    engTitle = 'Vocabulary';
    icon = AppImages.abc2Ico;
  }

  VocabModel.fromMap(Map map):super.fromMap(map) {
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
