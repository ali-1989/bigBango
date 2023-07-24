import 'package:app/structures/models/examModels/examSuperModel.dart';
import 'package:app/structures/models/mediaModel.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

class SpeakingModel extends ExamSuperModel {
  late String id;
  String? text;
  String? question;
  MediaModel? correctAnswerVoice;
  LastAnswer? lastAnswer;

  SpeakingModel();

  SpeakingModel.fromMap(Map js){
    id = js['id']?? '';
    question = js['question'];
    text = js['text'];

    if(js['lastAnswer'] is Map){
      lastAnswer = LastAnswer.fromMap(js['lastAnswer']);
    }

    if(js['correctAnswerVoice'] is Map){
      correctAnswerVoice = MediaModel.fromMap(js['correctAnswerVoice']);
    }
  }

  Map<String, dynamic> toMap(){
    final js = <String, dynamic>{};

    js['id'] = id;
    js['question'] = question;
    js['text'] = text;
    js['correctAnswerVoice'] = correctAnswerVoice?.toMap();
    js['lastAnswer'] = lastAnswer?.toMap();

    return js;
  }
}
///=============================================================================
class LastAnswer {
  DateTime? createdAt;
  MediaModel? userAnswerVoice;

  LastAnswer.fromMap(Map map){
    createdAt = DateHelper.tsToSystemDate(map['createdAt']);

    if(map['userAnswerVoice'] is Map) {
      userAnswerVoice = MediaModel.fromMap(map['userAnswerVoice']);
    }
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map['createdAt'] = DateHelper.toTimestampNullable(createdAt);
    map['userAnswerVoice'] = userAnswerVoice?.toMap();

    return map;
  }
}