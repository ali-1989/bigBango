import 'package:app/structures/models/lessonModels/iSegmentModel.dart';
import 'package:app/structures/models/listeningModel.dart';
import 'package:app/tools/app/appImages.dart';

class ListeningSegmentModel extends ISegmentModel {
  List<ListeningModel> listeningList  = [];

  ListeningSegmentModel(){
    _init();
  }

  void _init(){
    title = 'شنیدن';
    engTitle = 'Listening';
    icon = AppImages.speakerIco;
  }

  ListeningSegmentModel.fromMap(Map map):super.fromMap(map) {
    _init();

    if(map['items'] is List){
      listeningList = map['items'].map<ListeningModel>((e) => ListeningModel.fromMap(e)).toList();
    }
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['items'] = listeningList.map((e) => e.toMap()).toList();

    return map;
  }

  void matchBy(ListeningSegmentModel others){
    title = others.title;
    progress = others.progress;
    listeningList.clear();
    listeningList.addAll(others.listeningList);
  }
}