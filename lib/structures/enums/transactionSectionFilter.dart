
enum TransactionSectionFilter {
  unKnow(-1),
  removable(1),
  unermovable(2);

  final int number;

  const TransactionSectionFilter(this.number);

  static TransactionSectionFilter fromType(int num){
    for(final x in TransactionSectionFilter.values){
      if(x.number == num){
        return x;
      }
    }

    return TransactionSectionFilter.unKnow;
  }

  static TransactionSectionFilter fromName(String name){
    for(final x in TransactionSectionFilter.values){
      if(x.name == name){
        return x;
      }
    }

    return TransactionSectionFilter.unKnow;
  }

  String getTypeHuman(){
    switch(number){
      case 1:
        return 'قابل برداشت';
      case 2:
        return 'غیرقابل برداشت';
    }

    return 'ن م';
  }
}