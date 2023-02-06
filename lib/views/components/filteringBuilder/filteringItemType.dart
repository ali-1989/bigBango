

enum FilteringItemType {
  unKnow(-1),
  thinDivider(1),
  divider(2),
  title(3),
  checkbox(4),
  checkboxList(5),
  radioList(6),
  rang(7),
  custom(8);

  final int number;

  const FilteringItemType(this.number);

  static FilteringItemType fromType(int num){
    for(final x in FilteringItemType.values){
      if(x.number == num){
        return x;
      }
    }

    return FilteringItemType.unKnow;
  }

  static FilteringItemType fromName(String name){
    for(final x in FilteringItemType.values){
      if(x.name == name){
        return x;
      }
    }

    return FilteringItemType.unKnow;
  }
}