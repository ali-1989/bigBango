import 'package:app/views/components/filteringBuilder/filteringItemType.dart';
import 'package:app/views/components/filteringBuilder/filteringItems/filteringItem.dart';
import 'package:app/views/components/filteringBuilder/filteringItems/simpleItem.dart';

class CheckboxListFilteringItem extends FilteringItem {
  List<SimpleItem> items = [];
  bool isEnable = true;
  bool showHorizontalScrolling = true;

  CheckboxListFilteringItem(){
    filteringType = FilteringItemType.checkboxList;
  }

  CheckboxListFilteringItem.fromMap(Map<String, dynamic> map){
    showHorizontalScrolling = map['showHorizontalScrolling'];
    isEnable = map['isEnable'];

    if(map['items'] is List) {
      items = (map['items'] as List).map((e) => SimpleItem.fromMap(e)).toList();
    }

    super.fromMap(map);
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

  @override
  Map<String, dynamic> toMap() {
    final res = super.toMap();
    res['items'] = items.map((e) => e.toMap()).toList();
    res['isEnable'] = isEnable;
    res['showHorizontalScrolling'] = showHorizontalScrolling;

    return res;
  }
}
