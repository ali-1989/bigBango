import 'package:app/structures/injectors/segmentInjector.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:app/structures/models/lessonModels/vocabularySegmentModel.dart';

class VocabIdiomsPageInjector implements SegmentInjector {
  @override
  covariant late VocabularySegmentModel segment;

  @override
  late LessonModel lessonModel;

  VocabIdiomsPageInjector(this.lessonModel) : segment = lessonModel.vocabModel!;

  VocabIdiomsPageInjector.from(SegmentInjector parent){
    lessonModel = parent.lessonModel;
    segment = parent.segment as VocabularySegmentModel;
  }
}