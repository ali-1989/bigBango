import 'package:app/filteringBuilder/filteringItemType.dart';

abstract class FilteringItem {
  FilteringItemType filteringType = FilteringItemType.unKnow;
  String? title;

  FilteringItem();

  int getSelectedCount(){
    return 0;
  }

  bool hasSelected(){
    return false;
  }

  void clearFilter();
}