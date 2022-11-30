import 'package:app/structures/models/lessonModels/iSegmentModel.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';

abstract class SegmentInjector {
  abstract LessonModel lessonModel;
  abstract ISegmentModel segment;

  SegmentInjector();
}