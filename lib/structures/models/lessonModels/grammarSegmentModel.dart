import 'package:app/structures/models/grammarModel.dart';
import 'package:app/structures/models/lessonModels/iSegmentModel.dart';
import 'package:app/tools/app/appImages.dart';

class GrammarSegmentModel extends ISegmentModel {
  List<GrammarModel> grammarList = [];

  GrammarSegmentModel(){
    _init();
  }

  void _init(){
    title = 'گرامر';
    engTitle = 'Grammar';
    icon = AppImages.grammarIco;
  }

  GrammarSegmentModel.fromMap(Map map):super.fromMap(map) {
    _init();

    if(map['title'] is String){
      title = map['title'];
    }

    if(map['items'] is List){
      grammarList = map['items'].map<GrammarModel>((e) => GrammarModel.fromMap(e)).toList();
    }
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['items'] = grammarList.map((e) => e.toMap()).toList();

    return map;
  }

  void matchBy(GrammarSegmentModel others){
    id = others.id;
    title = others.title;
    progress = others.progress;
    grammarList.clear();
    grammarList.addAll(others.grammarList);
  }
}
