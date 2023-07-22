import 'package:app/structures/injectors/segmentInjector.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:app/structures/models/lessonModels/readingSegmentModel.dart';

class ReadingPageInjector implements SegmentInjector {
  @override
  covariant late ReadingSegmentModel segment;

  @override
  late LessonModel lessonModel;

  int? index;

  ReadingPageInjector(this.lessonModel, {this.index}) : segment = lessonModel.readingSegment!;

  ReadingPageInjector.from(SegmentInjector parent){
    lessonModel = parent.lessonModel;
    segment = parent.segment as ReadingSegmentModel;
  }
}