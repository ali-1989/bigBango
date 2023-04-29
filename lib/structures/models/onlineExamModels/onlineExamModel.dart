import 'package:app/structures/models/mediaModel.dart';

class OnlineExamModel {
  String? title;
  OnlineExamExerciseModel? exam;

  OnlineExamModel();

  OnlineExamModel.fromMap(Map js){
    title = js['title'];
    exam = OnlineExamExerciseModel.fromMap(js['title']);
  }
}
///==========================================================================================
class OnlineExamExerciseModel {
  String? type;
  List items = [];
  MediaModel? voice;

  OnlineExamExerciseModel();

  OnlineExamExerciseModel.fromMap(Map js){
    voice = js['type'];
    voice = js['voice'];
  }

}