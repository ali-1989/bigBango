import 'package:app/structures/injectors/segmentInjector.dart';
import 'package:app/structures/models/lessonModels/grammarSegmentModel.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';

class GrammarPageInjector implements SegmentInjector {
  String? id;

  @override
  covariant late GrammarSegmentModel segment;

  @override
  late LessonModel lessonModel;

  GrammarPageInjector(this.lessonModel, {this.id}) : segment = lessonModel.grammarSegment!;

  GrammarPageInjector.from(SegmentInjector parent, {this.id}){
    lessonModel = parent.lessonModel;
    segment = parent.segment as GrammarSegmentModel;
  }
}