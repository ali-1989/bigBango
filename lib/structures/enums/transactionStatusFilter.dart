
enum TransactionStatusFilter {
  unKnow(-1),
  //unpaid(1),
  paid(2),
  inProgress(3),
  rejected(4),
  cancelled(5);

  final int number;

  const TransactionStatusFilter(this.number);

  factory TransactionStatusFilter.from(dynamic numberOrString){
    if(numberOrString is String){
      return values.firstWhere((element) => element.name == numberOrString, orElse: ()=> unKnow);
    }

    if(numberOrString is int){
      return values.firstWhere((element) => element.number == numberOrString, orElse: ()=> unKnow);
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