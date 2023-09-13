import 'package:app/structures/models/lessonModels/iSegmentModel.dart';
import 'package:app/structures/models/lessonModels/speakingCategoryModel.dart';
import 'package:app/tools/app/app_images.dart';

class SpeakingSegmentModel extends ISegmentModel {
  List<SpeakingCategoryModel> categories = [];

  SpeakingSegmentModel(){
    _init();
  }

  void _init(){
    title = 'گفتن';
    engTitle = 'Speaking';
    icon = AppImages.micBlack;
  }

  SpeakingSegmentModel.fromMap(List map) :super.fromMap({}) {
    _init();

    for(final itm in map){
      categories.add(SpeakingCategoryModel.fromMap(itm));
    }
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['items'] = categories.map((e) => e.toMap()).toList();

    return map;
  }

  void matchBy(SpeakingSegmentModel others){
    title = others.title;
    progress = others.progress;
    categories.clear();
    categories.addAll(others.categories);
  }
}
