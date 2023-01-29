import 'package:app/filteringBuilder/filteringItemType.dart';
import 'package:app/filteringBuilder/filteringItems/filteringItem.dart';

class CheckboxFilteringItem extends FilteringItem {
  bool isSelected = false;
  bool isEnable = true;

  CheckboxFilteringItem(){
    filteringType = FilteringItemType.checkbox;
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
}