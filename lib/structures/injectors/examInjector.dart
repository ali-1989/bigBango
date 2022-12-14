import 'package:app/structures/interfaces/examStateInterface.dart';
import 'package:app/structures/models/examModel.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';

class ExamInjector {
  late LessonModel lessonModel;
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
/*///-----------------------------------------------------
class ExamPageInjector {
  late LessonModel lessonModel;
  List<ExamInjector> exams = [];
}*/
