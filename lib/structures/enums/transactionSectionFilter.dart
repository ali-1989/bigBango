
enum TransactionSectionFilter {
  unKnow(-1),
  chargeWallet(1),
  withdrawWallet(2),
  lessonPurchase(3),
  supportPurchase(4);

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
        return 'شارژ کیف پول';
      case 2:
        return 'برداشت از حساب';
      case 3:
        return 'خرید درس';
      case 4:
        return 'خرید پشتیبانی';
    }

    return 'ن م';
  }
}