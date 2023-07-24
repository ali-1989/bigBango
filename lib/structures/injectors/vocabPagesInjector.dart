import 'package:app/structures/injectors/segmentInjector.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:app/structures/models/lessonModels/vocabSegmentModel.dart';
import 'package:app/structures/models/vocabModels/idiomModel.dart';
import 'package:app/structures/models/vocabModels/vocabModel.dart';

class VocabIdiomsPageInjector implements SegmentInjector {
  VocabModel? vocabModel;
  IdiomModel? idiomModel;
  String categoryId;

  @override
  covariant late VocabularySegmentModel? segment;

  @override
  late LessonModel lessonModel;

  VocabIdiomsPageInjector(this.lessonModel, this.categoryId) : segment = lessonModel.vocabSegment;

  VocabIdiomsPageInjector.from(SegmentInjector parent) : categoryId = ''{
    lessonModel = parent.lessonModel;
    segment = parent.segment as VocabularySegmentModel;
    categoryId = segment!.vocabularyCategories.first.id;
  }
}