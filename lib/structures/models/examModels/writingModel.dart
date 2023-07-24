import 'package:app/structures/models/examModels/examSuperModel.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

class WritingModel extends ExamSuperModel {
  late String id;
  String? text;
  String? question;
  String? correctAnswer;
  LastAnswer? lastAnswer;

  WritingModel();

  WritingModel.fromMap(Map js){
    id = js['id']?? '';
    question = js['question'];
    text = js['text'];
    correctAnswer = js['correctAnswer'];

    if(js['lastAnswer'] is Map) {
      lastAnswer = LastAnswer.fromMap(js['lastAnswer']);
    }
  }

  Map<String, dynamic> toMap(){
    final js = <String, dynamic>{};

    js['id'] = id;
    js['question'] = question;
    js['text'] = text;
    js['correctAnswer'] = correctAnswer;
    js['lastAnswer'] = lastAnswer?.toMap();

    return js;
  }
}

///=============================================================================
class LastAnswer {
  String? userAnswer;
  DateTime? createdAt;

  LastAnswer.fromMap(Map map){
    userAnswer = map['userAnswer'];
    createdAt = DateHelper.tsToSystemDate(map['createdAt']);
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map['userAnswer'] = userAnswer;
    map['createdAt'] = DateHelper.toTimestampNullable(createdAt);

    return map;
  }
}