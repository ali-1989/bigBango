import 'package:app/structures/injectors/segmentInjector.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:app/structures/models/lessonModels/listeningSegmentModel.dart';

class ListeningPageInjector implements SegmentInjector {
  final String categoryId;

  @override
  covariant late ListeningSegmentModel segment;

  @override
  late LessonModel lessonModel;

  ListeningPageInjector(this.lessonModel, this.categoryId) : segment = lessonModel.listeningSegment!;

  ListeningPageInjector.from(SegmentInjector parent, this.categoryId){
    lessonModel = parent.lessonModel;
    segment = parent.segment as ListeningSegmentModel;
  }
}