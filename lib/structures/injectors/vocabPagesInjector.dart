import 'package:app/structures/injectors/segmentInjector.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:app/structures/models/lessonModels/vocabularySegmentModel.dart';
import 'package:app/structures/models/vocabModels/idiomModel.dart';
import 'package:app/structures/models/vocabModels/vocabModel.dart';

class VocabIdiomsPageInjector implements SegmentInjector {
  VocabModel? vocabModel;
  IdiomModel? idiomModel;

  @override
  covariant late VocabularySegmentModel? segment;

  @override
  late LessonModel lessonModel;

  VocabIdiomsPageInjector(this.lessonModel) : segment = lessonModel.vocabSegmentModel;

  VocabIdiomsPageInjector.from(SegmentInjector parent){
    lessonModel = parent.lessonModel;
    segment = parent.segment as VocabularySegmentModel;
  }
}