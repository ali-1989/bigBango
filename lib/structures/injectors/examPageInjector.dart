import 'package:app/structures/enums/quizType.dart';
import 'package:app/structures/models/examModels/autodidactModel.dart';
import 'package:app/structures/models/examModels/examModel.dart';

class ExamPageInjector {
  final List<ExamModel> examList = [];
  final List<AutodidactModel> autodidactList = [];
  String answerUrl = '';
  bool showSendButton = true;


  ExamPageInjector();

  void setAutodidacts(List<AutodidactModel> list){
    autodidactList.clear();
    autodidactList.addAll(list);
  }

  void setExams(List<ExamModel> list){
    examList.clear();
    examList.addAll(list);

    _check();
  }

  void prepareExamList(List<ExamModel> list){
    examList.clear();
    examList.addAll(list);

    for(final k in examList){
      if(!k.isPrepare){
        k.prepare();
      }
    }

    _check();
  }

  void _check(){
    examList.removeWhere((element) {
      if(element.quizType == QuizType.fillInBlank) {
        for (var x in element.items) {
          final starLen = x.question.split('**').length;
          if (x.teacherOptions.length != starLen - 1) {
            return true;
          }
        }
      }

      return false;
    });
  }
}