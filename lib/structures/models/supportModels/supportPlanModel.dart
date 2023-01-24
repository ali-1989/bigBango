
class SupportPlanModel {
  String id = '';
  String title = '';
  int minutes = 0;
  int amount = 0;

  SupportPlanModel();

  SupportPlanModel.fromMap(Map map) {
    id = map['id'];
    title = map['title'];
    minutes = map['minutes']?? 1;
    amount = map['amount']?? 1;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['id'] = id;
    map['title'] = title;
    map['minutes'] = minutes;
    map['amount'] = amount;

    return map;
  }
}