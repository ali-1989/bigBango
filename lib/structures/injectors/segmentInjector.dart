import 'package:app/structures/models/lessonModels/iSegmentModel.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';

class SegmentInjector<T extends ISegmentModel> {
  late LessonModel lessonModel;
  late T? segment;
}