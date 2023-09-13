import 'package:app/structures/models/lessonModels/iSegmentModel.dart';
import 'package:app/structures/models/lessonModels/writingCategoryModel.dart';
import 'package:app/tools/app/app_images.dart';

class WritingSegmentModel extends ISegmentModel {
  List<WritingCategoryModel> categories = [];

  WritingSegmentModel(){
    _init();
  }

  void _init(){
    title = 'نوشتن';
    engTitle = 'Writing';
    icon = AppImages.writingIco;
  }

  WritingSegmentModel.fromMap(List map) :super.fromMap({}) {
    _init();

    for(final itm in map){
      categories.add(WritingCategoryModel.fromMap(itm));
    }
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['items'] = categories.map((e) => e.toMap()).toList();

    return map;
  }

  void matchBy(WritingSegmentModel others){
    title = others.title;
    progress = others.progress;
    categories.clear();
    categories.addAll(others.categories);
  }
}
