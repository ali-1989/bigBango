import 'package:app/structures/abstract/examStateMethods.dart';
import 'package:app/structures/enums/quizType.dart';
import 'package:app/structures/models/examModels/examModel.dart';

class ExamController {
  static final Map<String, ExamController> _list = {};

  late ExamStateMethods _examMethods;
  late ExamModel _examModel;

  ExamController(ExamModel exam, ExamStateMethods examStateMethods){
    _list[exam.id] = this;
    _examModel = exam;
    _examMethods = examStateMethods;
  }

  void showAnswer(bool state){
    _examMethods.showAnswer(state);
  }

  bool isAnswerCorrect(){
    if(_examModel.quizType != QuizType.makeSentence) {
      return _examModel.getExamItem().isUserAnswerCorrect();
    }

    return _examModel.sentenceExtra!.isCorrectAll();
  }

  bool isAnswer(){
    if(_examModel.quizType != QuizType.makeSentence) {
      return _examModel.getExamItem().isUserAnswer();
    }

    return _examModel.sentenceExtra!.hasAnswer();
  }

  static ExamController? getControllerFor(ExamModel exam){
    for(final x in _list.entries){
      if(x.key == exam.id){
        return x.value;
      }
    }

    return null;
  }

  static void removeControllerFor(ExamModel exam){
    _list.removeWhere((key, value) => key == exam.id);
  }
}