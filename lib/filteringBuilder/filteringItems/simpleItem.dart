import 'package:iris_tools/api/generator.dart';

class SimpleItem {
  late String id;
  late String title;
  bool isSelected = false;

  SimpleItem() : id = Generator.generateKey(10);
}