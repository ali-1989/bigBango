
class ReadingCategoryModel {
  String id = '';
  String title = '';

  ReadingCategoryModel();

  ReadingCategoryModel.fromMap(Map map) {
    id = map['id'];
    title = map['title'];
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['id'] = id;
    map['title'] = title;

    return map;
  }

  void matchBy(ReadingCategoryModel others){
    id = others.id;
    title = others.title;
  }
}
