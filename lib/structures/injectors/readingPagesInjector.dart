import 'package:app/structures/injectors/segmentInjector.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:app/structures/models/lessonModels/readingSegmentModel.dart';

class ReadingPageInjector implements SegmentInjector {
  @override
  covariant late ReadingSegmentModel segment;

  @override
  late LessonModel lessonModel;

  String categoryId;

  ReadingPageInjector(this.lessonModel, {required this.categoryId}) : segment = lessonModel.readingSegment!;


}