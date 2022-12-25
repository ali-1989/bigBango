class VocabInReadingModel {
  late String id;
  late String word;


  VocabInReadingModel();

  VocabInReadingModel.fromMap(Map map) {
    id = map['vocabularyId'];
    word = map['word'];
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['vocabularyId'] = id;
    map['word'] = word;

    return map;
  }
}
