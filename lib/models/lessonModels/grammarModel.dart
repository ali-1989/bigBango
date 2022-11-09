import 'package:app/models/lessonModels/iSegmentModel.dart';
import 'package:app/models/mediaModel.dart';
import 'package:app/tools/app/appImages.dart';

class GrammarModel extends ISegmentModel {
  MediaModel? media;

  GrammarModel(){
    _init();
  }

  void _init(){
    title = 'گرامر';
    engTitle = 'Grammar';
    icon = AppImages.grammarIco;
  }

  GrammarModel.fromMap(Map map):super.fromMap(map) {
    _init();

    media = MediaModel();
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    map[''] = media?.toMap();

    return map;
  }
}
