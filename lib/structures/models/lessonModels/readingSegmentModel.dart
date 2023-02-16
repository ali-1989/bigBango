import 'package:app/structures/models/lessonModels/iSegmentModel.dart';
import 'package:app/structures/models/readingModel.dart';
import 'package:app/tools/app/appImages.dart';

class ReadingSegmentModel extends ISegmentModel {
  List<ReadingModel> readingList = [];

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

    if(map['title'] is String){
      title = map['title'];
    }

    if(map['items'] is List){
      readingList = map['items'].map<ReadingModel>((e) => ReadingModel.fromMap(e)).toList();
    }
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['items'] = readingList.map((e) => e.toMap()).toList();

    return map;
  }

  void matchBy(ReadingSegmentModel others){
    id = others.id;
    title = others.title;
    progress = others.progress;
    readingList.clear();
    readingList.addAll(others.readingList);
  }

  @override
  String toString() {
    String models = '';

    for(final x in readingList){
      models +=  '${x.segments}';
    }

    return 'id:$id | title:$title | models:{$models}';
  }
}