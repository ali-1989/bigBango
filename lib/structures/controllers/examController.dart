import 'package:app/structures/abstract/examStateMethods.dart';

class ExamController {
  static final Map<String, ExamController> _list = {};

  late ExamStateMethods _examMethods;

  ExamController(String id, ExamStateMethods examStateMethods){
    _list[id] = this;
    _examMethods = examStateMethods;
  }

  void showAnswer(String id, bool state){
    _examMethods.showAnswer(id, state);
  }

  void showAnswers(bool state){
    _examMethods.showAnswers(state);
  }

  bool isAnswerToAll(){
    return _examMethods.isAnswerToAll();
  }

  static ExamController? getControllerFor(String id){
    for(final x in _list.entries){
      if(x.key == id){
        return x.value;
      }
    }

    return null;
  }

  static void removeControllerFor(String id){
    _list.removeWhere((key, value) => key == id);
  }
}