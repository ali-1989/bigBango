import 'package:app/models/lessonModels/iSegmentModel.dart';
import 'package:app/tools/app/appImages.dart';

class ListeningSegmentModel extends ISegmentModel {
  ListeningSegmentModel(){
    _init();
  }

  void _init(){
    title = 'شنیدن';
    engTitle = 'Listening';
    icon = AppImages.speakerIco;
  }

  ListeningSegmentModel.fromMap(Map map):super.fromMap(map) {
    _init();
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    return map;
  }
}