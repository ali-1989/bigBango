import 'package:app/views/components/filteringBuilder/filteringBuilderOption.dart';
import 'package:app/views/components/filteringBuilder/filteringChangePage.dart';
import 'package:app/views/components/filteringBuilder/filteringItemType.dart';
import 'package:app/views/components/filteringBuilder/filteringItems/checkboxListFilteringItem.dart';
import 'package:app/views/components/filteringBuilder/filteringItems/filteringItem.dart';
import 'package:app/views/components/filteringBuilder/filteringItems/simpleItem.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:flutter/material.dart';

class FilteringBuilder extends StatefulWidget {
  final FilteringBuilderOptions options;
  final List<FilteringItem> filteringList;
  final void Function() onChangeFiltering;
  final Function(FilteringItem filteringItem, SimpleItem? simpleItem) onRemoveFilter;

  const FilteringBuilder({
    Key? key,
    required this.options,
    required this.filteringList,
    required this.onChangeFiltering,
    required this.onRemoveFilter,
  }) : super(key: key);

  @override
  State<FilteringBuilder> createState() => _FilteringBuilderState();
}
///===================================================================================
class _FilteringBuilderState extends State<FilteringBuilder> {
  late ThemeData _theme;
  late Color _primaryColor;
  late TextStyle _mainTextStyle;
  late TextDirection _txtDirection;
  late List<FilteringItem> filterList;

  @override
  void initState(){
    super.initState();

    filterList = widget.filteringList;
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initTheme();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        textDirection: _txtDirection,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...itemsBuilder(),
        ],
      ),
    );
  }

  void _initTheme() {
    _theme = widget.options.theme?? Theme.of(context);
    _primaryColor = _theme.primaryColor;
    _txtDirection = widget.options.textDirection?? Directionality.of(context);

    _mainTextStyle = TextStyle(color: widget.options.filterTextColor?? _primaryColor, fontSize: 11);
  }

  List<Widget> itemsBuilder(){
    final res = <Widget>[];

    res.add(_filterButtonBuilder());

    if(getFilterCount() > 0){
      res.add(SizedBox(width: 5));
    }

    for(final f in filterList) {
      if(!f.hasSelected()){
        continue;
      }

      switch (f.filteringType) {
        case FilteringItemType.unKnow:
        case FilteringItemType.thinDivider:
        case FilteringItemType.divider:
        case FilteringItemType.title:
          continue;
        case FilteringItemType.checkbox:
          break;
        case FilteringItemType.checkboxList:
          res.addAll(buildCheckboxList(f as CheckboxListFilteringItem));
          break;
        case FilteringItemType.radioList:
          break;
        case FilteringItemType.rang:
          break;
        case FilteringItemType.custom:
          break;
      }
    }

    return res;
  }

  Widget _filterButtonBuilder(){
    return Flexible(
      child: GestureDetector(
        onTap: (){
          onFilterButtonClick(null, null);
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
              border: widget.options.mainBorder?? Border.all(color: _primaryColor.withAlpha(100), width: 0.5),
              borderRadius: widget.options.mainBorderRadius?? BorderRadius.circular(15),
            color: _primaryColor.withAlpha(10)
          ),
          child: Padding(
            padding: widget.options.padding,
            child: Row(
              textDirection: _txtDirection,
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.options.filterIcon?? Icon(AppIcons.filtering, size: 14, color: _primaryColor),
                SizedBox(width: 4),

                Flexible(
                  child: Row(
                    textDirection: _txtDirection,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                          child: Visibility(
                            visible: getFilterCount() > 0,
                              child: Text('${getFilterCount()}', style: _mainTextStyle,)
                          )
                      ),

                      SizedBox(width: 3),
                      Flexible(child: Text(widget.options.filterText, style: _mainTextStyle)),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  int getFilterCount(){
    int c = 0;

    try{
      for(final x in filterList) {
        switch (x.filteringType) {
          case FilteringItemType.unKnow:
          case FilteringItemType.thinDivider:
          case FilteringItemType.divider:
          case FilteringItemType.title:
            break;
          case FilteringItemType.checkbox:
            c += x.getSelectedCount();
            break;
          case FilteringItemType.checkboxList:
            c += x.getSelectedCount();
            break;
          case FilteringItemType.radioList:
            c += x.getSelectedCount();
            break;
          case FilteringItemType.rang:
            c += x.getSelectedCount();
            break;
          case FilteringItemType.custom:
            c += x.getSelectedCount();
            break;
        }
      }
    }
    catch (e){}

    return c;
  }

  Iterable<Widget> buildCheckboxList(CheckboxListFilteringItem f) {
    final res = <Widget>[];

    for(final x in f.items){
      if(!x.isSelected){
        continue;
      }

      res.add(
          Padding(
            key: ValueKey(x.id),
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: (){
                onAnFilterClick(f, x);
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                    border: widget.options.mainBorder?? Border.all(color: _primaryColor.withAlpha(100), width: 0.5),
                    borderRadius: widget.options.mainBorderRadius?? BorderRadius.circular(15),
                    color: _primaryColor.withAlpha(10)
                ),
                child: Padding(
                  padding: widget.options.padding,
                  child: Row(
                    textDirection: _txtDirection,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(child: Text(x.title, style: _mainTextStyle)),
                      SizedBox(width: 8),
                      GestureDetector(
                          onTap: (){
                            x.isSelected = false;

                            setState(() {});
                            widget.onRemoveFilter.call(f, x);
                          },
                          behavior: HitTestBehavior.translucent,
                          child: Icon(AppIcons.remove, size: 16, color: _primaryColor)
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
      );
    }

    return res;
  }

  void onAnFilterClick(CheckboxListFilteringItem item, SimpleItem? simpleItem){
    onFilterButtonClick(item, simpleItem);
  }

  void onFilterButtonClick(CheckboxListFilteringItem? item, SimpleItem? simpleItem) async {
    final route = MaterialPageRoute(
        builder: (_){
          return FilteringChangePage(
            options: widget.options,
            filteringList: widget.filteringList,
            filterItem: item,
            simpleItem: simpleItem,
          );
        }
    );

    final org = widget.filteringList.map((e) => e.toMap()).toList();

    final res = await Navigator.of(context).push(route);

    if(res is bool && res){
      setState(() {});
      widget.onChangeFiltering.call();
    }
    else {
      widget.filteringList.clear();
      widget.filteringList.addAll(org.map((e) => FilteringItem.builder(e)!).toList());
    }
  }
}
