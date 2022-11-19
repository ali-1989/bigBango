import 'package:app/models/lessonModels/iSegmentModel.dart';
import 'package:app/models/mediaModel.dart';
import 'package:app/tools/app/appImages.dart';

class GrammarModel extends ISegmentModel {
  int order = 0;
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
    title = map['title'];
    order = map['order']?? 0;
    final video = map['video'];

    if(video != null) {
      media = MediaModel.fromMap(video);
    }
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    map['video'] = media?.toMap();

    return map;
  }
}
