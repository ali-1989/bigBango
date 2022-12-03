import 'package:app/structures/injectors/segmentInjector.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:app/structures/models/lessonModels/listeningSegmentModel.dart';

class ListeningPageInjector implements SegmentInjector {
  @override
  covariant late ListeningSegmentModel segment;

  @override
  late LessonModel lessonModel;

  ListeningPageInjector(this.lessonModel) : segment = lessonModel.listeningModel!;

  ListeningPageInjector.from(SegmentInjector parent){
    lessonModel = parent.lessonModel;
    segment = parent.segment as ListeningSegmentModel;
  }
}