import 'package:app/models/lessonModels/iSegmentModel.dart';
import 'package:app/tools/app/appImages.dart';

class SpeakingModel extends ISegmentModel {
  SpeakingModel(){
    _init();
  }

  void _init(){
    title = 'شنیدن';
    engTitle = 'Speaking';
    icon = AppImages.speakerIco;
  }

  SpeakingModel.fromMap(Map map):super.fromMap(map) {
    _init();
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    return map;
  }
}