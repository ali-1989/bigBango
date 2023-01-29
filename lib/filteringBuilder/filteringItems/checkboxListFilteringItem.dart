import 'package:app/filteringBuilder/filteringItemType.dart';
import 'package:app/filteringBuilder/filteringItems/filteringItem.dart';
import 'package:app/filteringBuilder/filteringItems/simpleItem.dart';


class CheckboxListFilteringItem extends FilteringItem {
  List<SimpleItem> items = [];
  bool isEnable = true;
  bool showHorizontalScrolling = true;

  CheckboxListFilteringItem(){
    filteringType = FilteringItemType.checkboxList;
  }

  @override
  int getSelectedCount(){
    int c = 0;

    for(final x in items){
      if(x.isSelected){
        c++;
      }
    }

    return c;
  }

  @override
  bool hasSelected(){
    for(final x in items){
      if(x.isSelected){
        return true;
      }
    }

    return false;
  }

  @override
  void clearFilter(){
    for(final x in items){
      x.isSelected = false;
    }
  }
}