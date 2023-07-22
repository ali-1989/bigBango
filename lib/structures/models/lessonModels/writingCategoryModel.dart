
class WritingCategoryModel {
  String id = '';
  String title = '';

  WritingCategoryModel();

  WritingCategoryModel.fromMap(Map map) {
    id = map['id'];
    title = map['title'];
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['id'] = id;
    map['title'] = title;

    return map;
  }

  void matchBy(WritingCategoryModel others){
    id = others.id;
    title = others.title;
  }
}
