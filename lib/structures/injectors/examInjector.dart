import 'package:app/structures/interfaces/examStateInterface.dart';
import 'package:app/structures/models/examModel.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';

class ExamPageInjector {
  late LessonModel lessonModel;
  List<ExamModel> examList = [];
  late ExamStateInterface state;
  String answerUrl = '';

  ExamPageInjector();

  void prepareExamList(List<ExamModel> list){
    examList = list;

    for(final k in examList){
      if(!k.isPrepare){
        k.prepare();
      }
    }
  }
}