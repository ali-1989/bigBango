import 'package:app/structures/interfaces/examStateInterface.dart';
import 'package:app/structures/models/examModels/autodidactModel.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';

class ExamPageInjector {
  late LessonModel lessonModel;
  List<ExamModel> examList = [];
  List<AutodidactModel> autodidactList = [];
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