
enum WalletAmountType {
  unKnow(-1),
  removable(1),
  unermovable(2);

  final int number;

  const WalletAmountType(this.number);

  factory WalletAmountType.from(dynamic numberOrString){
    if(numberOrString is String){
      return values.firstWhere((element) => element.name == numberOrString, orElse: ()=> unKnow);
    }

    if(numberOrString is int){
      return values.firstWhere((element) => element.number == numberOrString, orElse: ()=> unKnow);
    }

    return WalletAmountType.unKnow;
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