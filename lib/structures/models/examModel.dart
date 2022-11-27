import 'package:app/system/enums.dart';


class ExamModel {
  late String id;
  late String question;
  QuizType quizType = QuizType.unKnow;
  List<ExamChoiceModel> choices = [];

  //----------- local
  List<ExamChoiceModel> userAnswers = [];
  int userSelectedOptionIndex = -1;
  List<String> questionSplit = [];
  List<ExamChoiceModel> shuffleWords = [];

  ExamModel();

  ExamModel.fromMap(Map js){
    final choicesTemp = js['choices'];
    final userAnswersTemp = js['userAnswers'];

    id = js['id']?? '';
    question = js['question'];
    quizType = QuizType.from(js['quizType']);

    if(choicesTemp is List){
      choices = choicesTemp.map((e) => ExamChoiceModel.fromMap(e)).toList();
    }

    if(userAnswersTemp is List){
      userAnswers = choicesTemp.map((e) => ExamChoiceModel.fromMap(e)).toList();
    }
    //----------- local
    userSelectedOptionIndex = js['userSelectedOptionIndex']?? -1;
  }

  Map<String, dynamic> toMap(){
    final js = <String, dynamic>{};

    js['id'] = id;
    js['question'] = question;
    js['quizType'] = quizType.type();
    js['choices'] = choices;

    //----------- local
    js['userAnswers'] = userAnswers;
    js['userSelectedOptionIndex'] = userSelectedOptionIndex;

    return js;
  }

  void doSplitQuestion(){
    if(question.startsWith('**')){
      /// this trick used if question start with ** for correct splitting
      question = '\u2060$question';
    }

    questionSplit = question.split('**');

    userAnswers.clear();

    for(int i = 1; i < questionSplit.length; i++) {
      userAnswers.add(ExamChoiceModel());
    }

    if(quizType == QuizType.recorder){
      shuffleWords = [...choices];
      shuffleWords.shuffle();
    }
  }

  int getCorrectChoiceIndex(){
    for(int i = 0; i< choices.length; i++){
      if(choices[i].isCorrect){
        return i;
      }
    }

    return -1;
  }
}
///==================================================================================================
class ExamChoiceModel {
  String text = '';
  bool isCorrect = false;
  int order = 0;

  ExamChoiceModel();

  ExamChoiceModel.fromMap(Map js){
    text = js['text'];
    isCorrect = js['isCorrect']?? false;
    order = js['order']?? 0;
  }

  Map<String, dynamic> toMap(){
    final js = <String, dynamic>{};

    js['text'] = text;
    js['isCorrect'] = isCorrect;
    js['order'] = order;

    return js;
  }
}