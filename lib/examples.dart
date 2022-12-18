import 'package:app/structures/enums/quizType.dart';
import 'package:app/structures/models/examModel.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:app/structures/models/listeningModel.dart';

class Examples {
  Examples._();

  static List<ExamModel> genExams(){
    final res = <ExamModel>[];


    return res;
  }

  static void addListening(LessonModel lessonModel){
    final l1 = ListeningModel();
    l1.id = 'i1';
    l1.title = 'بخش یک';
    l1.quiz = ExamModel()..id = 'i1'..exerciseType = QuizType.fillInBlank;

    l1.quiz.question = 'fill ** the ** here';
    l1.quiz.choices = [ExamChoiceModel()..id = 'i1'..text = 't1', ExamChoiceModel()..id = 'i2'..text = 't2'];

    lessonModel.listeningModel!.listeningList.add(l1);


    final l2 = ListeningModel();
    l2.id = 'i2';
    l2.title = 'بخش دو';
    l2.quiz = ExamModel()..id = 'i2'..exerciseType = QuizType.recorder;

    l2.quiz.question = 'fill ** the ** here';
    l2.quiz.choices = [ExamChoiceModel()..id = 'i1'..text = 't1', ExamChoiceModel()..id = 'i2'..text = 't2'];

    lessonModel.listeningModel!.listeningList.add(l2);
  }
}