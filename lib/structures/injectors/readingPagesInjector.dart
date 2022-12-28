import 'package:app/structures/injectors/segmentInjector.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:app/structures/models/lessonModels/readingSegmentModel.dart';

class ReadingPageInjector implements SegmentInjector {
  @override
  covariant late ReadingSegmentModel segment;

  @override
  late LessonModel lessonModel;

  ReadingPageInjector(this.lessonModel) : segment = lessonModel.readingModel!;

  ReadingPageInjector.from(SegmentInjector parent){
    lessonModel = parent.lessonModel;
    segment = parent.segment as ReadingSegmentModel;
  }
}