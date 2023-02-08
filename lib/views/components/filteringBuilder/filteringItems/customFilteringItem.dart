import 'package:flutter/material.dart';

import 'package:app/views/components/filteringBuilder/filteringItemType.dart';
import 'package:app/views/components/filteringBuilder/filteringItems/filteringItem.dart';

typedef CustomBuilder = Widget Function(BuildContext buildContext);
typedef CustomIsSelected = bool Function();
typedef CustomSelectedCount = int Function();
typedef CustomClearFilter = void Function();
//---------------------------------------------------------------------------------
class CustomFilteringItem extends FilteringItem {
  late CustomBuilder customBuilder;
  late CustomIsSelected customIsSelected;
  late CustomSelectedCount customSelectedCount;
  late CustomClearFilter customClearFilter;

  CustomFilteringItem(){
    filteringType = FilteringItemType.custom;
  }

  @override
  bool hasSelected(){
    return customIsSelected.call();
  }

  @override
  int getSelectedCount(){
    return customSelectedCount.call();
  }

  @override
  void clearFilter(){
    customClearFilter.call();
  }

  @override
  Map<String, dynamic> toMap() {
    final res = super.toMap();

    return res;
  }
}
