import 'package:app/models/lessonModels/iSegmentModel.dart';
import 'package:app/tools/app/appImages.dart';

class ReadingModel extends ISegmentModel {

  ReadingModel(){
    _init();
  }

  void _init(){
    title = 'خواندن';
    engTitle = 'Reading';
    icon = AppImages.readingIco;
  }

  ReadingModel.fromMap(Map map):super.fromMap(map) {
    _init();
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    return map;
  }
}