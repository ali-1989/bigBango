import 'package:app/structures/models/examModels/examSuperModel.dart';
import 'package:app/structures/enums/autodidactReplyType.dart';
import 'package:app/structures/models/mediaModel.dart';

class AutodidactModel extends ExamSuperModel {
  late String id;
  String? text;
  String? question;
  String? correctAnswer;
  String? lastAnswer;
  AutodidactReplyType replyType = AutodidactReplyType.unKnow;
  MediaModel? voice;

  //----------- local

  AutodidactModel();

  AutodidactModel.fromMap(Map js){
    id = js['id']?? '';
    question = js['question'];
    text = js['text'];
    correctAnswer = js['correctAnswer'];
    replyType = AutodidactReplyType.from(js['replyType']);

    if(js['lastAnswer'] is Map){
      lastAnswer = js['lastAnswer']['text'];
    }

    if(js['voice'] is Map){
      voice = MediaModel.fromMap(js['voice']);
    }
  }

  Map<String, dynamic> toMap(){
    final js = <String, dynamic>{};

    js['id'] = id;
    js['question'] = question;
    js['text'] = text;
    js['correctAnswer'] = correctAnswer;
    js['replyType'] = replyType.type();
    js['lastAnswer'] = {'text': lastAnswer};
    js['voice'] = voice?.toMap();

    return js;
  }
}
