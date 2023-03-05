typedef ShowAnswerFn = void Function(String id, bool state);
typedef ShowAnswersFn = void Function(bool state);
typedef IsAnswerToAll = bool Function();


class ExamController {
  ShowAnswerFn? _showAnswerFn;
  ShowAnswersFn? _showAnswersFn;
  IsAnswerToAll? _isAnswerToAllFn;

  ExamController();

  void setShowAnswer(ShowAnswerFn fn){
    _showAnswerFn = fn;
  }

  void setShowAnswers(ShowAnswersFn fn){
    _showAnswersFn = fn;
  }

  void setIsAnswerToAll(IsAnswerToAll fn){
    _isAnswerToAllFn = fn;
  }

  void showAnswer(String id, bool state){
    _showAnswerFn?.call(id, state);
  }

  void showAnswers(bool state){
    _showAnswersFn?.call(state);
  }

  bool isAnswerToAll(){
    return _isAnswerToAllFn?.call()?? false;
  }

  void dispose(){
    _showAnswerFn = null;
    _showAnswersFn = null;
    _isAnswerToAllFn = null;
  }
}