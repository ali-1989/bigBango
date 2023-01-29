import 'package:app/filteringBuilder/filteringItemType.dart';
import 'package:app/filteringBuilder/filteringItems/filteringItem.dart';


class DividerFilteringItem extends FilteringItem {
  bool isThin;

  DividerFilteringItem({this.isThin = false}){
    filteringType = isThin ? FilteringItemType.thinDivider: FilteringItemType.divider;
  }

  @override
  bool hasSelected(){
    return false;
  }

  @override
  int getSelectedCount(){
    return 0;
  }

  @override
  void clearFilter(){}
}