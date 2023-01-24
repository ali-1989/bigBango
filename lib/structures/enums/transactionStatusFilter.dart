
enum TransactionStatusFilter {
  unKnow(-1),
  unpaid(1),
  paid(2),
  inProgress(3),
  rejected(4),
  cancelled(5);

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
        return 'پرداخت نشده';
      case 2:
        return 'پرداخت شده';
      case 3:
        return 'در حال بررسی';
      case 4:
        return 'رد شده';
      case 5:
        return 'لغو شده';
    }

    return 'ن م';
  }
}