import 'package:iris_tools/api/converter.dart';

class ExamSelectWordModel {
  late int id;
  late String question;
  List<String> words = [];

  //----------- local
  List<String> userAnswers = [];
  List<String> questionSplit = [];
  List<String> shuffleWords = [];

  ExamSelectWordModel();

  ExamSelectWordModel.fromMap(Map js){
    id = js['id'];
    question = js['question'];
    words = Converter.correctList<String>(js['words'])?? [];

    userAnswers = Converter.correctList<String>(js['userAnswers'])?? [];
  }

  Map<String, dynamic> toMap(){
    final js = <String, dynamic>{};

    js['id'] = id;
    js['question'] = question;
    js['words'] = words;

    js['userAnswers'] = userAnswers;

    return js;
  }

  void doSplitQuestion(){
    if(question.startsWith('*****')){
      question = '\u2060$question';
    }

    questionSplit = question.split('*****');
    userAnswers.clear();

    for(int i = 1; i < questionSplit.length; i++) {
      userAnswers.add('');
    }

    shuffleWords = [...words];
    shuffleWords.shuffle();
  }
}