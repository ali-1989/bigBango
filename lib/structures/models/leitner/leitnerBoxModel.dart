
class LeitnerBoxModel {
  int number = 0;
  int count = 0;
  int readyToLearnCount = 0;

  LeitnerBoxModel();

  LeitnerBoxModel.fromMap(Map map){
    number = map['number'];
    count = map['count'];
    readyToLearnCount = map['readyToLearnCount'];
  }

  Map toMap(){
    final map = <String, dynamic>{};

    map['number'] = number;
    map['count'] = count;
    map['readyToLearnCount'] = readyToLearnCount;

    return map;
  }

  String getNumText(int id){
    switch (id){
      case 1:
        return 'اول';
      case 2:
        return 'دوم';
      case 3:
        return 'سوم';
      case 4:
        return 'جهارم';
      case 5:
        return 'پنجم';
      case 6:
        return 'ششم';
      case 7:
        return 'هفتم';
      case 8:
        return 'هشتم';
      case 9:
        return 'نهم';
    }

    return '';
  }
}