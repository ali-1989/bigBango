import 'package:app/structures/models/lessonModels/iSegmentModel.dart';
import 'package:app/tools/app/appImages.dart';

class GrammarSegmentModel extends ISegmentModel {

  GrammarSegmentModel(){
    _init();
  }

  void _init(){
    title = 'گرامر';
    engTitle = 'Grammar';
    icon = AppImages.grammarIco;
  }

  GrammarSegmentModel.fromMap(Map map):super.fromMap(map) {
    _init();
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    return map;
  }
}
