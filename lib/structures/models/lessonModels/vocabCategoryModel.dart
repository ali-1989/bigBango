
class VocabCategoryModel {
  String id = '';
  String title = '';
  int count = 0;
  int progress = 0;

  VocabCategoryModel();

  VocabCategoryModel.fromMap(Map map) {
    id = map['id'];
    title = map['title'];
    count = map['count'];
    progress = map['progress'];
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['id'] = id;
    map['title'] = title;
    map['count'] = count;
    map['progress'] = progress;

    return map;
  }

  void matchBy(VocabCategoryModel others){
    id = others.id;
    title = others.title;
    progress = others.progress;
    count = others.count;
  }
}
