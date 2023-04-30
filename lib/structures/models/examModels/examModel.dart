import 'package:app/structures/models/mediaModel.dart';
import 'package:iris_tools/api/generator.dart';

import 'package:app/structures/enums/quizType.dart';
import 'package:app/structures/models/examModels/examSuperModel.dart';

class ExamModel extends ExamSuperModel {
  String? title;
  QuizType quizType = QuizType.unKnow;
  List<ExamSolvedOptionModel> solvedOptions = [];
  List<ExamItem> items = [];
  MediaModel? voice;

  //----------- local
  bool showAnswer = false;
  bool isPrepare = false;

  ExamModel();

  ExamModel.fromMap(Map js){
    quizType = QuizType.fromType(js['exerciseType']);
    title = js['title'];

    if(js['solveItems'] is List){
      solvedOptions = js['solveItems'].map<ExamSolvedOptionModel>((e) => ExamSolvedOptionModel.fromMap(e)).toList();
    }

    if(js['items'] is List){
      items = js['items'].map<ExamItem>((e) => ExamItem.fromMap(e, quizType)).toList();
    }

    if(js['voice'] is Map) {
      voice = MediaModel.fromMap(js['voice']);
    }
  }

  Map<String, dynamic> toMap(){
    final js = <String, dynamic>{};

    js['title'] = title;
    js['exerciseType'] = quizType.number;
    js['items'] = items.map((e) => e.toMap()).toList();
    js['solveItems'] = solvedOptions.map((e) => e.toMap()).toList();
    js['voice'] = voice?.toMap();

    return js;
  }

  ExamItem getFirst(){
    return items[0];
  }
  
  void prepare(){
    if(quizType == QuizType.multipleChoice){
      getFirst()._generateUserAnswer();
    }

    if(quizType == QuizType.recorder){
      getFirst()._doSplitQuestion();

      getFirst().shuffleWords = [...getFirst().options];
      getFirst().shuffleWords.shuffle();
    }

    if(quizType == QuizType.fillInBlank){
      getFirst()._doSplitQuestion();
    }

    if(quizType == QuizType.makeSentence){
    }

    isPrepare = true;
  }
}
///==================================================================================================
class ExamItem {
  late String id;
  late String question;
  int order = 1;
  List<ExamOptionModel> options = [];

  late QuizType quizType;
  List<ExamOptionModel> userAnswers = [];
  List<String> questionSplit = [];
  List<ExamOptionModel> shuffleWords = [];

  ExamItem(this.quizType);

  ExamItem.fromMap(Map js, this.quizType){
    id = js['id']?? '';
    question = js['question']?? '';
    order = js['order']?? 1;

    if(js['choices'] is List){
      options = js['choices'].map<ExamOptionModel>((e) => ExamOptionModel.fromMap(e)).toList();
    }

    //----------- local
    if(js['userAnswers'] is List){
      userAnswers = js['userAnswers'].map<ExamOptionModel>((e) => ExamOptionModel.fromMap(e)).toList();
    }
  }

  Map<String, dynamic> toMap(){
    final js = <String, dynamic>{};

    js['id'] = id;
    js['question'] = question;
    js['order'] = order;
    js['choices'] = options.map((e) => e.toMap()).toList();

    //----------- local
    js['userAnswers'] = userAnswers.map((e) => e.toMap()).toList();

    return js;
  }

  void _generateUserAnswer(){
    userAnswers.clear();
  }

  void _doSplitQuestion(){
    if(question.startsWith('**')){
      /// this trick used if question start with ** for correct splitting
      question = '\u2060$question';
    }

    questionSplit = question.split('**');
    userAnswers.clear();

    for(int i = 1; i < questionSplit.length; i++) {
      final ex = ExamOptionModel()..order = i;

      if(quizType == QuizType.multipleChoice){
        ex.id = '';
      }

      userAnswers.add(ex);
    }
  }

  int getIndexOfCorrectChoice(){
    for(int i = 0; i< options.length; i++){
      if(options[i].isCorrect){
        return i;
      }
    }

    return -1;
  }

  ExamOptionModel? getCorrectChoice(){
    for(int i = 0; i< options.length; i++){
      if(options[i].isCorrect){
        return options[i];
      }
    }

    return null;
  }

  ExamOptionModel? getChoiceByOrder(int order){
    for(int i = 0; i < options.length; i++){
      if(options[i].order == order){
        return options[i];
      }
    }

    return null;
  }

  ExamOptionModel? getUserChoiceByOrder(int order){
    for(int i = 0; i < userAnswers.length; i++){
      if(userAnswers[i].order == order){
        return userAnswers[i];
      }
    }

    return null;
  }

  ExamOptionModel? getUserChoiceById(String id){
    for(int i = 0; i < userAnswers.length; i++){
      if(userAnswers[i].id == id){
        return userAnswers[i];
      }
    }

    return null;
  }

  ExamOptionModel? getChoiceById(String id){
    for(int i = 0; i< options.length; i++){
      if(options[i].id == id){
        return options[i];
      }
    }

    return null;
  }

  String getUserAnswerText(){
    if(quizType == QuizType.multipleChoice){
      if(userAnswers.isNotEmpty){
        return getChoiceById(userAnswers[0].id)!.text;
      }
    }
    else if (quizType == QuizType.recorder){
      var txt = question;
      var order = 1;

      while(txt.contains('**')){
        final ans = getUserChoiceByOrder(order)?.text?? '';

        txt = txt.replaceFirst('**', '[${ans.isEmpty? 'بدون پاسخ': ans}]');
        order++;
      }

      return txt;
    }
    else if (quizType == QuizType.fillInBlank){
      var txt = question;
      var order = 1;

      while(txt.contains('**')){
        final ans = getUserChoiceByOrder(order)?.text?? '';

        txt = txt.replaceFirst('**', '[${ans.isEmpty? 'بدون پاسخ': ans}]');
        order++;
      }

      return txt;
    }
    else if (quizType == QuizType.makeSentence){
      var txt = question;
      return txt;
    }

    return 'بدون پاسخ';
  }

  bool isUserAnswerCorrect(){
    if(quizType == QuizType.multipleChoice){
      if(userAnswers.isEmpty){
        return false;
      }

      return userAnswers[0].id == getCorrectChoice()!.id;
    }
    else if (quizType == QuizType.recorder){
      for (final k in userAnswers) {
        if (k.id.isEmpty) {
          return false;
        }
      }

      for(int i=1; i <= options.length; i++){
        final correctAnswer = getChoiceByOrder(i)!.text;
        final userAnswer = getUserChoiceByOrder(i)?.text;

        if(correctAnswer != userAnswer){
          return false;
        }
      }

      return true;
    }
    else if (quizType == QuizType.fillInBlank){
      for(int i = 1; i <= options.length; i++){
        final correctAnswer = getChoiceByOrder(i)?.text;
        final userAnswer = getUserChoiceByOrder(i)?.text;

        if(correctAnswer != userAnswer){
          return false;
        }
      }

      return true;
    }
    else if (quizType == QuizType.makeSentence){
      return true;
    }

    return false;
  }
}
///==================================================================================================
class ExamOptionModel {
  String id = '';
  String text = '';
  bool isCorrect = false;
  int order = 1;

  ExamOptionModel(): id = Generator.generateKey(5);

  ExamOptionModel.fromMap(Map js){
    id = js['id']?? Generator.generateKey(5);
    text = js['text'];
    isCorrect = js['isCorrect']?? false;
    order = js['order']?? 1;
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
class ExamSolvedOptionModel {
  String quizId = '';
  String answer = '';
  bool isCorrect = false;

  ExamSolvedOptionModel();

  ExamSolvedOptionModel.fromMap(Map js){
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
