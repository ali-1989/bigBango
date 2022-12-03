import 'package:app/structures/injectors/segmentInjector.dart';
import 'package:app/structures/models/lessonModels/grammarSegmentModel.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';

class GrammarPageInjector implements SegmentInjector {
  @override
  covariant late GrammarSegmentModel segment;

  @override
  late LessonModel lessonModel;

  GrammarPageInjector(this.lessonModel) : segment = lessonModel.grammarModel!;

  GrammarPageInjector.from(SegmentInjector parent){
    lessonModel = parent.lessonModel;
    segment = parent.segment as GrammarSegmentModel;
  }
}