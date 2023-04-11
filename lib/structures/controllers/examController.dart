
typedef ShowAnswerFn = void Function(String id, bool state);
typedef ShowAnswersFn = void Function(bool state);
typedef IsAnswerToAll = bool Function();


class ExamController {
  static final Map<String, ExamController> _list = {};

  ShowAnswerFn? _showAnswerFn;
  ShowAnswersFn? _showAnswersFn;
  IsAnswerToAll? _isAnswerToAllFn;
  bool _isInit = false;

  ExamController(String id){
    _list[id] = this;
  }

  void init(ShowAnswerFn? showAnswerFn, ShowAnswersFn? showAnswersFn, IsAnswerToAll? isAnswerToAll){
    _showAnswerFn = showAnswerFn;
    _showAnswersFn = showAnswersFn;
    _isAnswerToAllFn = isAnswerToAll;

    _isInit = true;
  }

  bool isInit(){
    return _isInit;
  }

  void assertIsInit(){
    assert(isInit(), 'must initialization ExamController');
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

    _isInit = false;
  }
}

abstract class ExamStateMethods {

  bool isAnswerToAll();
  void showAnswers(bool state);
  void showAnswer(String examId, bool state);
}