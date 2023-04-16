import 'package:app/structures/models/lessonModels/iSegmentModel.dart';
import 'package:app/tools/app/appImages.dart';

class VocabularySegmentModel extends ISegmentModel {
  bool hasIdioms = false;
  int count = 0;
  int reviewCount = 0;
  int idiomCount = 0;
  int idiomReviewCount = 0;
  List<String> reviewIds = [];
  List<String> idiomsReviewIds = [];

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

      if(map['idiom']['reviewIds'] is List) {
        reviewIds.addAll((map['idiom']['reviewIds'] as List).map((e) => e.toString()));
      }
    }

    if(map['reviewIds'] is List) {
      reviewIds.addAll((map['reviewIds'] as List).map((e) => e.toString()));
    }

    if(count > 0) {
      final p = map['progress'];

      if(p != null){
        progress = double.tryParse(p.toString())!;
      }
      else {
        progress = ((reviewCount * 100 / count) + (idiomReviewCount * 100 / idiomCount)) / 2;
      }
    }
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    map['hasIdioms'] = hasIdioms;
    map['count'] = count;
    map['reviewedCount'] = reviewCount;
    map['reviewIds'] = reviewIds;
    map['idiom'] = {'count': idiomCount, 'reviewedCount': idiomReviewCount, 'reviewIds': idiomsReviewIds};

    return map;
  }

  void matchBy(VocabularySegmentModel others){
    id = others.id;
    title = others.title;
    progress = others.progress;
    hasIdioms = others.hasIdioms;
    count = others.count;
    reviewCount = others.reviewCount;
    idiomReviewCount = others.idiomReviewCount;
    idiomCount = others.idiomCount;
    reviewIds = others.reviewIds;
    idiomsReviewIds = others.idiomsReviewIds;
  }

  double progressOfVocab(){
    return (reviewCount * 100 / count);
  }

  double progressOfIdioms(){
    return idiomReviewCount * 100 / idiomCount;
  }
}
