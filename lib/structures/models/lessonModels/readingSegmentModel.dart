import 'package:app/structures/models/lessonModels/iSegmentModel.dart';
import 'package:app/tools/app/appImages.dart';

class ReadingSegmentModel extends ISegmentModel {

  ReadingSegmentModel(){
    _init();
  }

  void _init(){
    title = 'خواندن';
    engTitle = 'Reading';
    icon = AppImages.readingIco;
  }

  ReadingSegmentModel.fromMap(Map map):super.fromMap(map) {
    _init();
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    return map;
  }
}