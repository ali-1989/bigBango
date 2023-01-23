
enum TransactionStatusFilter {
  unKnow(-1),
  removable(1),
  unermovable(2);

  final int number;

  const TransactionStatusFilter(this.number);

  static TransactionStatusFilter fromType(int num){
    for(final x in TransactionStatusFilter.values){
      if(x.number == num){
        return x;
      }
    }

    return TransactionStatusFilter.unKnow;
  }

  static TransactionStatusFilter fromName(String name){
    for(final x in TransactionStatusFilter.values){
      if(x.name == name){
        return x;
      }
    }

    return TransactionStatusFilter.unKnow;
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