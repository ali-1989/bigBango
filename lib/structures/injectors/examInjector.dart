import 'package:app/structures/interfaces/examStateInterface.dart';
import 'package:app/structures/models/examModel.dart';
import 'package:app/structures/models/lessonModels/iSegmentModel.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';

class ExamInjector {
  LessonModel? lessonModel;
  ISegmentModel? segmentModel;
  List<ExamModel> examList = [];
  late ExamStateInterface state;

  ExamInjector();

  void prepareExamList(List<ExamModel> list){
    examList = list;

    for(final k in examList){
      k.doSplitQuestion();
    }
  }
}