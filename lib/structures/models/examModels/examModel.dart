import 'package:app/structures/models/examModels/examSuperModel.dart';
import 'package:app/structures/enums/quizType.dart';
import 'package:iris_tools/api/generator.dart';


class ExamModel extends ExamSuperModel {
  late String id;
  late String question;
  QuizType exerciseType = QuizType.unKnow;
  List<ExamChoiceModel> choices = [];
  List<ExamSolveModel> solveItems = [];

  //----------- local
  bool isPrepare = false;
  List<ExamChoiceModel> userAnswers = [];
  List<String> questionSplit = [];
  List<ExamChoiceModel> shuffleWords = [];

  ExamModel();

  ExamModel.fromMap(Map js){
    id = js['id']?? '';
    question = js['question'];
    exerciseType = QuizType.fromType(js['exerciseType']);

    if(js['choices'] is List){
      choices = js['choices'].map<ExamChoiceModel>((e) => ExamChoiceModel.fromMap(e)).toList();
    }

    if(js['solveItems'] is List){
      choices = js['solveItems'].map<ExamChoiceModel>((e) => ExamSolveModel.fromMap(e)).toList();
    }

    //----------- local
    if(js['userAnswers'] is List){
      userAnswers = js['userAnswers'].map<ExamChoiceModel>((e) => ExamChoiceModel.fromMap(e)).toList();
    }
  }

  Map<String, dynamic> toMap(){
    final js = <String, dynamic>{};

    js['id'] = id;
    js['question'] = question;
    js['exerciseType'] = exerciseType.number;
    js['choices'] = choices.map((e) => e.toMap()).toList();
    js['solveItems'] = solveItems.map((e) => e.toMap()).toList();

    //----------- local
    js['userAnswers'] = userAnswers.map((e) => e.toMap()).toList();

    return js;
  }

  void prepare(){
    if(exerciseType == QuizType.multipleChoice){
      _generateUserAnswer();
    }
    else {
      _doSplitQuestion();
    }

    if(exerciseType == QuizType.recorder){
      shuffleWords = [...choices];
      shuffleWords.shuffle();
    }

    isPrepare = true;
  }

  void _generateUserAnswer(){
    userAnswers.clear();

    /*for(int i = 0; i < choices.length; i++) {
      final ex = ExamChoiceModel()..order = i;

      ex.id = choices[i].id;

      userAnswers.add(ex);
    }*/
  }

  void _doSplitQuestion(){
    if(question.startsWith('**')){
      /// this trick used if question start with ** for correct splitting
      question = '\u2060$question';
    }

    questionSplit = question.split('**');

    userAnswers.clear();

    for(int i = 0; i < questionSplit.length-1; i++) {
      final ex = ExamChoiceModel()..order = i;

      if(exerciseType == QuizType.multipleChoice){
        ex.id = '';
      }

      userAnswers.add(ex);
    }
  }

  int getIndexOfCorrectChoice(){
    for(int i = 0; i< choices.length; i++){
      if(choices[i].isCorrect){
        return i;
      }
    }

    return -1;
  }

  ExamChoiceModel? getCorrectChoice(){
    for(int i = 0; i< choices.length; i++){
      if(choices[i].isCorrect){
        return choices[i];
      }
    }

    return null;
  }

  ExamChoiceModel? getChoiceByOrder(int order){
    for(int i = 0; i< choices.length; i++){
      if(choices[i].order == order){
        return choices[i];
      }
    }

    return null;
  }

  ExamChoiceModel? getUserChoiceByOrder(int order){
    for(int i = 0; i< userAnswers.length; i++){
      if(userAnswers[i].order == order){
        return userAnswers[i];
      }
    }

    return null;
  }

  ExamChoiceModel? getUserChoiceById(String id){
    for(int i = 0; i< userAnswers.length; i++){
      if(userAnswers[i].id == id){
        return userAnswers[i];
      }
    }

    return null;
  }

  ExamChoiceModel? getChoiceById(String id){
    for(int i = 0; i< choices.length; i++){
      if(choices[i].id == id){
        return choices[i];
      }
    }

    return null;
  }

  String getUserAnswerText(){
    if(exerciseType == QuizType.multipleChoice){
      if(userAnswers.isNotEmpty){
        return getChoiceById(userAnswers[0].id)!.text;
      }
    }
    else if (exerciseType == QuizType.recorder){
      var txt = question;
      var order = 0;

      while(txt.contains('**')){
        final ans = getUserChoiceByOrder(order)!.text;

        txt = txt.replaceFirst('**', '[${ans.isEmpty? 'بدون پاسخ': ans}]');
        order++;
      }

      return txt;
    }
    else if (exerciseType == QuizType.fillInBlank){
      var txt = question;
      var order = 0;

      while(txt.contains('**')){
        final ans = getUserChoiceByOrder(order)!.text;

        txt = txt.replaceFirst('**', '[${ans.isEmpty? 'بدون پاسخ': ans}]');
        order++;
      }

      return txt;
    }

    return 'بدون پاسخ';
  }

  bool isUserAnswerCorrect(){
    if(exerciseType == QuizType.multipleChoice){
      if(userAnswers.isEmpty){
        return false;
      }

      return userAnswers[0].id == getCorrectChoice()!.id;
    }
    else if (exerciseType == QuizType.recorder){
      for (final k in userAnswers) {
        if (k.id.isEmpty) {
          return false;
        }
      }

      for(int i=0; i< choices.length; i++){
        final correctAnswer = getChoiceByOrder(i)!.text;
        final userAnswer = getUserChoiceByOrder(i)!.text;

        if(correctAnswer != userAnswer){
          return false;
        }
      }

      return true;
    }
    else if (exerciseType == QuizType.fillInBlank){
      for(int i = 0; i < choices.length; i++){
        final correctAnswer = getChoiceByOrder(i)!.text;
        final userAnswer = getUserChoiceByOrder(i)!.text;

        if(correctAnswer != userAnswer){
          return false;
        }
      }

      return true;
    }

    return false;
  }
}
///==================================================================================================
class ExamChoiceModel {
  String id = '';
  String text = '';
  bool isCorrect = false;
  int order = 0;

  ExamChoiceModel(): id = Generator.generateKey(5);

  ExamChoiceModel.fromMap(Map js){
    id = js['id']?? Generator.generateKey(5);
    text = js['text'];
    isCorrect = js['isCorrect']?? false;
    order = js['order']?? 0;
  }

  Map<String, dynamic> toMap(){
    final js = <String, dynamic>{};

    js['id'] = id;
    js['text'] = text;
    js['isCorrect'] = isCorrect;
    js['order'] = order;

    return js;
  }
}
///==================================================================================================
class ExamSolveModel {
  String quizId = '';
  String answer = '';
  bool isCorrect = false;

  ExamSolveModel();

  ExamSolveModel.fromMap(Map js){
    quizId = js['quizId'];
    answer = js['answer'];
    isCorrect = js['isCorrect']?? false;
  }

  Map<String, dynamic> toMap(){
    final js = <String, dynamic>{};

    js['quizId'] = quizId;
    js['answer'] = answer;
    js['isCorrect'] = isCorrect;

    return js;
  }
}
