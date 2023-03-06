import 'package:flutter/animation.dart';

typedef ShowAnswerFn = void Function(String id, bool state);
typedef ShowAnswersFn = void Function(bool state);
typedef IsAnswerToAll = bool Function();


class ExamController {
  ShowAnswerFn? _showAnswerFn;
  ShowAnswersFn? _showAnswersFn;
  IsAnswerToAll? _isAnswerToAllFn;
  VoidCallback? _sendResultCallFn;
  bool _isInit = false;

  ExamController();

  void init(ShowAnswerFn? showAnswerFn, ShowAnswersFn? showAnswersFn, IsAnswerToAll? isAnswerToAll, VoidCallback? sendResult){
    _showAnswerFn = showAnswerFn;
    _showAnswersFn = showAnswersFn;
    _isAnswerToAllFn = isAnswerToAll;
    _sendResultCallFn = sendResult;

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

  void sendResult(){
    _sendResultCallFn?.call();
  }

  void dispose(){
    _showAnswerFn = null;
    _showAnswersFn = null;
    _isAnswerToAllFn = null;
    _sendResultCallFn = null;

    _isInit = false;
  }
}