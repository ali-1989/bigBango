import 'package:app/structures/models/grammarExerciseModel.dart';
import 'package:app/structures/models/mediaModel.dart';

class GrammarModel {
  String id = '';
  String title = '';
  int order = 0;
  MediaModel? media;
  List<GrammarExerciseModel> exerciseCategories = [];

  GrammarModel();

  GrammarModel.fromMap(Map map) {
    id = map['id'];
    title = map['title'];
    order = map['order'];

    if(map['video'] is Map) {
      media = MediaModel.fromMap(map['video']);
    }

    if(map['exerciseCategories'] is List){
      for(final l in map['exerciseCategories']){
        exerciseCategories.add(GrammarExerciseModel.fromMap(l));
      }
    }
    //progress = MathHelper.clearToDouble(map['progress']);
    //progress = MathHelper.fixPrecision(progress, 1);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['id'] = id;
    map['title'] = title;
    map['order'] = order;
    map['video'] = media?.toMap();
    map['exerciseCategories'] = exerciseCategories.map((e) => e.toMap()).toList();

    return map;
  }
}
