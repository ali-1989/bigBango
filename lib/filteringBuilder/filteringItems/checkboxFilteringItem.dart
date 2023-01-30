import 'package:app/filteringBuilder/filteringItemType.dart';
import 'package:app/filteringBuilder/filteringItems/filteringItem.dart';

class CheckboxFilteringItem extends FilteringItem {
  bool isSelected = false;
  bool isEnable = true;

  CheckboxFilteringItem(){
    filteringType = FilteringItemType.checkbox;
  }

  CheckboxFilteringItem.fromMap(Map<String, dynamic> map){
    isSelected = map['isSelected'];
    isEnable = map['isEnable'];

    super.fromMap(map);
  }

  @override
  int getSelectedCount(){
    return isSelected ? 1 : 0;
  }

  @override
  bool hasSelected(){
    return isSelected;
  }

  @override
  void clearFilter(){
    isSelected = false;
  }

  @override
  Map<String, dynamic> toMap() {
    final res = super.toMap();
    res['isEnable'] = isEnable;
    res['isSelected'] = isSelected;

    return res;
  }
}