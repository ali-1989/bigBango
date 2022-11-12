import 'package:iris_tools/api/converter.dart';

class ExamOptionsModel {
  late int id;
  late String question;
  List<String> options = [];
  int correctOptionIndex = 0;

  //----------- local
  int userSelectedOptionIndex = 0;

  ExamOptionsModel();

  ExamOptionsModel.fromMap(Map js){
    id = js['id'];
    question = js['question'];
    options = Converter.correctList<String>(js['options'])?? [];
    correctOptionIndex = js['correctOptionIndex']?? 0;

    correctOptionIndex = js['userSelectedOptionIndex']?? 0;
  }

  Map<String, dynamic> toMap(){
    final js = <String, dynamic>{};

    js['id'] = id;
    js['question'] = question;
    js['options'] = options;
    js['correctOptionIndex'] = correctOptionIndex;

    js['userSelectedOptionIndex'] = userSelectedOptionIndex;

    return js;
  }
}