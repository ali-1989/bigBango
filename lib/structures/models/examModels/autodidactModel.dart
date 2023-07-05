import 'package:app/structures/enums/autodidactReplyType.dart';
import 'package:app/structures/models/examModels/examSuperModel.dart';
import 'package:app/structures/models/mediaModel.dart';

class AutodidactModel extends ExamSuperModel {
  late String id;
  String? text;
  String? question;
  String? correctAnswer;
  MediaModel? correctAnswerVoice;
  LastAnswer? lastAnswer;
  //----------- local
  AutodidactReplyType replyType = AutodidactReplyType.unKnow;

  AutodidactModel();

  AutodidactModel.fromMap(Map js){
    id = js['id']?? '';
    question = js['question'];
    text = js['text'];
    correctAnswer = js['correctAnswer'];

    if(js['lastAnswer'] is Map){
      lastAnswer = LastAnswer.fromMap(js['lastAnswer']);
    }

    if(js['correctAnswerVoice'] is Map){
      correctAnswerVoice = MediaModel.fromMap(js['correctAnswerVoice']);
    }
    //-------- local
    replyType = correctAnswerVoice != null ? AutodidactReplyType.voice : AutodidactReplyType.text;
  }

  Map<String, dynamic> toMap(){
    final js = <String, dynamic>{};

    js['id'] = id;
    js['question'] = question;
    js['text'] = text;
    js['correctAnswer'] = correctAnswer;
    js['correctAnswerVoice'] = correctAnswerVoice?.toMap();
    js['lastAnswer'] = lastAnswer?.toMap();

    js['replyType'] = replyType.number;

    return js;
  }
}
///=============================================================================
class LastAnswer {
  String? userAnswer;
  MediaModel? userAnswerVoice;

  LastAnswer.fromMap(Map map){
    userAnswer = map['userAnswer'];

    if(map['userAnswerVoice'] is Map) {
      userAnswerVoice = MediaModel.fromMap(map['userAnswerVoice']);
    }
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map['userAnswer'] = userAnswer;
    map['userAnswerVoice'] = userAnswerVoice?.toMap();

    return map;
  }
}