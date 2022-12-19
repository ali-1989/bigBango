import 'package:app/structures/models/lessonModels/iSegmentModel.dart';
import 'package:app/tools/app/appImages.dart';

class VocabularySegmentModel extends ISegmentModel {
  bool hasIdioms = false;
  int count = 0;
  int reviewCount = 0;
  int idiomCount = 0;
  int idiomReviewCount = 0;

  VocabularySegmentModel(){
    _init();
  }

  void _init(){
    title = 'واژه آموزی';
    engTitle = 'Vocabulary';
    icon = AppImages.abc2Ico;
  }

  VocabularySegmentModel.fromMap(Map map):super.fromMap(map) {
    _init();
    hasIdioms = map['hasIdioms'];
    count = map['count']?? 1;
    reviewCount = map['reviewedCount']?? 0;

    if(map['idiom'] is Map){
      idiomCount = map['idiom']['count']?? 1;
      idiomReviewCount = map['idiom']['reviewedCount']?? 0;
    }

    if(count > 0) {
      progress = map['progress']?? ((reviewCount * 100 / count) + (idiomReviewCount * 100 / idiomCount)) /2;
    }
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    map['hasIdioms'] = hasIdioms;
    map['count'] = count;
    map['reviewedCount'] = reviewCount;
    map['idiom'] = {'count': idiomCount, 'reviewedCount': idiomReviewCount};

    return map;
  }
}
