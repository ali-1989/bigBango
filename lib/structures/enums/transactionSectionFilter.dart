
enum TransactionSectionFilter {
  unKnow(-1),
  chargeWallet(1),
  withdrawWallet(2),
  lessonPurchase(3),
  supportPurchase(4),
  forceChargeWallet(5);

  final int number;

  const TransactionSectionFilter(this.number);

  factory TransactionSectionFilter.from(dynamic numberOrString){
    if(numberOrString is String){
      return values.firstWhere((element) => element.name == numberOrString, orElse: ()=> unKnow);
    }

    if(numberOrString is int){
      return values.firstWhere((element) => element.number == numberOrString, orElse: ()=> unKnow);
    }

    return TransactionSectionFilter.unKnow;
  }

  String getTypeHuman(){
    switch(number){
      case 1:
        return 'شارژ کیف پول';
      case 2:
        return 'برداشت از حساب';
      case 3:
        return 'خرید درس';
      case 4:
        return 'خرید پشتیبانی';
      case 5:
        return 'شارژ توسط مدیر';
    }

    return 'ن م';
  }
}