import 'package:app/filteringBuilder/filteringItemType.dart';
import 'package:app/filteringBuilder/filteringItems/checkboxFilteringItem.dart';
import 'package:app/filteringBuilder/filteringItems/checkboxListFilteringItem.dart';
import 'package:app/filteringBuilder/filteringItems/dividerFilteringItem.dart';

abstract class FilteringItem {
  FilteringItemType filteringType = FilteringItemType.unKnow;
  String? title;
  String? scope;

  FilteringItem();

  int getSelectedCount(){
    return 0;
  }

  bool hasSelected(){
    return false;
  }

  void clearFilter();

  fromMap(Map<String, dynamic> map){
    title = map['title'];
    scope = map['scope'];
    filteringType = FilteringItemType.fromType(map['filteringType']);
  }

  Map<String, dynamic> toMap(){
    final res = <String, dynamic>{};
    res['title'] = title;
    res['scope'] = scope;
    res['filteringType'] = filteringType.number;

    return res;
  }

  static C? builder<C extends FilteringItem>(Map<String, dynamic> map){
    final filteringType = FilteringItemType.fromType(map['filteringType']);

    if(filteringType == FilteringItemType.checkboxList){
      return CheckboxListFilteringItem.fromMap(map) as C;
    }

    if(filteringType == FilteringItemType.divider || filteringType == FilteringItemType.thinDivider){
      return DividerFilteringItem.fromMap(map) as C;
    }

    if(filteringType == FilteringItemType.checkbox){
      return CheckboxFilteringItem.fromMap(map) as C;
    }

    return null;
  }
}