
class SpeakingCategoryModel {
  String id = '';
  String title = '';

  SpeakingCategoryModel();

  SpeakingCategoryModel.fromMap(Map map) {
    id = map['id'];
    title = map['title'];
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['id'] = id;
    map['title'] = title;

    return map;
  }

  void matchBy(SpeakingCategoryModel others){
    id = others.id;
    title = others.title;
  }
}
