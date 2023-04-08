import 'package:app/structures/models/examModels/autodidactModel.dart';
import 'package:app/structures/models/examModels/examModel.dart';

class ExamBuilderContent {
  final List<ExamModel> examList = [];
  final List<AutodidactModel> autodidactList = [];
  bool showSendButton = true;
  String sendButtonText = 'ارسال جواب';
  String answerUrl = '';

  ExamBuilderContent();

  void setAutodidacts(List<AutodidactModel> list){
    autodidactList.clear();
    autodidactList.addAll(list);
  }

  void setExams(List<ExamModel> list){
    examList.clear();
    examList.addAll(list);
  }

  void prepareExamList(List<ExamModel> list){
    examList.clear();
    examList.addAll(list);

    for(final k in examList){
      if(!k.isPrepare){
        k.prepare();
      }
    }
  }
}