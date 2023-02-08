import 'package:app/views/components/filteringBuilder/filteringItemType.dart';
import 'package:app/views/components/filteringBuilder/filteringItems/filteringItem.dart';

class DividerFilteringItem extends FilteringItem {
  bool isThin;

  DividerFilteringItem({this.isThin = false}){
    filteringType = isThin ? FilteringItemType.thinDivider: FilteringItemType.divider;
  }

  DividerFilteringItem.fromMap(Map<String, dynamic> map): isThin = false{
    isThin = map['isThin'];

    super.fromMap(map);
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

  @override
  Map<String, dynamic> toMap() {
    final res = super.toMap();
    res['isThin'] = isThin;

    return res;
  }
}
