import 'package:flutter/material.dart';

import 'package:app/views/components/filteringBuilder/filteringBuilderOption.dart';
import 'package:app/views/components/filteringBuilder/filteringItemType.dart';
import 'package:app/views/components/filteringBuilder/filteringItems/checkboxListFilteringItem.dart';
import 'package:app/views/components/filteringBuilder/filteringItems/filteringItem.dart';
import 'package:app/views/components/filteringBuilder/filteringItems/simpleItem.dart';

class FilteringChangePage extends StatefulWidget {
  final FilteringBuilderOptions options;
  final List<FilteringItem> filteringList;
  final CheckboxListFilteringItem? filterItem;
  final SimpleItem? simpleItem;

  const FilteringChangePage({
    Key? key,
    required this.options,
    required this.filteringList,
    this.filterItem,
    this.simpleItem,
  }) : super(key: key);

  @override
  State<FilteringChangePage> createState() => _FilteringChangePageState();
}
///===================================================================================
class _FilteringChangePageState extends State<FilteringChangePage> {
  late ThemeData _theme;
  late Color _primaryColor;
  late TextStyle _titleStyle;
  late TextStyle _infoStyle;
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

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        iconTheme: _theme.appBarTheme.iconTheme?.copyWith(color: widget.options.appBarItemColor),
        foregroundColor: widget.options.appBarItemColor,
        title: Text('${widget.options.titleText}', style: _theme.appBarTheme.titleTextStyle),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.filteringList.length*2-1,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              itemBuilder: itemsBuilder,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: onApply,
                      child: Text(widget.options.applyText)
                  ),
                ),

                SizedBox(width: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _primaryColor, width: 0.5),
                    foregroundColor: _primaryColor,
                    //backgroundColor: _primaryColor,
                  ),
                    onPressed: clearFiltering,
                    child: Text(widget.options.removeAllText)
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _initTheme() {
    _theme = widget.options.theme?? Theme.of(context);
    _primaryColor = _theme.primaryColor;
    _txtDirection = widget.options.textDirection?? Directionality.of(context);

    final tColor = widget.options.titleTextColor?? _theme.textTheme.bodyText2?.color;
    final iColor = widget.options.infoTextColor?? _theme.textTheme.bodyText2?.color?.withAlpha(140);

    _titleStyle = TextStyle(color: tColor, fontSize: 14);
    _infoStyle = TextStyle(color: iColor, fontSize: 11);
  }

  Widget itemsBuilder(_, idx){
    if(idx % 2 == 1){
      return SizedBox(height: 8);
    }

    final itm = widget.filteringList[idx~/2];

    switch (itm.filteringType) {
      case FilteringItemType.unKnow:
      case FilteringItemType.thinDivider:
        return getThinDivider();
      case FilteringItemType.divider:
        return getDivider();
      case FilteringItemType.title:
        return getTitle(itm);
      case FilteringItemType.checkbox:
        break;
      case FilteringItemType.checkboxList:
        return buildCheckbox(itm as CheckboxListFilteringItem);
      case FilteringItemType.radioList:
        break;
      case FilteringItemType.rang:
        break;
      case FilteringItemType.custom:
        break;
    }

    return SizedBox();
  }

  void clearFiltering(){
    for(final x in widget.filteringList){
      x.clearFilter();
    }

    Navigator.of(context).pop(true);
  }

  void onApply(){
    Navigator.of(context).pop(true);
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

  Widget getThinDivider(){
    return Divider(thickness: 0.2, color: widget.options.dividerColor?? _infoStyle.color);
  }

  Widget getDivider(){
    return Divider(color: widget.options.dividerColor?? _infoStyle.color);
  }

  Widget getTitle(FilteringItem item){
    return Text('${item.title}', style: _titleStyle);
  }

  Widget buildCheckbox(CheckboxListFilteringItem f) {
    if(!f.showHorizontalScrolling){
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${f.title}', style: _titleStyle),

          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (){},
            child: Builder(
              builder: (context) {
                if(f.hasSelected()) {
                  return Text('${f.getSelectedCount()} ${widget.options.item}', style: _infoStyle);
                }

                return Text(widget.options.select, style: TextStyle(color: Colors.lightBlue.withAlpha(200)),);
              }
            ),
          ),
        ],
      );
    }

    final res = <Widget>[];

    for(final x in f.items){
      res.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: (){
                x.isSelected = !x.isSelected;
                setState(() {});
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                    border: widget.options.mainBorder?? Border.all(color: _infoStyle.color!, width: 0.5),
                    borderRadius: widget.options.mainBorderRadius?? BorderRadius.circular(15),
                    //color: _primaryColor.withAlpha(20)
                ),
                child: Padding(
                  padding: widget.options.padding,
                  child: Row(
                    textDirection: _txtDirection,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(child: Text(x.title, style: _infoStyle)),
                      SizedBox(width: 8),
                      SizedBox(
                        height: 17,
                        width: 17,
                        child: FittedBox(
                          child: Checkbox(
                            value: x.isSelected,
                            fillColor: MaterialStateProperty.all(_primaryColor),
                            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                            onChanged: (v){
                              x.isSelected = !x.isSelected;
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${f.title}', style: _titleStyle),
        SizedBox(height: 10),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: res,
          ),
        ),
      ],
    );
  }

}
