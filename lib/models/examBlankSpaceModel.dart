import 'package:iris_tools/api/converter.dart';

class ExamBlankSpaceModel {
  late int id;
  late String question;
  List<String> answers = [];

  //----------- local
  List<String> userAnswers = [];
  List<String> questionSplit = [];

  ExamBlankSpaceModel();

  ExamBlankSpaceModel.fromMap(Map js){
    id = js['id'];
    question = js['question'];
    answers = Converter.correctList<String>(js['answers'])?? [];

    userAnswers = Converter.correctList<String>(js['userAnswers'])?? [];
  }

  Map<String, dynamic> toMap(){
    final js = <String, dynamic>{};

    js['id'] = id;
    js['question'] = question;
    js['answers'] = answers;

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
  }
}