import 'package:app/structures/models/examModels/examModel.dart';

class OnlineExamCategoryModel {
  String? title;
  List<ExamModel> questions = [];

  OnlineExamCategoryModel();

  OnlineExamCategoryModel.fromMap(Map js){
    title = js['title'];

    if(js['questions'] is List) {
      for(final itm in js['questions']){
        questions.add(ExamModel.fromMap(itm));
      }
    }
  }
}