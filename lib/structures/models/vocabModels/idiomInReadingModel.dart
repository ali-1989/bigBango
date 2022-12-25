
class IdiomInReadingModel {
  late String id;
  late String content;

  IdiomInReadingModel();

  IdiomInReadingModel.fromMap(Map map) {
    id = map['idiomId'];
    content = map['content'];
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['idiomId'] = id;
    map['content'] = content;

    return map;
  }
}