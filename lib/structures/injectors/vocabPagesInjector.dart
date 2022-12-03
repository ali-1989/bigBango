import 'package:app/structures/injectors/segmentInjector.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:app/structures/models/lessonModels/vocabularySegmentModel.dart';

class VocabPageInjector implements SegmentInjector {
  @override
  covariant late VocabularySegmentModel segment;

  @override
  late LessonModel lessonModel;

  VocabPageInjector(this.lessonModel) : segment = lessonModel.vocabModel!;

  VocabPageInjector.from(SegmentInjector parent){
    lessonModel = parent.lessonModel;
    segment = parent.segment as VocabularySegmentModel;
  }
}