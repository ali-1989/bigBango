import 'package:app/structures/models/lessonModels/iSegmentModel.dart';
import 'package:app/structures/models/readingModel.dart';
import 'package:app/tools/app/appImages.dart';

class ReadingSegmentModel extends ISegmentModel {
  List<ReadingModel> categories = [];

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
      categories = map['items'].map<ReadingModel>((e) => ReadingModel.fromMap(e)).toList();
    }
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['items'] = categories.map((e) => e.toMap()).toList();

    return map;
  }

  void matchBy(ReadingSegmentModel others){
    title = others.title;
    progress = others.progress;
    categories.clear();
    categories.addAll(others.categories);
  }

  @override
  String toString() {
    return ' title:$title ';
  }
}