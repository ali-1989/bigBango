import 'package:iris_tools/api/generator.dart';

class SimpleItem {
  late String id;
  late String title;
  dynamic value;
  bool isSelected = false;

  SimpleItem() : id = Generator.generateKey(10);

  SimpleItem.fromMap(Map<String, dynamic> map){
    id = map['id'];
    title = map['title'];
    isSelected = map['isSelected'];
    value = map['value'];
  }

  Map<String, dynamic> toMap() {
    final res = <String, dynamic>{};
    res['id'] = id;
    res['title'] = title;
    res['isSelected'] = isSelected;
    res['value'] = value;

    return res;
  }
}