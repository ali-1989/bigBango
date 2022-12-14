import 'package:app/structures/enums/quizType.dart';
import 'package:iris_tools/api/generator.dart';

class ExamModel {
  late String id;
  late String question;
  QuizType exerciseType = QuizType.unKnow;
  List<ExamChoiceModel> choices = [];

  //----------- local
  List<ExamChoiceModel> userAnswers = [];
  int userSelectedOptionIndex = -1;
  List<String> questionSplit = [];
  List<ExamChoiceModel> shuffleWords = [];

  ExamModel();

  ExamModel.fromMap(Map js){
    id = js['id']?? '';
    question = js['question'];
    exerciseType = QuizType.from(js['exerciseType']);

    if(js['choices'] is List){
      choices = js['choices'].map((e) => ExamChoiceModel.fromMap(e)).toList();
    }

    //----------- local
    if(js['userAnswers'] is List){
      userAnswers = js['userAnswers'].map((e) => ExamChoiceModel.fromMap(e)).toList();
    }

    userSelectedOptionIndex = js['userSelectedOptionIndex']?? -1;
  }

  Map<String, dynamic> toMap(){
    final js = <String, dynamic>{};

    js['id'] = id;
    js['question'] = question;
    js['exerciseType'] = exerciseType.type();
    js['choices'] = choices.map((e) => e.toMap()).toList();

    //----------- local
    js['userAnswers'] = userAnswers.map((e) => e.toMap()).toList();
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

    for(int i = 0; i < questionSplit.length-1; i++) {
      userAnswers.add(ExamChoiceModel()..order = i..id = '');
    }

    if(exerciseType == QuizType.recorder){
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
